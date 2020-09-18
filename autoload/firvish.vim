function! s:msg_error(msg) abort
  redraw | echohl ErrorMsg | echomsg 'firvish:' a:msg | echohl None
endfunction
