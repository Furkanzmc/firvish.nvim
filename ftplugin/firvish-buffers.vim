if exists("b:did_firvish")
  finish
endif

nmap <buffer> <silent> <enter> :lua require'firvish.buffers'.jump_to_buffer()<CR>

nmap <buffer> <silent> gq :lua require'firvish.buffers'.close_buffers()<CR>

nmap <buffer> <silent> fm :lua require'firvish.buffers'.filter_buffers("modified")<CR>
nmap <buffer> <silent> ft :lua require'firvish.buffers'.filter_buffers("current_tab")<CR>

nmap <buffer> <silent> <s-R> :lua require'firvish.buffers'.refresh_buffers()<CR>

command! -buffer -nargs=* -range Bufdo :lua require'firvish.buffers'.buf_do(<line1>, <line2>, <q-args>)
command! -buffer -nargs=* -range Bdelete :lua require'firvish.buffers'.buf_delete(<line1>, <line2>)

let b:did_firvish = 1
