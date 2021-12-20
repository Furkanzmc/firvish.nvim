local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local b = vim.b
local M = {}

local utils = require "firvish.utils"
local notifications = require "firvish.notifications"
local firvish = require "firvish"
local options_loaded, options = pcall(require, "options")

local s_jobs = {}
local s_job_count = 1
local s_opened_buffers = {}
local s_job_list_bufnr = -1
local s_job_output_preview_bufnr = -1

-- Locals {{{

local function create_job_list_item(job_id, job)
    local line = "[" .. job_id .. "] " .. job.start_time .. " -> "

    if job.finish_time == "" then
        line = line .. "?"
    else
        line = line .. job.finish_time
    end

    if job.output_qf then
        line = line .. " [QF]"
    elseif job.output_lqf then
        line = line .. " [LOC]"
    end

    if job.is_background_job then
        line = line .. " [B]"
    end

    if job.running then
        line = line .. " [R]"
    elseif not job.running then
        line = line .. " [F]"
    end

    if not job.running and job.exit_code == nil then
        line = line .. " [E:0]"
    elseif not job.running then
        line = line .. " [E:" .. job.exit_code .. "]"
    end

    local cmdString = ""
    for _, word in ipairs(job.cmd) do
        cmdString = cmdString .. " " .. word
    end
    cmdString = string.gsub(cmdString, "^ ", "")
    line = line .. " " .. cmdString

    -- These are the optional line that will be echoed on cursor hold.
    local additional = 'Started: "' .. job.start_time .. '"'
    if not job.running then
        additional = additional .. ' Finished: "' .. job.finish_time .. '"'
    end

    return { echo = additional, job_id = job_id, line = line }
end

local function create_job_list_window(lines, job_list)
    local bufnr = utils.create_preview_window("Firvish Jobs", lines)
    api.nvim_buf_set_option(bufnr, "filetype", "firvish-job-list")
    api.nvim_buf_set_var(bufnr, "firvish_job_list_additional_lines", job_list)

    return bufnr
end

local function get_jobs_preview_data()
    local job_list = {}

    for job_id, value in pairs(s_jobs) do
        local line = create_job_list_item(job_id, value)

        table.insert(job_list, line)
    end

    table.sort(job_list, function(a, b)
        return a.job_id > b.job_id
    end)

    local lines = {}
    for _, value in pairs(job_list) do
        table.insert(lines, value.line)
    end

    return { lines = lines, job_list = job_list }
end

local function check_start_job_args(opts)
    assert(opts ~= nil, "opts cannot be nil.")
    assert(opts.cmd ~= nil, "cmd is required.")
    assert(opts.filetype ~= nil, "filetype is required.")
    assert(opts.title ~= nil, "title is required.")

    opts.use_last_buffer = opts.use_last_buffer or false
    opts.is_background_job = opts.is_background_job or false
    opts.listed = opts.listed or false
    opts.output_qf = opts.output_qf or false
    opts.output_lqf = opts.output_lqf or false
    opts.efm = opts.efm or {}
    opts.notify = opts.notify or false
    if opts.output_qf == 1 then
        opts.output_qf = true
    elseif opts.output_qf == 0 then
        opts.output_qf = false
    end
    opts.open_qf = opts.output_qf and opts.open_qf or false
    opts.open_lqf = opts.output_lqf and opts.open_lqf or false

    opts.cwd = opts.cwd or fn.getcwd()
    opts.cwd = fn.expand(opts.cwd)

    if opts.output_qf then
        for _, value in pairs(s_jobs) do
            if value.output_qf and value.running then
                utils.log_error "There's already a job running with quickfix."
                return nil
            end
        end
    elseif opts.output_lqf then
        for _, value in pairs(s_jobs) do
            if value.output_lqf and value.running then
                utils.log_error "There's already a job running with local-list window."
                return nil
            end
        end
    end

    return opts
end

-- }}}

-- Internal {{{

M.stop_job = function()
    assert(vim.wo.previewwindow, "Cannot called when not in preview window.")

    local bufnr = fn.bufnr()
    local linenr = fn.line "."

    local additional_lines = api.nvim_buf_get_var(bufnr, "firvish_job_list_additional_lines")
    local info = additional_lines[linenr]
    local job_info = s_jobs[info.job_id]
    if not job_info.running then
        return
    end

    fn.jobstop(info.job_id)
    M.refresh_job_list_window()
end

M.delete_job_from_history = function(stop_job)
    assert(vim.wo.previewwindow, "Cannot called when not in preview window.")

    local additional_lines = api.nvim_buf_get_var(bufnr, "firvish_job_list_additional_lines")
    local info = additional_lines[linenr]
    local job_info = s_jobs[info.job_id]
    if job_info.running and not stop_job then
        utils.log_error "Job is still running."
        return
    end

    if job_info.running then
        job_info.listed = false
        fn.jobstop(info.job_id)
    else
        s_jobs[info.job_id] = nil
    end

    additional_lines[linenr] = nil
    api.nvim_buf_set_var(bufnr, "firvish_job_list_additional_lines", additional_lines)

    M.refresh_job_list_window()
end

-- Event Handlers {{{

M.on_job_list_bufdelete = function()
    s_job_list_bufnr = -1
end

M.on_job_output_preview_bufdeleter = function()
    s_job_output_preview_bufnr = -1
end

-- }}}

-- }}}

