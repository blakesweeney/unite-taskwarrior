let s:save_cpo = &cpo
set cpo&vim

let s:matcher = {
      \ 'name': 'match_task',
      \ 'description': 'match tasks'
      \ }

function! s:project_filter(possible, project)
  let found = []
  for candidate in a:possible
    if candidate.source__data.project =~ a:project
      call add(found, candidate)
    endif
  endfor
  return found
endfunction

function! s:tag_filter(possible, tag)
  let found = []
  for candidate in a:possible
    for tag in candidate.source__data.tags
      if tag =~ a:tag
        call add(found, candidate)
      endif
    endfor
  endfor
  return found
endfunction

function! s:matcher.filter(candidates, context)
  echomsg string(a:context)
  return a:candidates

  " if a:context.input == ''
  "   return unite#filters#filter_matcher(a:candidates, '', a:context)
  " endif

  " let matched = a:candidates
  " for input in a:context.input
  "   let matched = unite#filters#match_task#task_filter(
  "         \ matched,
  "         \ input,
  "         \ a:context)
  " endfor

  " return matched
endfunction

function! unite#filters#match_task#task_filter(possible, input, context)
  echomsg string('here')
  return a:possible
  " if strpart(a:input, 0, 1) == g:unite_taskwarrior_project_abbr
  "   return s:project_filter(a:possible, strpart(a:input, 1))
  " endif

  " if strpart(a:input, 0, 1) == g:unite_taskwarrior_tag_abbr
  "   return s:tag_filter(a:possible, strpart(a:input, 1))
  " endif

  " echomsg string(g:unite_taskwarrior_fallback_match)
  " return call("g:unite_taskwarrior_fallback_match", a:possible, a:context)
endfunction

function! unite#filters#match_task#define()
  return s:matcher
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
