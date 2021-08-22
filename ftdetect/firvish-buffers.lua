vim.cmd [[augroup firvish_buffers]]
vim.cmd [[au!]]
vim.cmd [[autocmd BufNewFile,BufRead firvish://buffers setlocal filetype=firvish-buffers]]
vim.cmd [[augroup END]]
