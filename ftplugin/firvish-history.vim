if exists("b:did_firvish_history")
  finish
endif

setlocal cursorline
setlocal modifiable
setlocal nobuflisted
setlocal syntax=firvish-buffers
setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal noswapfile

nmap <buffer> <silent> <enter> :lua require'firvish.history'.open_file()<CR>
nmap <buffer> <silent> gq :lua require'firvish.history'.close_history()<CR>
nmap <buffer> <silent> <s-R> :lua require'firvish.history'.refresh_history()<CR>

lua << EOF
  require'firvish'.configure_buffer_preview_keymaps()
  require'firvish.history'.open_history()
EOF

augroup neovim_firvish_history
    autocmd! * <buffer>
    autocmd BufEnter <buffer> lua require'firvish.history'.open_history()
    autocmd BufDelete <buffer> lua require'firvish.history'.on_buf_delete()
    autocmd BufWipeout <buffer> lua require'firvish.history'.on_buf_delete()
    autocmd BufLeave <buffer> lua require'firvish.history'.on_buf_leave()
augroup END

if mapcheck("-", "n") != "" && hasmapto('<Plug>(dirvish_up)', 'n')
  nmap <silent> <buffer> - :edit firvish://<CR>
endif

let b:did_firvish_history = 1
