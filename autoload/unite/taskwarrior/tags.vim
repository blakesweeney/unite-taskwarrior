scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#tags#select(args)
  let filter = unite#taskwarrior#filter(a:args, '')
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
  return printf(g:unite_taskwarrior_tag_format_string, 
        \ a:tag.name,
        \ a:tag.count)
endfunction

function! unite#taskwarrior#tags#abbr(data)
  if a:data == ''
    return ''
  endif
  if type(a:data) == type('')
    return g:unite_taskwarrior_tags_abbr . a:data
  endif
  return g:unite_taskwarrior_tags_abbr . a:data.name
endfunction

function! unite#taskwarrior#tags#expand(short)
  if strpart(a:short, 0, 1) == g:unite_taskwarrior_tags_abbr
    return 'tag:' . strpart(a:short, 1, -1)
  endif
  return 'tag:' . a:short
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
