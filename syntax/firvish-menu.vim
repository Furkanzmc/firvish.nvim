if 'firvish' !=# get(b:, 'current_syntax', 'firvish')
  finish
endif

syntax match FirvishMenuItemPoint '\*'
syntax match FirvishMenuItem '\w\+\(\ \|$\)'
syntax match FirvishMenuItemNumber '\[[0-9]\+\]'

highlight default link FirvishMenuItemPoint Delimiter
highlight default link FirvishMenuItem Directory
highlight default link FirvishMenuItemNumber Number

let b:current_syntax = 'firvish'
