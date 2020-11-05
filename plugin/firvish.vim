if exists('g:loaded_firvish') || &cp || v:version < 700 || &cpo =~# 'C'
  finish
endif

nnoremap <silent> <Plug>(firvish_buffers) :<C-U>lua require'firvish.buffers'.open_buffers()<CR>
nnoremap <silent> <Plug>(firvish_history) :<C-U>lua require'firvish.history'.open_history()<CR>

nmap <nowait> <leader>b <Plug>(firvish_buffers)
nmap <nowait> <leader>h <Plug>(firvish_history)

if !exists("g:firvish_shell")
  let g:firvish_shell = &shell
endif

if !exists("g:firvish_interactive_window_height")
  let g:firvish_interactive_window_height = 3
endif

if executable("rg")
  command! -bang -complete=file -nargs=* Rg call luaeval('require"firvish.job_control".start_job({
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
        \ "<bang>" == "!",
        \ false,
        \ false
        \ )') | let b:firvish_repeat_job_command="Rg!"
endif

if executable("ugrep")
  command! -bang -complete=file -nargs=* Ug call luaeval('require"firvish.job_control".start_job({
        \ "ugrep",
        \ "--column-number",
        \ "--line-number",
        \ "--color=never",
        \ "--smart-case",
        \ "--line-buffered",
        \ "-J1",
        \ <f-args>,
        \ },
        \ "firvish-dir",
        \ "ugrep",
        \ "<bang>" == "!",
        \ false,
        \ false
        \ )') | let b:firvish_repeat_job_command="Ug!"
endif

if executable("fd")
  command! -bang -complete=file -nargs=* Fd call luaeval('require"firvish.job_control".start_job({
        \ "fd",
        \ "--color=never",
        \ <f-args>,
        \ },
        \ "firvish-dir",
        \ "fd",
        \ "<bang>" == "!",
        \ false,
        \ false
        \ )') | let b:firvish_repeat_job_command="Fd!"
endif

command! -bang -complete=shellcmd -nargs=* FRun
                  \ call luaeval('require"firvish.job_control".start_job({
                  \     <f-args>,
                  \ },
                  \ "firvish-job",
                  \ "job",
                  \ false,
                  \ "<bang>" == "!",
                  \ true
                  \ )')

command! -nargs=* -complete=shellcmd -range -bang Fhdo
                  \ lua require'firvish'.open_linedo_buffer(
                  \     <line1>, <line2>, vim.fn.bufnr(), <q-args>)

command! FirvishJobs lua require'firvish.job_control'.list_jobs()

augroup neovim_firvish_buffer
  autocmd!
  autocmd BufDelete,BufWipeout,BufAdd * lua require'firvish.buffers'.mark_dirty()
augroup END

let g:loaded_firvish = 1
