scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#projects#select(args)
  let filter = unite#taskwarrior#filter(a:args)
  let tasks = unite#taskwarrior#select(filter)
  let projects = {}

  for task in tasks
    let project = task.project
    if empty(project)
      continue
    endif

    let data =  get(projects, project, {'name': project, 'count': 0})
    let data.count += 1
    let projects[project] = data
  endfor

  return values(projects)
endfunction

function! unite#taskwarrior#projects#format(project)
  return '$' . a:project.name
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
