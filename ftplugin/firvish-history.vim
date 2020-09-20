if exists("b:firvish_history")
  finish
endif

nmap <buffer> <silent> <enter> :lua require'firvish.history'.open_file()<CR>

nmap <buffer> <silent> gq :lua require'firvish.history'.close_history()<CR>

nmap <buffer> <silent> <s-R> :lua require'firvish.buffers'.refresh_history()<CR>

let b:firvish_history = 1
