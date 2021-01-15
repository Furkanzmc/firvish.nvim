if exists("b:did_firvish_buffers")
  finish
endif

setlocal cursorline
setlocal modifiable
setlocal buflisted
setlocal syntax=firvish-buffers
setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal noswapfile

nmap <buffer> <silent> <enter> :lua require'firvish.buffers'.jump_to_buffer()<CR>
nmap <buffer> <silent> fm :lua require'firvish.buffers'.filter_buffers("modified")<CR>

nmap <buffer> <silent> ft :lua require'firvish.buffers'.filter_buffers("current_tab")<CR>
nmap <buffer> <silent> fa :lua require'firvish.buffers'.filter_buffers("args")<CR>
nmap <buffer> <silent> <s-R> :lua require'firvish.buffers'.refresh_buffers()<CR>

command! -buffer -nargs=* -range Bufdo :lua require'firvish.buffers'.buf_do(<line1>, <line2>, <q-args>)
command! -buffer -bang -nargs=* -range Bdelete :lua require'firvish.buffers'.buf_delete(<line1>, <line2>, "<bang>" == "!")

augroup neovim_firvish_buffer_local
    autocmd! * <buffer>
    autocmd BufEnter <buffer> lua require'firvish.buffers'.on_buf_enter()
    autocmd BufWinEnter <buffer> file firvish-buffers
    autocmd BufDelete,BufWipeout,BufUnload <buffer> lua require'firvish.buffers'.on_buf_delete()
    autocmd BufLeave <buffer> lua require'firvish.buffers'.on_buf_leave()
augroup END

lua require'firvish.buffers'.open_buffers()

let b:did_firvish_buffers = 1
