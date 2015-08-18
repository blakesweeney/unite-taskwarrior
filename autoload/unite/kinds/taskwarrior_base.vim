let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_base',
      \ 'default_action' : 'previous',
      \ 'action_table': {},
      \ }

let s:kind.action_table.previous  = {'description': 'open last unite buffer', 'is_selectable': 1}
function! s:kind.action_table.previous.func(candidates) abort
  let history = unite#sources#history_unite#define()
  let past = history.gather_candidates([], {})
  call history.action_table.start.func(past[0])
endfunction

function! unite#kinds#taskwarrior_base#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
