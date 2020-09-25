if 'firvish' !=# get(b:, 'current_syntax', 'firvish')
  finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\\' : '/'

syntax match FirvishBufNr '^\[[0-9]\+\]'

highlight default link FirvishBufNr Number

let b:current_syntax = 'firvish'
