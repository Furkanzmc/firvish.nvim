if vim.b.did_firvish_job_list == true then return end

local map = require"firvish.utils".map
local cmd = vim.cmd
local opt_local = vim.opt_local
local bufnr = vim.api.nvim_get_current_buf()

opt_local.modifiable = false
opt_local.readonly = true
opt_local.cursorline = true

cmd [[augroup firvish_job_list_preview]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufDelete,BufWipeout,WinClosed <buffer> lua require'firvish.job_control'.on_job_list_bufdelete()]]
cmd [[augroup END]]

map("n", "R", ":lua require'firvish.job_control'.refresh_job_list_window()<CR>",
    {silent = true, buffer = bufnr})

map("n", "dd",
    ":lua require'firvish.job_control'.delete_job_from_history(false)<CR>",
    {silent = true, buffer = bufnr})

map("n", "S", ":lua require'firvish.job_control'.stop_job()<CR>",
    {silent = true, buffer = bufnr})

map("n", "P",
    ":execute \":lua require'firvish.job_control'.preview_job_output(\" . b:firvish_job_list_additional_lines[line(\".\") - 1].job_id . \")\"<CR>",
    {silent = true, buffer = bufnr})

map("n", "E",
    ":execute \"lua require'firvish.job_control'.echo_job_output(\" . b:firvish_job_list_additional_lines[line(\".\") - 1].job_id . \", \" . max([v:count, 1]) * -1 . \")\"<CR>",
    {silent = true, buffer = bufnr})

vim.b.did_firvish_job_list = true
