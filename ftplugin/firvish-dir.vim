if exists("b:did_firvish")
  finish
endif

nmap <buffer> <silent> a <cmd>call firvish#open_file_under_cursor("", v:true, v:false, v:true)<CR>
nmap <buffer> <silent> o <cmd>call firvish#open_file_under_cursor("", v:true, v:false, v:false)<CR>

nmap <buffer> <silent> P <cmd>call firvish#open_file_under_cursor("", v:true, v:true, v:true)<CR>
nmap <buffer> <silent> <C-N> <cmd>call firvish#open_file_under_cursor("down", v:true, v:true, v:true)<CR>
nmap <buffer> <silent> <C-P> <cmd>call firvish#open_file_under_cursor("up", v:true, v:true, v:true)<CR>

function s:repeat_command(command)
  if mode() != "i"
    return
  endif

  if !empty(getline(line(".")))
    if exists("b:firvish_job_id")
      call jobstop(b:firvish_job_id)
    endif

    execute a:command . " " . substitute(getline(line(".")), " ", "\\\\ ", "g")
  endif
endfunction

function s:start_interactive(command)
  execute "normal " . g:firvish_interactive_window_height . ""

  file "firvish [interactive]"

  setlocal filetype=firvish-interactive

  execute "augroup ftp_firvish_" . bufnr(0)
    au!

    execute 'autocmd TextChangedI <buffer> call <SID>repeat_command("' . a:command . '")'
    autocmd BufLeave <buffer> bd!
  augroup END

  startinsert
endfunction

nmap <buffer> <silent> I <cmd>call <SID>start_interactive(b:firvish_job_command)<CR>

let b:did_firvish = 1
