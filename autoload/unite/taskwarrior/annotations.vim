scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#annotations#groups(filt) abort
  let tasks = unite#taskwarrior#select(a:filt)
  let annotations = {}
  let method = unite#taskwarrior#config('group_annotations_by')
  let group = ''
  if method == 'content'
    let grouper = 'unite#taskwarrior#annotations#content'
  elseif method == 'time'
    let grouper = 'unite#taskwarrior#annotations#time'
  else
    echoerr "Unknown grouping method"
  endif

  for task in tasks
    for annotation in get(task, 'annotations', [])
      let key = call(grouper, [annotation])
      let data =  get(annotations, key,
            \ {'description': annotation.description, 'tasks': []})
      call add(data.tasks, task)
      let annotations[key] = data
    endfor
  endfor

  return values(annotations)
endfunction

function! unite#taskwarrior#annotations#format(annotation) abort
  return printf("%s\n\t%s", a:annotation.description,
        \ join(map(a:annotation.tasks, "'#' . v:val.short"), ", "))
endfunction

function! unite#taskwarrior#annotations#time(annotation) abort
  let stamp = a:annotation.entry
  let parts = split(substitute(stamp, 'Z', '', ''), 'T')
  let precision = unite#taskwarrior#config('annotation_precision')
  let time = str2float(parts[1]) / 10
  let rounded = float2nr(floor(time / precision) * precision)
  return printf("%sT%sZ", parts[0], string(rounded))
endfunction

function! unite#taskwarrior#annotations#content(annotation) abort
  return a:annotation.description
endfunction

function! unite#taskwarrior#annotations#edit(annotation) abort
  call unite#taskwarrior#scratch#edit(a:annotation.description, 
        \ 'unite#taskwarrior#annotations#update', a:annotation)
endfunction

function! unite#taskwarrior#annotations#update(descriptions, annotation) abort
  let uuids = join(map(a:annotation.tasks, 'v:val.uuid'), ',')
  call unite#taskwarrior#call([uuids, "denote", a:annotation.description])
  for description in split(a:descriptions, "\n")
    call unite#taskwarrior#call([uuids, "annotate", a:new_description])
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
