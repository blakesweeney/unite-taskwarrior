let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_tag',
      \ 'default_action' : 'open',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.open = {
      \ 'description' : 'show all asks with this tag(s)',
      \ 'is_selectable': 1,
      \ 'is_quit': 1
      \ }

function! s:kind.action_table.open.func(candidates)
  let args = ['taskwarrior']
  for candidate in a:candidates
    call add(args, '@' . candidate.source__data.name)
  endfor
  call unite#start([args])
endfunction

let s:kind.action_table.rename = {
      \ 'description' : 'rename a tag',
      \ }

function! s:kind.action_table.rename.func(candidate)
  let name = a:candidate.name
  let filter = unite#taskwarrior#tags#expand(name)
  let tag = unite#taskwarrior#trim(input("Name ( " . name . "): ", name))
  call unite#taskwarrior#call([filter, "modify", "+" . tag, "-" . name])
endfunction

function! unite#kinds#taskwarrior_tag#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
