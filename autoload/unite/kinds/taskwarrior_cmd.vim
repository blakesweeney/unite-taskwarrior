let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior/cmd',
      \ 'default_action' : 'execute',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.execute = {
      \ 'description': 'execute command',
      \ 'is_quit': 1
      \ }
function! s:kind.action_table.execute.func(candidate)
  call unite#taskwarrior#show_result('unite#taskwarrior#call',
        \ [a:candidate.word])
endfunction

function! unite#kinds#taskwarrior_cmd#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
