if 'firvish-buffers' !=# get(b:, 'current_syntax', 'firvish-buffers')
  finish
endif

let s:sep = exists('+shellslash') && !&shellslash ? '\\' : '/'

syntax match FirvishBufNr '^\[[0-9]\+\]'

for s:p in argv()
  exe 'syntax match FirvishArg ,' . escape(fnamemodify(s:p, ':p:~:.'), '[,*.^$~\') . '$, contains=FirvishBufNr'
endfor

highlight default link FirvishBufNr Number
highlight default link FirvishArg Todo

let b:current_syntax = 'firvish-buffers'
