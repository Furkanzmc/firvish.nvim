if exists('g:loaded_firvish') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif

nnoremap <silent> <Plug>(firvish_buffers) :<C-U>lua require'firvish.buffers'.open_buffers()<CR>
nnoremap <silent> <Plug>(firvish_history) :<C-U>lua require'firvish.history'.open_history()<CR>

nmap <nowait> <leader>b <Plug>(firvish_buffers)
nmap <nowait> <leader>h <Plug>(firvish_history)

if executable("rg")
  command! -bang -complete=file -nargs=* Rg :lua require'firvish.job_control'.start_job({
        \ "rg",
        \ "--column",
        \ "--line-number",
        \ "--no-heading",
        \ "--vimgrep",
        \ "--color=never",
        \ "--smart-case",
        \ "--block-buffered",
        \ <f-args>,
        \ },
        \ "firvish-dir",
        \ "rg",
        \ "<bang>" == "!"
        \ )<CR>
endif

if executable("ugrep")
  command! -bang -complete=file -nargs=* Ug :lua require'firvish.job_control'.start_job({
        \ "ugrep",
        \ "--column-number",
        \ "--line-number",
        \ "--color=never",
        \ "--smart-case",
        \ "-J1",
        \ <f-args>,
        \ },
        \ "firvish-dir",
        \ "ugrep",
        \ "<bang>" == "!"
        \ )<CR>
endif

if executable("fd")
  command! -bang -complete=file -nargs=* Fd :lua require'firvish.job_control'.start_job({
        \ "fd",
        \ "--color=never",
        \ <f-args>,
        \ },
        \ "firvish-dir",
        \ "fd",
        \ "<bang>" == "!"
        \ )<CR>
endif

augroup neovim_firvish_buffer
  autocmd!
  autocmd BufDelete,BufWipeout,BufAdd * lua require'firvish.buffers'.mark_dirty()
augroup END

let g:loaded_firvish = 1
