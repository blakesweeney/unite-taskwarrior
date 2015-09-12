scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#tags#select(filt)
  let tags = {}

  for task in unite#taskwarrior#select(a:filt)
    for tag in task.tags
      if tag == ''
        continue
      endif
      let data = get(tags, tag, {'name': tag, 'count': 0})
      let data.count += 1
      let tags[tag] = data
    endfor
  endfor

  return values(tags)
endfunction

function! unite#taskwarrior#tags#format(tag, summary) abort
  let formatter = unite#taskwarrior#config('tag_formatter')
  return call(formatter, [a:tag, a:summary])
endfunction

function! unite#taskwarrior#tags#abbr(data)
  if a:data == ''
    return ''
  endif
  if type(a:data) == type('')
    return unite#taskwarrior#config('tags_abbr') . a:data
  endif
  return unite#taskwarrior#config('tags_abbr') . a:data.name
endfunction

function! unite#taskwarrior#tags#expand(short)
  if strpart(a:short, 0, 1) == unite#taskwarrior#config('tags_abbr')
    return 'tag:' . strpart(a:short, 1, -1)
  endif
  return 'tag:' . a:short
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
