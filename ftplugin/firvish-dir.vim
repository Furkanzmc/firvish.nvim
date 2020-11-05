if exists("b:did_firvish")
  finish
endif

lua << EOF
  require'firvish'.configure_common_commands()
  require'firvish'.configure_buffer_preview_keymaps()
EOF

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

nmap <buffer> <silent> I <cmd>call <SID>start_interactive(b:firvish_repeat_job_command)<CR>

let b:did_firvish = 1
