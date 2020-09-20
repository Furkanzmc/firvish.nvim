if exists('g:loaded_firvish') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif

nnoremap <silent> <Plug>(firvish_buffers) :<C-U>lua require'firvish.buffers'.open_buffers()<CR>
nnoremap <silent> <Plug>(firvish_history) :<C-U>lua require'firvish.history'.open_history()<CR>

nmap <nowait> <leader>b <Plug>(firvish_buffers)
nmap <nowait> <leader>h <Plug>(firvish_history)

command! -bang -nargs=* Rg :lua require'firvish.job_control'.start_job({
      \ "rg",
      \ "--column",
      \ "--line-number",
      \ "--no-heading",
      \ "--color=never",
      \ "--smart-case",
      \ "--vimgrep",
      \ <f-args>,
      \ },
      \ "firvish-dir"
      \ )<CR>

command! -bang -nargs=* Fd :lua require'firvish.job_control'.start_job({
      \ "fd",
      \ "--color=never",
      \ <f-args>,
      \ },
      \ "firvish-dir"
      \ )<CR>

let g:loaded_firvish = 1
