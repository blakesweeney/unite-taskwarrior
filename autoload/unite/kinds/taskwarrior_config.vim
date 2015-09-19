let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior/config',
      \ 'default_action' : 'edit',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.edit = {
      \ 'description': 'edit a value', 
      \ 'is_selectable': 0,
      \ 'is_quit': 0, 
      \ 'is_invalidate_cache': 1
      \ }
function! s:kind.action_table.edit.func(candidate)
  let current = a:candidate.source__data.value
  let raw = unite#taskwarrior#trim(input('Value (' . current . '): ', current))
  let name = a:candidate.source__data.name
  let value = type(current) == type(0) ? str2nr(raw) : raw
  call unite#taskwarrior#config#set(name, value)
endfunction

let s:kind.action_table.reset = {
      \ 'description': 'reset value to default', 
      \ 'is_selectable': 1,
      \ 'is_quit': 0, 
      \ 'is_invalidate_cache': 1
      \ }
function! s:kind.action_table.reset.func(candidates) abort
  for candidate in a:candidates
    call unite#taskwarrior#config#reset(candidate.source__data.name)
  endfor
endfunction

function! unite#kinds#taskwarrior_config#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
