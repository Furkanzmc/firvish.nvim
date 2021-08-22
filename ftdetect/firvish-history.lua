vim.cmd [[augroup firvish_history]]
vim.cmd [[au!]]
vim.cmd [[autocmd BufNewFile,BufRead firvish://history setlocal filetype=firvish-history]]
vim.cmd [[augroup END]]
