let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/projects',
      \ 'description': 'Show a listing of know projects',
      \ 'syntax': 'TaskWarrior',
      \ 'sorters': 'sorter_count'
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let candidates = []
  let projects = unite#taskwarrior#projects#select(a:args)
  let summary = unite#taskwarrior#formatters#size_summary(projects)
  for project in projects
    let line = unite#taskwarrior#projects#format(project, summary)
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
