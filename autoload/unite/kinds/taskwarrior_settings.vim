let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_settings',
      \ 'default_action' : 'open',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.unset = {'description': 'sets value to defeault', 'is_selectable': 1}
function! s:kind.action_table.unset.func(candidates)
  for candidate in a:candidates
    call unite#taskwarrior#unset(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.delete = {'description': 'set value to ""', 'is_selectable': 1}
function! s:kind.action_table.delete.func(candidates) abort
  for candidate in a:candidates
    call unite#taskwarrior#delete(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.set = {'description': 'Set config value'}
function! s:kind.action_table.func(candidate) abort
  let setting = a:candidate.source__data
  let value = input("Value ( ". setting.value . " ): ", setting.value)
  let value = unite#taskwarrior#trim(value)
  call unite#taskwarrior#settings#set(setting, value)
endfunction

function! unite#kinds#taskwarrior_settings#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
