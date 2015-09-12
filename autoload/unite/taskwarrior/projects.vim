scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#projects#select(filt)
  let tasks = unite#taskwarrior#select(a:filt)
  let projects = {}

  for task in tasks
    let project = task.project
    if empty(project)
      let project = unite#taskwarrior#config('missing_project')
    endif

    let data =  get(projects, project, {'name': project, 'count': 0})
    let data.count += 1
    let projects[project] = data
  endfor

  return values(projects)
endfunction

function! unite#taskwarrior#projects#format(project, summary) abort
  let formatter = unite#taskwarrior#config('project_formatter')
  return call(formatter, [a:project, a:summary])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
