let s:save_cpo = &cpo
set cpo&vim

let s:sorter = {
      \ 'name' : 'sorter_task_urgency',
      \ 'description' : 'sort by task urgency',
      \}

function! unite#filters#sorter_task_urgency#define()
  return s:sorter
endfunction

function! unite#filters#sorter_task_urgency#sorter(candidate1, candidate2) abort
  let task1 = a:candidate1.source__data
  let task2 = a:candidate2.source__data
  return float2nr(get(task2, 'urgency', 0.0) - get(task1, 'urgency', 0.0))
endfunction

function! s:sorter.filter(candidates, context) abort
  if empty(a:candidates)
    return a:candidates
  endif
  return sort(a:candidates, "unite#filters#sorter_task_urgency#sorter")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
