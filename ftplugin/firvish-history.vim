if exists("b:firvish_history")
  finish
endif

nmap <buffer> <silent> <enter> :lua require'firvish.history'.open_file()<CR>
nmap <buffer> <silent> gq :lua require'firvish.history'.close_history()<CR>
nmap <buffer> <silent> <s-R> :lua require'firvish.history'.refresh_history()<CR>

lua << EOF
  require'firvish'.configure_common_commands()
  require'firvish'.configure_file_open_commands()
EOF

let b:firvish_history = 1
