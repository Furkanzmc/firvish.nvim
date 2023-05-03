if vim.b.did_ftp == true then
    return
end

local cmd = vim.cmd
local opt_local = vim.opt_local

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish"
opt_local.buftype = "nofile"
opt_local.swapfile = false

require("firvish.config").apply_mappings("menu")

cmd([[augroup neovim_firvish_buffer_local]])
cmd([[autocmd! * <buffer>]])
cmd([[autocmd BufEnter <buffer> lua require'firvish.menu'.on_buf_enter()]])
cmd([[autocmd BufDelete,BufWipeout <buffer> lua require'firvish.menu'.on_buf_delete()]])
cmd([[augroup END]])

require("firvish.menu").open()
