if vim.g.loaded_firvish == true then return end

local utils = require "firvish.utils"
local map = utils.map
local jobs = require "firvish.job_control"
local cmd = vim.cmd
local fn = vim.fn
local opt_local = vim.opt_local
local opt = vim.opt

require"firvish.settings".init()

map("n", "<leader>b", ":lua require'firvish.buffers'.open_buffers()<CR>",
    {silent = true, nowait = true})

map("n", "<leader>h", ":lua require'firvish.history'.open_history()<CR>",
    {silent = true, nowait = true})

cmd [[command! Buffers lua require'firvish.buffers'.open_buffers()<CR>]]
cmd [[command! History lua require'firvish.history'.open_history()<CR>]]

if vim.g.firvish_shell == nil then vim.g.firvish_shell = opt.shell:get() end

if vim.g.firvish_interactive_window_height == nil then
    vim.g.firvish_interactive_window_height = 3
end

if fn.executable("rg") == 1 then
    function _G.firvish_run_rg(args, use_last_buffer, qf, loc)
        local command = {
            "rg", "--column", "--line-number", "--no-heading", "--vimgrep",
            "--color=never", "--smart-case", "--block-buffered"
        }
        if args then command = table.extend(command, args) end

        jobs.start_job({
            cmd = command,
            filetype = "firvish-dir",
            title = "rg",
            use_last_buffer = use_last_buffer,
            listed = true,
            efm = {"%f:%l:%c:%m"},
            output_qf = qf,
            output_lqf = loc,
            is_background_job = qf or loc
        })
    end

    cmd [[command! -bang -complete=file -nargs=* Rg :lua _G.firvish_run_rg({<f-args>}, "<bang>" == "!")]]
    cmd [[command! -complete=file -nargs=* Crg :lua _G.firvish_run_rg({<f-args>}, false, true, false)]]
    cmd [[command! -complete=file -nargs=* Lrg :lua _G.firvish_run_rg({<f-args>}, false, false, true)]]
end

if fn.executable("ugrep") == 1 then
    function _G.firvish_run_ug(args, use_last_buffer, qf, loc)
        local command = {
            "ugrep", "--column-number", "--line-number", "--color=never",
            "--smart-case", "--line-buffered", "-J1"
        }
        if args then command = table.extend(command, args) end

        jobs.start_job({
            cmd = command,
            filetype = "firvish-dir",
            title = "ugrep",
            use_last_buffer = use_last_buffer,
            listed = true,
            output_qf = qf,
            efm = {"%f:%l:%c:%m"},
            output_lqf = loc,
            is_background_job = qf or loc
        })
    end

    cmd [[command! -bang -complete=file -nargs=* Ug :lua _G.firvish_run_ug({<f-args>}, "<bang>" == "!")]]
    cmd [[command! -complete=file -nargs=* Cug :lua _G.firvish_run_ug({<f-args>}, false, true, false)]]
    cmd [[command! -complete=file -nargs=* Lug :lua _G.firvish_run_ug({<f-args>}, false, false, true)]]
end

if fn.executable("fd") == 1 then
    function _G.firvish_run_fd(args, use_last_buffer, qf, loc)
        local command = {"fd", "--color=never"}
        if args then command = table.extend(command, args) end

        jobs.start_job({
            cmd = command,
            filetype = "firvish-dir",
            title = "fd",
            use_last_buffer = use_last_buffer,
            listed = true,
            efm = {"%f"},
            output_qf = qf,
            output_lqf = loc,
            is_background_job = qf or loc
        })
    end

    cmd [[command! -bang -complete=file -nargs=* Fd :lua _G.firvish_run_fd({<f-args>}, "<bang>" == "!", {"%f"}, false, false)]]
    cmd [[command! -complete=file -nargs=* Cfd :lua _G.firvish_run_fd({<f-args>}, false, true, false)]]
    cmd [[command! -complete=file -nargs=* Lfd :lua _G.firvish_run_fd({<f-args>}, false, false, true)]]
end

function _G.firvish_call_frun(args, is_background_job, qf, loc)
    jobs.start_job({
        cmd = args,
        filetype = "firvish-job",
        title = "job",
        use_last_buffer = false,
        is_background_job = is_background_job,
        listed = true,
        output_qf = qf,
        output_lqf = loc,
        is_background_job = qf or loc or is_background_job
    })
end

cmd [[command! -bang -complete=file -nargs=* FRun :lua _G.firvish_call_frun({<f-args>}, "<bang>" == "!")]]
cmd [[command! -complete=file -nargs=* Cfrun :lua _G.firvish_call_frun({<f-args>}, false, true, false)]]
cmd [[command! -complete=file -nargs=* Lfrun :lua _G.firvish_call_frun({<f-args>}, false, false, true)]]

cmd [[command! -nargs=* -complete=shellcmd -bang -range Fhdo lua require'firvish'.open_linedo_buffer(<line1>, <line2>, vim.fn.bufnr(), <q-args>, "<bang>" ~= "!")]]

cmd [[command! -bar FirvishJobs lua require'firvish.job_control'.show_jobs_list()]]

cmd [[command! -bang -nargs=* -range FhFilter :lua require"firvish".filter_lines( <line1>, <line2>, "<bang>" ~= "!", <q-args>)]]

cmd [[command! -bang -range FhQf :lua require"firvish".set_lines_to_qf( <line1>, <line2> - 1, "<bang>" == "!", false)]]

cmd [[command! -bang -range Fhllist :lua require"firvish".set_lines_to_qf( <line1>, <line2>, "<bang>" == "!", true)]]

cmd [[augroup neovim_firvish_buffer]]
cmd [[autocmd!]]
cmd [[autocmd BufDelete,BufWipeout,BufAdd * lua require'firvish.buffers'.mark_dirty()]]
cmd [[augroup END]]

vim.g.loaded_firvish = true
