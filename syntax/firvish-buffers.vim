if 'firvish-buffers' !=# get(b:, 'current_syntax', 'firvish-buffers')
  finish
endif

syntax match FirvishBufNr '^\[[0-9]\+\]'

highlight default link FirvishBufNr Number

let b:current_syntax = 'firvish-buffers'
