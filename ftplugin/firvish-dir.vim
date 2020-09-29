if exists("b:did_firvish")
  finish
endif

nmap <buffer> <silent> a <cmd>call firvish#open_file_under_cursor("", v:true, v:false, v:true)<CR>
nmap <buffer> <silent> o <cmd>call firvish#open_file_under_cursor("", v:true, v:false, v:false)<CR>

nmap <buffer> <silent> <C-N> <cmd>call firvish#open_file_under_cursor("down", v:true, v:true, v:true)<CR>
nmap <buffer> <silent> <C-P> <cmd>call firvish#open_file_under_cursor("up", v:true, v:true, v:true)<CR>

let b:did_firvish = 1
