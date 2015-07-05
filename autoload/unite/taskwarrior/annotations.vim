scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#annotations#groups(args) abort
  let filter = unite#taskwarrior#filter(a:args, '')
  let tasks = unite#taskwarrior#select(filter)
  let annotations = {}

  for task in tasks
    for annotation in get(task, 'annotations', [])
      let key = annotation.entry
      let data =  get(annotations, key,
            \ {'description': annotation.description, 'tasks': []})
      call add(data.tasks, task)
      let annotations[key] = data
    endfor
  endfor

  return values(annotations)
endfunction

function! unite#taskwarrior#annotations#edit(annotation) abort
  let new_description = ''
  call unite#taskwarrior#annotations#update(a:annotation, new_description)
endfunction

function! unite#taskwarrior#annotations#update(annotation, new_description) abort
  let uuids = map(a:annotation.tasks, 'v:val.uuid')
  call unite#taskwarrior#call(uuids, "denote", a:annotation.description)
  call unite#taskwarrior#call(uuids, "annotate", a:new_description)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
