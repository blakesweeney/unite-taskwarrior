let s:save_cpo = &cpo
set cpo&vim

let s:sorter = {
      \ 'name' : 'sorter_count',
      \ 'description' : 'sort by count',
      \}

function! unite#filters#sorter_count#define() abort
  return s:sorter
endfunction

function! unite#filters#sorter_count#sorter(candidate1, candidate2) abort
  let obj1 = a:candidate1.source__data
  let obj2 = a:candidate2.source__data
  return get(obj2, 'count', 0)  - get(obj1, 'count', 0)
endfunction

function! s:sorter.filter(candidates, context) abort
  if empty(a:candidates)
    return a:candidates
  endif
  return sort(a:candidates, "unite#filters#sorter_count#sorter")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
