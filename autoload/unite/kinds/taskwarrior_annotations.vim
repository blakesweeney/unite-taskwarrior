let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_annotations',
      \ 'default_action' : 'edit',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

function! unite#kinds#taskwarrior_annotations#define()
  return s:kind
endfunction

let s:kind.action_table.edit = {
      \ 'description' : 'edit this annotation',
      \ 'is_selectable': 0,
      \ 'is_quit': 1
      \ }
function! s:kind.action_table.edit.func(candidate)
  call unite#taskwarrior#annotations#edit(a:candidate.__souce_data)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
