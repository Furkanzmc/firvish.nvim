local vim = vim
local fn = vim.fn
local M = {}
local utils = require'firvish.utils'
local firvish = require'firvish'

local jobs = {}
local job_count = 1
local opened_buffers = {}
local job_output_preview_bufnr = -1
local s_preview_bufnr = -1
local auto_close_preview_window = true

-- Locals {{{

local function create_job_list_window(lines, job_list)
    local bufnr = utils.create_preview_window("Firvish Jobs", lines)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "firvish-job-list")
    vim.api.nvim_buf_set_var(bufnr, "firvish_job_list_additional_lines", job_list)

    return bufnr
end

local function get_jobs_preview_data()
    local job_list = {}

    for job_id,value in pairs(jobs) do
        local line = "[" .. job_id .. "] " .. value.start_time .. " -> "

        if value.finish_time == "" then
            line = line .. "?"
        else
            line = line .. value.finish_time
        end

        if value.output_qf then
            line = line .. " [QF]"
        end

        if value.is_background_job then
            line = line .. " [B]"
        end

        if value.running then
            line = line .. " [R]"
        elseif not value.running then
            line = line .. " [F]"
        end

        line = line .. " [E:" .. value.exit_code .. "]"

        local cmdString = ""
        for _, word in ipairs(value.cmd) do
            cmdString = cmdString .. " " .. word
        end
        cmdString = string.gsub(cmdString, "^ ", "")
        line = line .. ' ' .. cmdString

        -- These are the optional line that will be echoed on cursor hold.
        local additonal = 'Started: "' .. value.start_time .. '"'
        if not value.running then
            additonal = additonal .. ' Finished: "' .. value.finish_time .. '"'
        end

        table.insert(job_list, {echo=additonal, job_id=job_id, line=line})
    end

    table.sort(job_list, function(a, b) return a.job_id > b.job_id end)

    local lines = {}
    for _,value in pairs(job_list) do
        table.insert(lines, value.line)
    end

    return {
        lines=lines,
        job_list=job_list
    }
end

local function close_job_output_preview()
    assert(job_output_preview_bufnr ~= -1)

    vim.api.nvim_command("bdelete " .. job_output_preview_bufnr)
    job_output_preview_bufnr = -1
end

-- }}}

