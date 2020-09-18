if exists('g:loaded_firvish') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif

nnoremap <silent> <Plug>(firvish_buffers) :<C-U>lua require'firvish.buffers'.open_buffers()<CR>
nmap <nowait> <leader>b <Plug>(firvish_buffers)

command! -bang -nargs=* Rg :lua require'firvish.job_control'.start_job({
      \ "rg",
      \ "--column",
      \ "--line-number",
      \ "--no-heading",
      \ "--color=never",
      \ "--smart-case",
      \ "--vimgrep",
      \ "--",
      \ <q-args>,
      \ },
      \ "firvish_dir"
      \ )<CR>

command! -bang -nargs=* Fd :lua require'firvish.job_control'.start_job({
      \ "fd",
      \ "--color=never",
      \ "--",
      \ <q-args>,
      \ },
      \ "firvish_dir"
      \ )<CR>

let g:loaded_firvish = 1
