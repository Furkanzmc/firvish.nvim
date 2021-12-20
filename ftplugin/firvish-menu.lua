if vim.b.did_ftp == true then
  return
end

local map = require("firvish.utils").map
local cmd = vim.cmd
local opt_local = vim.opt_local
local bufnr = vim.api.nvim_get_current_buf()
local menu = require "firvish.menu"

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish"
opt_local.buftype = "nofile"
opt_local.swapfile = false

map("n", "R", ":lua require'firvish.menu'.refresh_menu()<CR>", { silent = true, buffer = bufnr })

map("n", "<enter>", ":lua require'firvish.menu'.open_item(vim.fn.line('.'))<CR>", { silent = true, buffer = bufnr })

cmd [[augroup neovim_firvish_buffer_local]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufEnter <buffer> lua require'firvish.menu'.on_buf_enter()]]
cmd [[autocmd BufDelete,BufWipeout <buffer> lua require'firvish.menu'.on_buf_delete()]]
cmd [[augroup END]]

menu.open()
