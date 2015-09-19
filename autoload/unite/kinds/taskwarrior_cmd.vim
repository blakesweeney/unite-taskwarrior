let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior/cmd',
      \ 'default_action' : 'execute',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.execute = {
      \ 'description' : 'execute command',
      \ 'is_selectable': 1,
      \ 'is_quit': 1
      \ }

function! s:kind.action_table.execute.func(candidates)
  for candidate in a:candidates
    echo unite#taskwarrior#call(candidate.word)
  endfor
endfunction

function! unite#kinds#taskwarrior_cmd#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
