let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior/show',
      \ 'default_action' : 'edit',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.edit = {'description': 'edit a value', 'is_selectable': 0,
      \ 'is_quit': 0, 'is_invalidate_cache': 1}
function! s:kind.action_table.edit.func(candidate)
  let current = a:candidate.source__data.value
  let value = unite#taskwarrior#trim(input('Value (' . current . '): ', current))
  call unite#taskwarrior#settings#set(a:candidate.source__data, value)
endfunction

let s:kind.action_table.unset = {'description': 'sets value to defeault', 'is_selectable': 1}
function! s:kind.action_table.unset.func(candidates)
  for candidate in a:candidates
    call unite#taskwarrior#settings#unset(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.delete = {'description': 'set value to ""', 'is_selectable': 1}
function! s:kind.action_table.delete.func(candidates) abort
  for candidate in a:candidates
    call unite#taskwarrior#settings#delete(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.set = {'description': 'Set config value'}
function! s:kind.action_table.set.func(candidate) abort
  let setting = a:candidate.source__data
  let value = input("Value ( ". setting.value . " ): ", setting.value)
  let value = unite#taskwarrior#trim(value)
  call unite#taskwarrior#settings#set(setting, value)
endfunction

function! unite#kinds#taskwarrior_show#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
