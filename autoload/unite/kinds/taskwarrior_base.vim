let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_base',
      \ 'default_action' : 'open',
      \ 'action_table': {},
      \ 'is_selectable': 1,
      \ 'parents': ['common', 'openable'],
      \ }

let s:kind.action_table.previous  = {'description': 'open last unite buffer'}
function! s:kind.action_table.previous.func(candidate) abort
  let history = unite#sources#history_unite#define()
  let candidates = history.gather_candidates([], {})
  call history.action_table.start.func(candidates[0])
endfunction

function! unite#kinds#taskwarrior_base#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
