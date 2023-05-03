if vim.b.did_ftp == true then
    return
end

local opt_local = vim.opt_local
local cmd = vim.cmd

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish-buffers"
opt_local.buftype = "nofile"
opt_local.swapfile = false

require("firvish.config").apply_mappings("history")

cmd([[augroup neovim_firvish_history]])
cmd([[autocmd! * <buffer>]])
cmd([[autocmd BufEnter <buffer> lua require'firvish.history'.open_history()]])
cmd([[autocmd BufDelete <buffer> lua require'firvish.history'.on_buf_delete()]])
cmd([[autocmd BufWipeout <buffer> lua require'firvish.history'.on_buf_delete()]])
cmd([[autocmd BufLeave <buffer> lua require'firvish.history'.on_buf_leave()]])
cmd([[augroup END]])
