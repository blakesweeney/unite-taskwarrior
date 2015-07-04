let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_cmd',
      \ 'default_action' : 'execute',
      \ 'action_table': {},
      \ }

let s:kind.action_table.execute = {
      \ 'description' : 'execute command',
      \ 'is_selectable': 1,
      \ 'is_quit': 1
      \ }

function! s:kind.action_table.execute.func(candidates)
  for candidate in a:candidates
    let args = ['']
    call extend(args, split(candidate.word))
    echo call('unite#taskwarrior#call', args)
  endfor
endfunction

function! unite#kinds#taskwarrior_cmd#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
