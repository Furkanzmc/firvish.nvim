if 'firvish_dir' !=# get(b:, 'current_syntax', 'firvish_dir')
  finish
endif

execute 'syntax region FirvishDirPath start="^[aA-zZ]" end="[\.]\w\+"'
syntax match FirvishJobMessage "^\[firvish\] \w\+.*$"

highlight default link FirvishDirPath Directory
highlight default link FirvishJobMessage Comment

let b:current_syntax = 'firvish_dir'
