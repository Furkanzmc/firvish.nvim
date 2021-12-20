if vim.b.did_ftp == true then
    return
end

local map = require("firvish.utils").map
local cmd = vim.cmd
local opt_local = vim.opt_local
local bufnr = vim.api.nvim_get_current_buf()

opt_local.cursorline = true

cmd [[augroup firvish_job_output_preview]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufDelete,BufWipeout,WinClosed <buffer> lua require'firvish.job_control'.on_job_output_preview_bufdeleter()]]
cmd [[augroup END]]

map("n", "gb", ':lua require"firvish.job_control".go_back_from_job_output()<CR>', { silent = true, buffer = bufnr })
