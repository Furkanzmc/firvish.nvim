if vim.b.did_ftp == true then
    return
end

local map = require("firvish.utils").map
local cmd = vim.cmd
local opt_local = vim.opt_local

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish-buffers"
opt_local.buftype = "nofile"
opt_local.swapfile = false

require("firvish.config").apply_mappings "buffers"

cmd [[command! -buffer -nargs=* -range Bufdo :lua require'firvish.buffers'.buf_do(<line1>, <line2>, <q-args>)]]

cmd [[command! -buffer -bang -nargs=* -range Bdelete :lua require'firvish.buffers'.buf_delete(<line1>, <line2>, "<bang>" == "!")]]

cmd [[augroup neovim_firvish_buffer_local]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufEnter <buffer> lua require'firvish.buffers'.on_buf_enter()]]
cmd [[autocmd BufDelete,BufWipeout <buffer> lua require'firvish.buffers'.on_buf_delete()]]
cmd [[autocmd BufLeave <buffer> lua require'firvish.buffers'.on_buf_leave()]]
cmd [[augroup END]]
