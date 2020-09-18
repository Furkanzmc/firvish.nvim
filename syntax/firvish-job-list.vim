if 'firvish-job-list' !=# get(b:, 'current_syntax', 'firvish-job-list')
  finish
endif

syntax match FirvishJobNr '^\[[0-9]\+\]'
syntax match FirvishJobTime '[0-9]\+:[0-9]\+:[0-9]\+'
syntax match FirvishJobQuickFix '\[QF\]'
syntax match FirvishJobBackground '\[B\]'
syntax match FirvishJobRunning '\[R\]'
syntax match FirvishJobFinished '\[F\]'
syntax match FirvishJobError '\[E:[1-9]\+\]'
syntax match FirvishJobNoError '\[E:[0-0]\]'
syntax match FirvishJobCommand '[a-zA]\+.*$'

highlight default link FirvishJobNr Number
highlight default link FirvishJobTime Delimiter
highlight default link FirvishJobQuickFix Define
highlight default link FirvishJobBackground Type
highlight default link FirvishJobRunning Operator
highlight default link FirvishJobFinished Label
highlight default link FirvishJobError ErrorMsg
highlight default link FirvishJobNoError Todo
highlight default link FirvishJobCommand String

let b:current_syntax = 'firvish-job-list'
