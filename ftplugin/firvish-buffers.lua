if vim.b.did_ftp == true then
    return
end

local map = require("firvish.utils").map
local cmd = vim.cmd
local opt_local = vim.opt_local
local bufnr = vim.api.nvim_get_current_buf()

opt_local.cursorline = true
opt_local.modifiable = true
opt_local.buflisted = true
opt_local.syntax = "firvish-buffers"
opt_local.buftype = "nofile"
opt_local.swapfile = false

map("n", "<enter>", ":lua require'firvish.buffers'.jump_to_buffer()<CR>", { silent = true, buffer = bufnr })

map("n", "fm", ':lua require"firvish.buffers".filter_buffers("modified")<CR>', { silent = true, buffer = bufnr })

map("n", "ft", ':lua require"firvish.buffers".filter_buffers("current_tab")<CR>', { silent = true, buffer = bufnr })

map("n", "fa", ':lua require"firvish.buffers".filter_buffers("args")<CR>', { silent = true, buffer = bufnr })

map("n", "R", ':lua require"firvish.buffers".refresh_buffers()<CR>', { silent = true, buffer = bufnr })

cmd [[command! -buffer -nargs=* -range Bufdo :lua require'firvish.buffers'.buf_do(<line1>, <line2>, <q-args>)]]

cmd [[command! -buffer -bang -nargs=* -range Bdelete :lua require'firvish.buffers'.buf_delete(<line1>, <line2>, "<bang>" == "!")]]

cmd [[augroup neovim_firvish_buffer_local]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufEnter <buffer> lua require'firvish.buffers'.on_buf_enter()]]
cmd [[autocmd BufDelete,BufWipeout <buffer> lua require'firvish.buffers'.on_buf_delete()]]
cmd [[autocmd BufLeave <buffer> lua require'firvish.buffers'.on_buf_leave()]]
cmd [[augroup END]]
