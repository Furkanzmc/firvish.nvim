if exists("b:firvish_job_list")
  finish
endif

augroup firvish_job_list_preview
    autocmd! * <buffer>
    autocmd BufDelete,WinClosed <buffer> lua require'firvish.job_control'.on_preview_buf_delete()
augroup END

nmap <buffer> <silent> <S-r> :lua require'firvish.job_control'.refresh_job_preview_window()<CR>
nmap <buffer> <silent> dd :lua require'firvish.job_control'.delete_job_from_history(false)<CR>
nmap <buffer> <silent> DD :lua require'firvish.job_control'.delete_job_from_history(true)<CR>
nmap <buffer> <silent> S :lua require'firvish.job_control'.stop_job()<CR>
nmap <buffer> <silent> <S-p> :execute "lua require'firvish.job_control'.preview_job_output("
            \ . b:firvish_job_list_additional_lines[line(".") - 1].job_id . ")"<CR>

let b:firvish_job_list = 1
