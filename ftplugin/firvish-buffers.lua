if vim.b.did_firvish_buffers == true then return end

local map = require"firvish.utils".map

vim.opt_local.cursorline = true
vim.opt_local.modifiable = true
vim.opt_local.buflisted = true
vim.opt_local.syntax = "firvish-buffers"
vim.opt_local.buftype = "nofile"
vim.opt_local.bufhidden = "wipe"
vim.opt_local.swapfile = false

local bufnr = vim.api.nvim_get_current_buf()

map("n", "<enter>", ":lua require'firvish.buffers'.jump_to_buffer()<CR>",
    {silent = true, buffer = bufnr})

map("n", "fm", ':lua require"firvish.buffers".filter_buffers("modified")<CR>',
    {silent = true, buffer = bufnr})

map("n", "ft",
    ':lua require"firvish.buffers".filter_buffers("current_tab")<CR>',
    {silent = true, buffer = bufnr})

map("n", "fa", 'lua require"firvish.buffers".filter_buffers("args")<CR>',
    {silent = true, buffer = bufnr})

map("n", "<s-R>", 'lua require"firvish.buffers".refresh_buffers()<CR>',
    {silent = true, buffer = bufnr})

vim.cmd [[command! -buffer -nargs=* -range Bufdo :lua require'firvish.buffers'.buf_do(<line1>, <line2>, <q-args>)]]

vim.cmd [[command! -buffer -bang -nargs=* -range Bdelete :lua require'firvish.buffers'.buf_delete(<line1>, <line2>, "<bang>" == "!")]]

vim.cmd [[augroup neovim_firvish_buffer_local]]
vim.cmd [[autocmd! * <buffer>]]
vim.cmd [[autocmd BufEnter <buffer> lua require'firvish.buffers'.on_buf_enter()]]
vim.cmd [[autocmd BufDelete,BufWipeout <buffer> lua require'firvish.buffers'.on_buf_delete()]]
vim.cmd [[autocmd BufLeave <buffer> lua require'firvish.buffers'.on_buf_leave()]]
vim.cmd [[augroup END]]

if vim.fn.mapcheck("-", "n") ~= "" and
    vim.fn.hasmapto('<Plug>(dirvish_up)', 'n') == 1 then
    map("n", "-", ':edit firvish://<CR>', {silent = true, buffer = bufnr})
end

require'firvish.buffers'.open_buffers()

vim.b.did_firvish_buffers = true
