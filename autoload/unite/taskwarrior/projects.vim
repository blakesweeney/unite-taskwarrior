scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#projects#select(args)
  let filter = unite#taskwarrior#filter(a:args, '')
  let tasks = unite#taskwarrior#select(filter)
  let projects = {}

  for task in tasks
    let project = task.project
    if empty(project)
      let project = g:unite_taskwarrior_missing_project
    endif

    let data =  get(projects, project, {'name': project, 'count': 0})
    let data.count += 1
    let projects[project] = data
  endfor

  return values(projects)
endfunction

function! unite#taskwarrior#projects#format(project)
  return printf(g:unite_taskwarrior_project_format_string, 
        \ a:project.name,
        \ a:project.count)
endfunction

function! unite#taskwarrior#projects#abbr(data)
  if a:data == ''
    return ''
  endif
  if type(a:data) == type('')
    return g:unite_taskwarrior_projects_abbr . a:data
  endif
  return g:unite_taskwarrior_projects_abbr . a:data.name
endfunction

function! unite#taskwarrior#projects#expand(short)
  if strpart(a:short, 0, 1) == g:unite_taskwarrior_projects_abbr
    return 'project:' . strpart(a:short, 1, -1)
  endif
  return 'project:' . a:short
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
