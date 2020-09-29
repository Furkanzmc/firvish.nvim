function firvish#open_file_under_cursor(nav_direction, preview, reuse_window, vertical)
  if a:reuse_window
    let l:current_winnr = winnr()
    wincmd l
    if winnr() != l:current_winnr
      normal q
    endif
  endif

  if a:vertical
    vertical normal ^F
  else
    normal ^F
  endif

  if a:preview
    wincmd p
  endif

  if a:nav_direction == "down"
    normal j
  elseif a:nav_direction == "up"
    normal k
  endif
endfunction

