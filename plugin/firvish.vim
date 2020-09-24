if exists('g:loaded_firvish') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif

nnoremap <silent> <Plug>(firvish_buffers) :<C-U>lua require'firvish.buffers'.open_buffers()<CR>
nnoremap <silent> <Plug>(firvish_history) :<C-U>lua require'firvish.history'.open_history()<CR>

nmap <nowait> <leader>b <Plug>(firvish_buffers)
nmap <nowait> <leader>h <Plug>(firvish_history)

command! -complete=file -nargs=* Rg :lua require'firvish.job_control'.start_job({
      \ "rg",
      \ "--column",
      \ "--line-number",
      \ "--no-heading",
      \ "--vimgrep",
      \ "--color=never",
      \ "--smart-case",
      \ "--vimgrep",
      \ <f-args>,
      \ },
      \ "firvish-dir",
      \ "rg"
      \ )<CR>

command! -complete=file -nargs=* Fd :lua require'firvish.job_control'.start_job({
      \ "fd",
      \ "--color=never",
      \ <f-args>,
      \ },
      \ "firvish-dir",
      \ "fd"
      \ )<CR>

augroup neovim_firvish_buffer
  autocmd!
  autocmd BufDelete,BufWipeout,BufAdd * lua require'firvish.buffers'.mark_dirty()
augroup END

let g:loaded_firvish = 1
