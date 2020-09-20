if 'firvish_dir' !=# get(b:, 'current_syntax', 'firvish_dir')
  finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\\' : '/'
let s:escape = 'substitute(escape(v:val, ".$~"), "*", ".*", "g")'

exe 'syntax match FirvishPathHead =.*'.s:sep.'\ze[^'.s:sep.']\+'.s:sep.'\?$= conceal'
exe 'syntax match FirvishPathTail =[^'.s:sep.']\+'.s:sep.'$='
exe 'syntax match FirvishSuffix   =[^'.s:sep.']*\%('.join(map(split(&suffixes, ','), s:escape), '\|') . '\)$='

highlight default link FirvishSuffix   SpecialKey
highlight default link FirvishPathTail Directory
highlight default link FirvishArg      Todo

let b:current_syntax = 'firvish_dir'
