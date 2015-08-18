let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior_project',
      \ 'default_action' : 'open',
      \ 'action_table': {},
      \ 'parents': ['taskwarrior_base'],
      \ }

let s:kind.action_table.open = {
      \ 'description' : 'show all asks for the given project(s)',
      \ 'is_selectable': 1
      \ }

function! s:kind.action_table.open.func(candidates)
  let args = ['taskwarrior']
  for candidate in a:candidates
    let query =  '$' . candidate.source__data.name
    if candidate.source__data.name == unite#taskwarrior#config('missing_project')
      let query = '$'
    endif
    call add(args, query)
  endfor
  call unite#start([args])
endfunction

let s:kind.action_table.rename = {
      \ 'description' : 'rename a project',
      \ }

function! s:kind.action_table.rename.func(candidate)
  let name = a:candidate.name
  let filter = unite#taskwarrior#projects#expand(name)
  let name = unite#taskwarrior#trim(input("Name ( " . name . "): ", name))
  let proj = unite#taskwarrior#projects#expand(name)
  call unite#taskwarrior#call([filter, "modify", proj])
endfunction

function! unite#kinds#taskwarrior_project#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
