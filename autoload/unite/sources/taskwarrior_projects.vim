let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/projects',
      \ 'syntax': 'TaskWarrior'
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let candidates = []
  let projects = unite#taskwarrior#projects#select(a:args)
  for project in projects
    let line = call(unite#taskwarrior#config('project_formatter'), [project])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_project",
          \ "source__data": project
          \ })
  endfor
  return candidates
endfunction

function! unite#sources#taskwarrior_projects#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
