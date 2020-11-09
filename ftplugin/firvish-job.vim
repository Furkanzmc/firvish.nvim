if exists("b:firvish_job")
  finish
endif

setlocal cursorline

lua << EOF
  require'firvish'.configure_buffer_preview_keymaps()
EOF

let b:firvish_job = 1
