if 'firvish' !=# get(b:, 'current_syntax', 'firvish')
  finish
endif

lua << EOF
  require'firvish.syntax'.set_common_syntax()
EOF

let b:current_syntax = 'firvish'
