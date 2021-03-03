if exists("b:firvish_job_output")
  finish
endif

function! s:go_back()
    if exists("b:firvish_job_list_linenr")
        let l:bufnr = b:firvish_job_list_linenr
        execute "FirvishJobs"
        wincmd P
        execute "normal " . l:bufnr . "G"
    else
        execute "FirvishJobs"
    endif
endfunction

nmap <buffer> <silent> gb :call <SID>go_back()<CR>
nmap <buffer> <silent> gq :pclose<CR>

let b:firvish_job_output = 1
