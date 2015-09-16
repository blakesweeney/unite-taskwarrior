let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior/notes',
      \ 'default_action' : 'open',
      \ 'action_table': {},
      \ 'parents': ['common', 'file', 'taskwarrior_base'],
      \ }

function! unite#kinds#taskwarrior_notes#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
