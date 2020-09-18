if 'firvish' !=# get(b:, 'current_syntax', 'firvish')
  finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\\' : '/'

syntax match firvishBufNr '^\[[0-9]\+\]'
exe 'syntax match firvishPathHead =.*' . s:sep . '\ze[^' . s:sep . ']\+' . s:sep . '\?$= conceal' . ' contains=firvishBufNr'

highlight default link firvishBufNr Number

let b:current_syntax = 'firvish'
