if exists("b:did_firvish")
  finish
endif

nmap <buffer> <silent> <enter> :lua require'firvish.buffers'.jump_to_buffer()<CR>

nmap <buffer> <silent> gq :lua require'firvish.buffers'.close_buffers()<CR>

nmap <buffer> <silent> fm :lua require'firvish.buffers'.filter_buffers("modified")<CR>
nmap <buffer> <silent> ft :lua require'firvish.buffers'.filter_buffers("current_tab")<CR>

nmap <buffer> <silent> <s-R> :lua require'firvish.buffers'.refresh_buffers()<CR>

let b:did_firvish = 1
