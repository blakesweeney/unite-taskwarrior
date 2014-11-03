let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior',
      \ 'syntax': 'TaskWarrior'
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)

  let idx = index(a:args, 'tags')
  if idx >= 0
    let data = remove(a:args, idx, -1)
    return s:tag_source(data)
  endif

  let idx = index(a:args, 'projects')
  if idx >= 0
    let data = remove(a:args, idx, -1)
    return s:project_source(data)
  endif

  return s:task_source(a:args, a:context)
endfunction

function! s:project_source(raw)
  let candidates = []
  let projects = unite#taskwarrior#projects#select(a:raw)
  for project in projects
    let line = call(g:unite_taskwarrior_project_formatter, [project])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_project",
          \ "source__data": project
          \ })
  endfor
  return candidates
endfunction

function! s:tag_source(raw)
  let candidates = []
  let tags = unite#taskwarrior#tags#select(a:raw)
  for tag in tags
    let line = call(g:unite_taskwarrior_tag_formatter, [tag])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_tag",
          \ "source__data": tag
          \ })
  endfor
  return candidates
endfunction

function! s:task_source(args, context)
  let candidates = []
  let filter = unite#taskwarrior#filter(a:args)
  let loaded = unite#taskwarrior#select(filter)
  for todo in loaded
    let line = call(g:unite_taskwarrior_formatter, [todo])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior",
          \ "source__data": todo,
          \ })
    unlet todo
  endfor
  return candidates
endfunction

let s:source_cmd = {
      \ 'name': 'taskwarrior/cmd',
      \ 'default_kind': 'taskwarrior_cmd'
      \ }

function! s:source_cmd.change_candidates(args, context)
  return [{"word": a:context.input}]
endfunction

function! unite#sources#taskwarrior#define()
  return [s:source, s:source_cmd]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
