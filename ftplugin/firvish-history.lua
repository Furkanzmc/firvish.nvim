if vim.b.did_firvish_history == true then return end

local map = require'firvish.utils'.map
local history = require 'firvish.history'
local opt_local = vim.opt_local
local cmd = vim.cmd
local bufnr = vim.api.nvim_get_current_buf()

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish-buffers"
opt_local.buftype = "nofile"
opt_local.swapfile = false

map("n", "<enter>", ":lua require'firvish.history'.open_file()<CR>",
    {silent = true, buffer = bufnr})

map("n", "gq", ":lua require'firvish.history'.close_history()<CR>",
    {silent = true, buffer = bufnr})

map("n", "R", ":lua require'firvish.history'.refresh_history()<CR>",
    {silent = true, buffer = bufnr})

map("n", "-", ":edit firvish://<CR>", {silent = true, buffer = bufnr})

history.configure_buffer_preview_keymaps()
history.open_history()

cmd [[augroup neovim_firvish_history]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufEnter <buffer> lua require'firvish.history'.open_history()]]
cmd [[autocmd BufDelete <buffer> lua require'firvish.history'.on_buf_delete()]]
cmd [[autocmd BufWipeout <buffer> lua require'firvish.history'.on_buf_delete()]]
cmd [[autocmd BufLeave <buffer> lua require'firvish.history'.on_buf_leave()]]
cmd [[augroup END]]

vim.b.did_firvish_history = true
