let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_context',
      \ 'default_action' : 'use',
      \ 'action_table': {},
      \ }

let s:kind.action_table.use = {'description': 'set and show the given context'}
function! s:kind.action_table.use.func(candidate)
  call unite#taskwarrior#context#set(a:candidate.source__data)
  let filter = unite#taskwarrior#context#filter(a:candidate.source__data)
  call unite#start([['taskwarrior']], {'custom_filter': filter})
endfunction

let s:kind.action_table.rename = {'description' : 'rename a context'}
function! s:kind.action_table.rename.func(candidate)
  if a:candidate.name == 'none'
    return 0
  endif
  let name = a:candidate.source__data.name
  let name = unite#taskwarrior#trim(input("Name (" . name . "): ", name))
  call unite#taskwarrior#context#rename(name, a:candidate.source__data)
endfunction

let s:kind.action_table.edit = {'description' : 'edit definition of a context'}
function! s:kind.action_table.edit.func(candidate)
  if a:candidate.name == 'none'
    return 0
  endif
  let def = a:candidate.source__data.definition
  let def = unite#taskwarrior#trim(input("Definition (" . def . "): ", def))
  call unite#taskwarrior#context#define(a:candidate.source__data.name, def)
endfunction

let s:kind.action_table.delete = {'description' : 'delete a context'}
function! s:kind.action_table.delete.func(candidate)
  if a:candidate.name == 'none'
    return 0
  endif
  call unite#taskwarrior#context#delete(a:candidate.source__data)
endfunction

function! unite#kinds#taskwarrior_context#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
