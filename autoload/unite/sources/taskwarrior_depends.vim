let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/depends',
      \ 'sorters': 'sorter_task_urgency',
      \ 'default_action': 'depends',
      \ 'action_table': {}
      \ }

let s:taskwarrior = unite#sources#taskwarrior#define()

function! s:filter(uuids)
  let raw = unite#taskwarrior#call([join(a:uuids, ','), '_projects'])
  let projects = uniq(sort(split(raw, '\n')))
  return map(projects, '"$" . v:val')
endfunction

function! s:source.gather_candidates(args, context)
  if empty(a:args)
    return []
  endif

  let filter = s:filter(a:args)
  let candidates = s:taskwarrior.gather_candidates(filter, a:context)
  for candidate in candidates
    let candidate['source__parent'] = a:args
  endfor

  return candidates
endfunction

let s:source.action_table.depends = {
      \ 'description': 'modify dependencies of a task',
      \ 'is_selectable': 1
      \ }
function! s:source.action_table.depends.func(candidates)
  for candidate in a:candidates
    let task = candidate.source__data
    call unite#taskwarrior#depends(task, candidate.source__parent)
  endfor
endfunction

function! unite#sources#taskwarrior_depends#define() abort
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
