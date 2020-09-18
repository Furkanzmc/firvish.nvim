if exists("b:did_firvish")
  finish
endif

nmap <buffer> <silent> <enter> :lua require'firvish'.jump_to_buffer()<CR>

nmap <buffer> <silent> gq :lua require'firvish'.firvish_close()<CR>
nmap <buffer> <silent> <s-R> :lua require'firvish'.refresh_buffer_list()<CR>

let b:did_firvish = 1