-- Job Control {{{

local function on_stdout(job_id, data, name)
    local job_info = jobs[job_id]
    if #data == 1 and data[#data] == "" then
        return
    end

    for index,line in pairs(data) do
        data[index] = string.gsub(line, "\r", "")
    end

    if #data > 1 and data[#data] == "" then
        data[#data] = nil
    end

    utils.merge_table(job_info.stdout, data)
    utils.merge_table(job_info.output, data)

    if job_info.output_qf == true then
        utils.set_qflist(data, "a")
    end

    if not job_info.is_background_job then
        vim.fn.appendbufline(job_info.bufnr, "$", data)
    end
end

local function on_stderr(job_id, data, name)
    if #data == 1 and data[#data] == "" then
        return
    end

    if #data > 1 and data[#data] == "" then
        data[#data] = nil
    end

    local error_lines = {}
    for index,error in ipairs(data)
    do
        error_lines[index] = "ERROR: " .. error
    end

    local job_info = jobs[job_id]
    utils.merge_table(job_info.stderr, error_lines)
    utils.merge_table(job_info.output, error_lines)

    if job_info.output_qf == true then
        utils.set_qflist(data, "a")
    end

    if not job_info.is_background_job then
        vim.fn.appendbufline(job_info.bufnr, "$", data)
    end
end

local function on_exit(job_id, exit_code, event)
    local job_info = jobs[job_id]
    if not job_info.is_background_job then
        vim.fn.appendbufline(job_info.bufnr, "$", {"[firvish] Job Finished..."})
    end

    job_info.finish_time = fn.strftime('%H:%M:%S')
    if job_info.output_qf == true then
        utils.set_qflist({"[firvish] Job Finished at " .. job_info.finish_time}, "a")
    end

    vim.api.nvim_buf_set_var(bufnr, "firvish_job_id", -1)

    if job_info.is_listed == true then
        job_info.running = false
        job_info.exit_code = exit_code
        M.refresh_job_preview_window()
    else
        jobs[job_id] = nil
    end
end

-- }}}

-- Public API {{{

M.start_job = function(opts)
    assert(opts ~= nil)
    assert(opts.cmd ~= nil)
    assert(opts.filetype ~= nil)
    assert(opts.title ~= nil)

    opts.use_last_buffer = opts.use_last_buffer or false
    opts.is_background_job = opts.is_background_job or false
    opts.listed = opts.listed or false
    opts.output_qf = opts.output_qf or false
    opts.cwd = opts.cwd or fn.getcwd()
    opts.cwd = fn.expand(opts.cwd)

    if opts.output_qf then
        for _,value in pairs(jobs) do
            if value.output_qf and value.running then
                utils.log_error("There's already a job running with quickfix.")
                return
            end
        end
    end

    local buf_title = "firvish [" .. opts.title .. "-" .. job_count .. "]"
    local bufnr = -1

    if opts.use_last_buffer and vim.api.nvim_buf_get_option(0, "filetype") == opts.filetype then
        bufnr = fn.bufnr()
    elseif opts.use_last_buffer and opened_buffers[opts.filetype] ~= nil then
        bufnr = opened_buffers[opts.filetype]
    end

    if (bufnr == -1 or fn.bufexists(bufnr) == 0) and not opts.is_background_job then
        bufnr = utils.open_firvish_buffer(
            buf_title, opts.filetype, {buflisted=true}
            )
        opened_buffers[opts.filetype] = bufnr
        assert(bufnr ~= -1)
    end

    job_count = job_count + 1

    if not opts.use_last_buffer and not opts.is_background_job then
        vim.api.nvim_command("buffer " .. bufnr)
    end

    if opts.output_qf then
        utils.set_qflist({}, "r")
    end

    local job_id = fn.jobstart(opts.cmd, {
            on_stderr=on_stderr,
            on_stdout=on_stdout,
            on_exit=on_exit,
            stderr_buffered=false,
            stdout_buffered=false,
            cwd=opts.cwd,
            detach=false,
        })

    if job_id == 0 then
        utils.log_error("Invalid arguments were provided to start_job.")
    elseif job_id == -1 then
        utils.log_error("Command or 'shell' is not executable.")
    end

    if not opts.is_background_job then
        vim.api.nvim_buf_set_var(bufnr, "firvish_job_id", job_id)
    end

    jobs[job_id] = {
        bufnr=bufnr,
        cmd=opts.cmd,
        title=buf_title,
        stdout={},
        stderr={},
        output={},
        running=true,
        is_background_job=opts.is_background_job,
        start_time=fn.strftime('%H:%M:%S'),
        finish_time="",
        exit_code=nil,
        is_listed=opts.listed,
        output_qf=opts.output_qf
    }
    if opts.output_qf then
        utils.set_qflist({"[firvish] Job Started at " .. jobs[job_id].start_time}, "a")
    end
end

M.refresh_job_preview_window = function()
    if s_preview_bufnr ~= -1 then
        local cursor = nil
        if vim.fn.bufnr() == s_preview_bufnr then
            cursor = vim.api.nvim_win_get_cursor(0)
        end

        M.show_jobs_list()

        if cursor ~= nil then
            vim.api.nvim_win_set_cursor(0, cursor)
        end
    end
end

M.show_jobs_list = function()
    local data = get_jobs_preview_data()
    s_preview_bufnr = create_job_list_window(data.lines, data.job_list)
end

M.preview_job_output = function(job_id)
    auto_close_preview_window = false
    local job_info = jobs[job_id]
    if job_info == nil then
        utils.log_error("Job does not exist: " .. job_id)
        return
    end

    vim.api.nvim_command("botright new")
    local bufnr = utils.open_firvish_buffer(
        "Job Output", "firvish-job", {buflisted=false}
        )

    vim.api.nvim_command("augroup firvish_job_output_preview")
    vim.api.nvim_command("autocmd!")
    vim.api.nvim_command("augroup END")

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, job_info.output)

    job_output_preview_bufnr = bufnr

    vim.api.nvim_command("augroup firvish_job_output_preview")
    vim.api.nvim_command("autocmd!")
    vim.api.nvim_command(
        "autocmd BufLeave <buffer=" .. bufnr .. "> lua require'firvish.job_control'.on_job_output_preview_bufleave()")
    vim.api.nvim_command("augroup END")
end

-- }}}

-- Internal {{{

M.stop_job = function()
    assert(vim.wo.previewwindow)

    local bufnr = fn.bufnr()
    local linenr = fn.line(".")

    local additional_lines = vim.api.nvim_buf_get_var(bufnr, "firvish_job_list_additional_lines")
    local info = additional_lines[linenr]
    local job_info = jobs[info.job_id]
    if not job_info.running then
        return
    end

    fn.jobstop(info.job_id)
    M.refresh_job_preview_window()
end

M.delete_job_from_history = function(stop_job)
    assert(vim.wo.previewwindow)

    local bufnr = fn.bufnr()
    local linenr = fn.line(".")

    local additional_lines = vim.api.nvim_buf_get_var(bufnr, "firvish_job_list_additional_lines")
    local info = additional_lines[linenr]
    local job_info = jobs[info.job_id]
    if job_info.running and not stop_job then
        utils.log_error("Job is still running.")
        return
    end

    if job_info.running then
        job_info.is_listed = false
        fn.jobstop(info.job_id)
    else
        jobs[info.job_id] = nil
    end

    additional_lines[linenr] = nil
    vim.api.nvim_buf_set_var(bufnr, "firvish_job_list_additional_lines", additional_lines)

    M.refresh_job_preview_window()
end

-- Event Handlers {{{

M.on_preview_buf_delete = function()
    s_preview_bufnr = -1
end

M.on_job_output_preview_bufleave = function()
    if job_output_preview_bufnr ~= -1 then
        close_job_output_preview()
    end

    auto_close_preview_window = true
end

-- }}}

-- }}}

return M

-- vim: foldmethod=marker