-- Job Control {{{

local function on_stdout(job_id, data, name)
    local job_info = s_jobs[job_id]
    if #data == 1 and data[#data] == "" then
        return
    end

    for index, line in pairs(data) do
        data[index] = string.gsub(line, "\r", "")
    end

    if #data > 1 and data[#data] == "" then
        data[#data] = nil
    end

    utils.merge_table(job_info.stdout, data)
    utils.merge_table(job_info.output, data)

    if job_info.output_qf then
        utils.set_qflist(data, "a", job_info.bufnr, job_info.efm, false)
    elseif job_info.output_lqf then
        utils.set_qflist(data, "a", job_info.bufnr, job_info.efm, true)
    end

    if not job_info.is_background_job then
        assert(job_info.bufnr > 0, "Invalid bufnr.")
        vim.fn.appendbufline(job_info.bufnr, "$", data)
    end

    if
        s_job_output_preview_bufnr ~= -1
        and api.nvim_buf_get_var(s_job_output_preview_bufnr, "firvish_job_id") == job_id
    then
        vim.fn.appendbufline(s_job_output_preview_bufnr, "$", data)
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
    for index, error in ipairs(data) do
        error_lines[index] = "ERROR: " .. error
    end

    local job_info = s_jobs[job_id]
    utils.merge_table(job_info.stderr, data)
    utils.merge_table(job_info.output, data)

    if job_info.output_qf then
        utils.set_qflist(data, "a", job_info.bufnr, job_info.efm, false)
    elseif job_info.output_lqf then
        utils.set_qflist(data, "a", job_info.bufnr, job_info.efm, true)
    end

    if not job_info.is_background_job then
        vim.fn.appendbufline(job_info.bufnr, "$", data)
    end

    if
        s_job_output_preview_bufnr ~= -1
        and api.nvim_buf_get_var(s_job_output_preview_bufnr, "firvish_job_id") == job_id
    then
        vim.fn.appendbufline(s_job_output_preview_bufnr, "$", data)
    end
end

local function on_exit(job_id, exit_code, event)
    local job_info = s_jobs[job_id]
    job_info.finish_time = fn.strftime "%H:%M:%S"
    local finished_message = "Job Finished at " .. job_info.finish_time
    if not job_info.is_background_job then
        assert(job_info.bufnr > 0, "bufnr is invalid.")

        vim.fn.appendbufline(job_info.bufnr, "$", { "[firvish] " .. finished_message })
        api.nvim_buf_set_var(job_info.bufnr, "firvish_job_id", -1)
    end

    if job_info.output_qf then
        utils.set_qflist({ "[firvish] " .. finished_message }, "a", job_info.bufnr)
    elseif job_info.output_lqf then
        utils.set_qflist({ "[firvish] " .. finished_message }, "a", job_info.bufnr, {}, true)
    end

    if job_info.notify then
        notifications.notify(finished_message, "info", {
            plugin = "firvish",
            title = "Firvish Jobs",
            timeout = 1000,
        })
    end

    if job_info.listed == true then
        job_info.running = false
        job_info.exit_code = exit_code
        M.refresh_job_list_window()
    else
        s_jobs[job_id] = nil
    end

    if job_info.open_qf then
        cmd [[copen]]
    elseif job_info.open_lqf then
        cmd [[lopen]]
    end
end

-- }}}

-- Public API {{{

M.start_job = function(opts)
    opts = check_start_job_args(opts)
    if opts == nil then
        return
    end

    local buf_title = "firvish " .. opts.title .. "-" .. s_job_count
    local bufnr = -1

    if opts.use_last_buffer and api.nvim_buf_get_option(0, "filetype") == opts.filetype then
        bufnr = fn.bufnr()
    elseif opts.use_last_buffer and s_opened_buffers[opts.filetype] ~= nil then
        bufnr = s_opened_buffers[opts.filetype]
    end

    if (bufnr == -1 or fn.bufexists(bufnr) == 0) and not opts.is_background_job then
        bufnr = utils.open_firvish_buffer(buf_title, opts.filetype, { buflisted = true })
        s_opened_buffers[opts.filetype] = bufnr
        assert(bufnr ~= -1, "Invalid bufnr")
    end

    s_job_count = s_job_count + 1

    if not opts.use_last_buffer and not opts.is_background_job then
        api.nvim_command("buffer " .. bufnr)
    end

    if opts.output_qf then
        utils.set_qflist({}, " ")
    elseif opts.output_qf then
        utils.set_qflist({}, " ", nil, {}, true)
    end

    local job_id = fn.jobstart(opts.cmd, {
        on_stderr = on_stderr,
        on_stdout = on_stdout,
        on_exit = on_exit,
        stderr_buffered = false,
        stdout_buffered = false,
        cwd = opts.cwd,
        detach = false,
    })

    if job_id == 0 then
        utils.log_error "Invalid arguments were provided to start_job."
    elseif job_id == -1 then
        utils.log_error "Command or 'shell' is not executable."
    end

    if not opts.is_background_job then
        api.nvim_buf_set_var(bufnr, "firvish_job_id", job_id)
    end

    local job_info = {
        bufnr = api.nvim_get_current_buf(),
        title = buf_title,
        stdout = {},
        stderr = {},
        output = {},
        running = true,
        start_time = fn.strftime "%H:%M:%S",
        finish_time = "",
        exit_code = nil,
    }
    s_jobs[job_id] = vim.tbl_extend("keep", job_info, opts)
    if opts.output_qf then
        utils.set_qflist({
            "[firvish] Job Started at " .. s_jobs[job_id].start_time,
        }, "a", s_jobs[job_id].bufnr)
    elseif opts.output_lqf then
        utils.set_qflist({
            "[firvish] Job Started at " .. s_jobs[job_id].start_time,
        }, "a", s_jobs[job_id].bufnr, {}, true)
    end

    M.refresh_job_list_window()
    if
        (s_job_list_bufnr ~= -1 or s_job_output_preview_bufnr ~= -1)
        and options_loaded
        and options.get_option_value "alwayspreview" == true
    then
        M.preview_job_output(job_id)
    end
end

M.refresh_job_list_window = function()
    if s_job_list_bufnr ~= -1 then
        local cursor = nil
        if vim.fn.bufnr() == s_job_list_bufnr then
            cursor = api.nvim_win_get_cursor(0)
        end

        M.show_jobs_list()

        if cursor ~= nil then
            api.nvim_win_set_cursor(0, cursor)
        end
    end
end

M.show_jobs_list = function()
    local data = get_jobs_preview_data()
    s_job_list_bufnr = create_job_list_window(data.lines, data.job_list)
end

M.preview_job_output = function(job_id)
    local job_info = s_jobs[job_id]
    if job_info == nil then
        utils.log_error("Job does not exist: " .. job_id)
        return
    end

    local linenr = -1
    if s_job_list_bufnr ~= -1 then
        linenr = vim.fn.line "."
    end

    local cmdString = ""
    for _, word in ipairs(s_jobs[job_id].cmd) do
        cmdString = cmdString .. " " .. word
    end
    cmdString = string.gsub(cmdString, "^ ", "")

    s_job_output_preview_bufnr = utils.create_preview_window(cmdString, job_info.output)
    api.nvim_buf_set_var(s_job_output_preview_bufnr, "firvish_job_id", job_id)
    api.nvim_buf_set_option(s_job_output_preview_bufnr, "filetype", "firvish-job-output")

    if linenr ~= -1 then
        api.nvim_buf_set_var(s_job_output_preview_bufnr, "firvish_job_list_linenr", linenr)
    end

    cmd [["augroup firvish_job_preview"]]
    cmd("autocmd! * <buffer=" .. s_job_output_preview_bufnr .. ">")
    cmd [[autocmd BufDelete,BufWipeout,WinClosed <buffer> lua require'firvish.job_control'.on_job_output_preview_bufdeleter()]]
    cmd [[augroup END]]
end

function M.echo_job_output(job_id, line)
    local job_info = s_jobs[job_id]
    if job_info == nil then
        utils.log_error("Job does not exist: " .. job_id)
        return
    end

    if line == 0 then
        line = 1
    end

    if line < 0 then
        line = #job_info.output - ((line + 1) * -1)
    end

    vim.cmd("echo " .. fn.shellescape(job_info.output[line]))
end

function M.go_back_from_job_output()
    assert(b.did_firvish_output ~= nil, "b:did_firvish_output must be set.")
    if b.firvish_job_list_linenr ~= nil then
        local bufnr = b.firvish_job_list_linenr
        fn.execute "FirvishJobs"
        fn.execute "wincmd P"
        fn.execute("normal " .. bufnr .. "G")
    else
        fn.execute "FirvishJobs"
    end
end

-- }}}

return M

-- vim: foldmethod=marker
