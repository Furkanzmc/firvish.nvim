if exists('g:loaded_firvish') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif

nnoremap <silent> <Plug>(firvish_open) :<C-U>lua require'firvish'.open_buffer_list()<CR>
nmap <nowait> <leader>b <Plug>(firvish_open)

let g:loaded_firvish = 1
