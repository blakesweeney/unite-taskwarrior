let s:save_cpo = &cpo
set cpo&vim

let s:kind = {
      \ 'name' : 'taskwarrior',
      \ 'default_action' : 'toggle',
      \ 'action_table': {},
      \ 'is_selectable': 1,
      \ 'parents': ['common', 'openable'],
      \ }

let s:kind.action_table.open = {'description' : 'open note', 'is_selectable': 0}
function! s:kind.action_table.open.func(candidate)
  call unite#taskwarrior#open(a:candidate.source__data)
endfunction

let s:kind.action_table.preview = {'description' : 'preview note', 'is_selectable': 0}
function! s:kind.action_table.preview.func(candidate)
  let todo = a:candidate.source__data
  if filereadable(todo.note)
    call unite#view#_preview_file(todo.note)
  endif
endfunction

let s:kind.action_table.edit = {'description' : 'edit description', 'is_selectable': 0}
function! s:kind.action_table.edit.func(candidate)
  let todo = a:candidate.source__data
  let prompt = 'Title: ' . todo.description . ': '
  let after = unite#taskwarrior#trim(input(prompt, todo.description))
  if !empty(after)
    let todo.description = after
    call unite#taskwarrior#rename(todo)
  endif
endfunction

let s:kind.action_table.edit_tag = {'description' : 'edit tags', 'is_selectable': 1}
function! s:kind.action_table.edit_tag.func(candidates)
  let tags = []
  for candidate in a:candidates
    call extend(tags, candidate.source__data.tags)
  endfor
  let tags = uniq(sort(tags))
  let before = join(tags, ' ')
  let prompt = 'Tags modifications (' . before . '): '
  let after = split(unite#taskwarrior#trim(input(prompt, before)))
  if !empty(after)
    for candidate in a:candidates
      let task = candidate.source__data
      call unite#taskwarrior#edit_tags(task, after)
    endfor
  endif
endfunction

let s:kind.action_table.edit_proj = {'description' : 'edit project', 'is_selectable': 1}
function! s:kind.action_table.edit_proj.func(candidates)
  let projs = []
  for candidate in a:candidates
    call add(projs, candidate.source__data.project)
  endfor
  let projs = uniq(projs)
  let before = join(projs, ',')
  let prompt = 'Project: ' . before . ': '
  if before == ''
    let prompt = 'Project: '
  endif
  let after = unite#taskwarrior#trim(input(prompt, before))
  if !empty(after)
    for candidate in a:candidates
      let task = candidate.source__data
      call unite#taskwarrior#project(task, after)
    endfor
  endif
endfunction

let s:kind.action_table.do = {'description' : 'complete task', 'is_selectable': 1}
function! s:kind.action_table.do.func(candidates)
  for candidate in a:candidates
    call unite#taskwarrior#do(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.delete = {'description' : 'delete task', 'is_selectable': 1}
function! s:kind.action_table.delete.func(candidates)
  for candidate in a:candidates
    call unite#taskwarrior#delete(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.toggle = { 'description' : 'toggle status', 'is_selectable': 1}
function! s:kind.action_table.toggle.func(candidates)
  for candidate in a:candidates
    call unite#taskwarrior#toggle(candidate.source__data)
  endfor
endfunction

let s:kind.action_table.modify = {'description': 'modify task', 'is_selectable': 1}
function! s:kind.action_table.modify.func(candidates)
  let raw = unite#taskwarrior#trim(input("Modify: "))
  for candidate in a:candidates
    call unite#taskwarrior#modify(candidate.source__data, raw)
  endfor
endfunction

let s:kind.action_table.annotate = {'description': 'annotate task', 'is_selectable': 1}
function! s:kind.action_table.annotate.func(candidates)
  let raw = unite#taskwarrior#trim(input("Annotate: "))
  for candidate in a:candidates
    call unite#taskwarrior#annotate(candidate.source__data, raw)
  endfor
endfunction

let s:kind.action_table.undo = {
      \ 'description': 'undo an action',
      \ 'is_selectable': 0,
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1}
function! s:kind.action_table.undo.func(candidate) abort
  return unite#taskwarrior#undo()
endfunction

let s:kind.action_table.start = {'description': 'start a task', 'is_selectable': 0}
function! s:kind.action_table.start.func(candidate)
  return unite#taskwarrior#start(a:candidate.source__data)
endfunction

let s:kind.action_table.stop = {'description': 'stop a task', 'is_selectable': 0}
function! s:kind.action_table.stop.func(candidate)
  return unite#taskwarrior#stop(a:candidate.source__data)
endfunction

let s:kind.action_table.yank_id = {'description': 'yank a task uuid', 'is_selectable': 0, 'is_quit': 1}
function! s:kind.action_table.yank_id.func(candidate)
  return unite#taskwarrior#yank(a:candidate.source__data, 'id')
endfunction

let s:kind.action_table.yank_uri = {'description': 'yank a task uri', 'is_selectable': 0, 'is_quit': 1}
function! s:kind.action_table.yank_uri.func(candidate)
  return unite#taskwarrior#yank(a:candidate.source__data, 'uri')
endfunction

let s:kind.action_table.view = {'description': 'view a task', 'is_selectable': 0}
function! s:kind.action_table.view.func(candidate)
  let task = a:candidate.source__data
  echo unite#taskwarrior#run(task, 'information')
endfunction

let s:parent_kind = {
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }

call extend(s:kind.action_table.do, s:parent_kind, 'error')
call extend(s:kind.action_table.delete, s:parent_kind, 'error')
call extend(s:kind.action_table.toggle, s:parent_kind, 'error')
call extend(s:kind.action_table.preview, s:parent_kind, 'error')
call extend(s:kind.action_table.edit_tag, s:parent_kind, 'error')

function! unite#kinds#taskwarrior#define()
  return s:kind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
