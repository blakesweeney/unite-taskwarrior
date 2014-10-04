scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#tags#select(args)
  let filter = unite#taskwarrior#filter(a:args)
  let tasks = unite#taskwarrior#select(filter)
  let tags = {}

  for task in tasks
    for tag in task.tags
      let data = get(tags, tag, {'name': tag, 'count': 0})
      let data.count += 1
      let tags[tag] = data
    endfor
  endfor

  return values(tags)
endfunction

function! unite#taskwarrior#tags#format(tag)
  return '@' . a:tag.name
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
