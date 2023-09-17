local utils = require("firvish.utils")
local map = utils.map
local jobs = require("firvish.job_control")
local fn = vim.fn
local g = vim.g
local opt = vim.opt

if g.firvish_use_default_mappings ~= nil and g.firvish_use_default_mappings ~= 0 then
    map(
        "n",
        "<leader>b",
        ":lua require'firvish.buffers'.open_buffers()<CR>",
        { silent = true, nowait = true }
    )

    map(
        "n",
        "<leader>h",
        ":lua require'firvish.history'.open_history()<CR>",
        { silent = true, nowait = true }
    )
end

if g.firvish_shell == nil then
    g.firvish_shell = opt.shell:get()
end

if g.firvish_interactive_window_height == nil then
    g.firvish_interactive_window_height = 3
end

vim.api.nvim_create_user_command("Buffers", function(_)
    require("firvish.buffers").open_buffers()
end, {})

vim.api.nvim_create_user_command("History", function(_)
    require("firvish.history").open_history()
end, {})

if fn.executable("rg") == 1 then
    local function firvish_run_rg(args, use_last_buffer, qf, loc, open)
        local command = {
            "rg",
            "--column",
            "--line-number",
            "--no-heading",
            "--vimgrep",
            "--color=never",
            "--smart-case",
            "--block-buffered",
        }
        if args then
            command = table.extend(command, args)
        end

        jobs.start_job({
            cmd = command,
            filetype = "firvish-dir",
            title = "rg",
            use_last_buffer = use_last_buffer,
            listed = true,
            efm = { "%f:%l:%c:%m" },
            output_qf = qf,
            open_qf = open,
            output_lqf = loc,
            open_lqf = open,
            is_background_job = qf or loc,
        })
    end

    vim.api.nvim_create_user_command("Rg", function(args)
        firvish_run_rg(args.fargs, args.bang, false, false, false)
    end, { nargs = "*", complete = "file", bang = true })

    vim.api.nvim_create_user_command("Crg", function(args)
        firvish_run_rg(args.fargs, false, true, false, false)
    end, { nargs = "*", complete = "file" })

    vim.api.nvim_create_user_command("Lrg", function(args)
        firvish_run_rg(args.fargs, false, false, true, false)
    end, { nargs = "*", complete = "file" })
end

if fn.executable("ugrep") == 1 then
    local function firvish_run_ug(args, use_last_buffer, qf, loc)
        local command = {
            "ugrep",
            "--column-number",
            "--line-number",
            "--color=never",
            "--smart-case",
            "--line-buffered",
            "-J1",
        }
        if args then
            command = table.extend(command, args)
        end

        jobs.start_job({
            cmd = command,
            filetype = "firvish-dir",
            title = "ugrep",
            use_last_buffer = use_last_buffer,
            listed = true,
            output_qf = qf,
            efm = { "%f:%l:%c:%m" },
            output_lqf = loc,
            is_background_job = qf or loc,
        })
    end

    vim.api.nvim_create_user_command("Ug", function(args)
        firvish_run_ug(args.fargs, args.bang, false, false)
    end, { nargs = "*", complete = "file", bang = true })

    vim.api.nvim_create_user_command("Cug", function(args)
        firvish_run_ug(args.fargs, false, true, false)
    end, { nargs = "*", complete = "file" })

    vim.api.nvim_create_user_command("Lug", function(args)
        firvish_run_ug(args.fargs, false, false, true)
    end, { nargs = "*", complete = "file" })
end

if fn.executable("fd") == 1 then
    local function firvish_run_fd(args, use_last_buffer, qf, loc, open)
        local command = { "fd", "--color=never" }
        if args then
            command = table.extend(command, args)
        end

        jobs.start_job({
            cmd = command,
            filetype = "firvish-dir",
            title = "fd",
            use_last_buffer = use_last_buffer,
            listed = true,
            efm = { "%f" },
            output_qf = qf,
            open_qf = open,
            output_lqf = loc,
            open_lqf = open,
            is_background_job = qf or loc,
        })
    end

    vim.api.nvim_create_user_command("Fd", function(args)
        firvish_run_fd(args.fargs, args.bang, false, false)
    end, { nargs = "*", complete = "file", bang = true })

    vim.api.nvim_create_user_command("Cfd", function(args)
        firvish_run_fd(args.fargs, false, true, false)
    end, { nargs = "*", complete = "file" })

    vim.api.nvim_create_user_command("Lfd", function(args)
        firvish_run_fd(args.fargs, false, false, true)
    end, { nargs = "*", complete = "file" })
end

local function firvish_call_frun(args, is_background_job, qf, loc)
    jobs.start_job({
        cmd = args,
        filetype = "firvish-job",
        title = "job",
        use_last_buffer = false,
        listed = true,
        output_qf = qf,
        output_lqf = loc,
        is_background_job = qf or loc or is_background_job,
    })
end

vim.api.nvim_create_user_command("FRun", function(args)
    firvish_call_frun(args.fargs, args.bang, false, false)
end, { nargs = "*", bang = true })

vim.api.nvim_create_user_command("Cfrun", function(args)
    firvish_call_frun(args.fargs, args.bang, true, false)
end, { nargs = "*" })

vim.api.nvim_create_user_command("Lfrun", function(args)
    firvish_call_frun(args.fargs, args.bang, false, true)
end, { nargs = "*" })

vim.api.nvim_create_user_command("Fhdo", function(args)
    require("firvish").open_linedo_buffer(
        args.line1,
        args.line2,
        vim.fn.bufnr(),
        args.args,
        not args.bang
    )
end, { nargs = "*", complete = "shellcmd", bang = true, range = true })

vim.api.nvim_create_user_command("FirvishJobs", function(_)
    require("firvish.job_control").show_jobs_list()
end, { nargs = "*" })

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufAdd" }, {
    group = vim.api.nvim_create_augroup("neovim_firvish_buffer", { clear = true }),
    callback = function(_)
        require("firvish.buffers").mark_dirty()
    end,
})
