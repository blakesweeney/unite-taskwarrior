let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite_taskwarrior')
let s:DT = s:V.load('DateTime')
let s:DT = s:DT.DateTime

let s:sorter = {
      \ 'name' : 'sorter_task',
      \ 'description' : 'taskwiki style sorting',
      \}

function! s:less(name, a1, a2, forward) abort
  let p1 = get((a:forward ? a:a1 : a:a2), a:name)
  let p2 = get((a:forward ? a:a2 : a:a1), a:name)
  if type(p1) == type([])
    return len(p1) - len(p2)
  endif

  if s:is_date(p1) && s:is_date(p2)
    return s:date_less(name, a:a1, a:a2, a:forward)
  end

  return p1 == p2 ? 0 : p1 > p2 ? 1 : -1
endfunction

function! s:date_less(name, a1, a2, forward) abort
  let parsed = '_' . a:name
    let a:a1[parsed] = get(a:a1, parsed,
          \ s:DT.from_format(a:a1[a:name], '%Y%m%dT%H%M%SZ'))
    let a:a2[parsed] = get(a:a2, parsed,
          \ s:DT.from_format(a:a2[a:name], '%Y%m%dT%H%M%SZ'))
    return (a:forward ? a:a1[parsed].compare(a:a2[parsed]) :
          \ a:a2[parsed].compare(a:a1[parsed]))
endfunction

function! s:is_date(attr) abort
  let pattern = '^\d\{8}T\d\{6}Z$'
  if type(a:attr) != type('')
    return 0
  endif
  return match(pattern, a:attr) != -1
endfunction

function! unite#filters#sorter_task#get_sorting_definition(context) abort
  let key = get(a:context, 'custom_sorting',
        \ unite#taskwarrior#config('default_ordering'))
  let known = unite#taskwarrior#config('sort_orders')

  return get(known, key, key)
endfunction

function! unite#filters#sorter_task#parse(definition) abort
  let attrs = []
  for def in split(a:definition, ',')
    let matches = matchlist(def, '^\(\w\+\)\([+-]\)$')
    if !empty(matches)
      call add(attrs, {
            \ 'name': matches[1],
            \ 'ordering': matches[2] == '+',
            \ 'func': function('s:less')
            \ })
    endif
  endfor
  return attrs
endfunction

function! unite#filters#sorter_task#build(context) abort
  let def = unite#filters#sorter_task#get_sorting_definition(a:context)
  if empty(def)
    return {}
  endif

  let sorter = {'attrs': unite#filters#sorter_task#parse(def)}

  function! sorter.func(c1, c2) abort
    for attr in self.attrs
      let current = attr.func(attr.name, a:c1.source__data, a:c2.source__data,
            \ attr.ordering)
      if !empty(current)
        return current
      endif
    endfor

    return 0
  endfunction

  return sorter
endfunction

function! s:sorter.filter(candidates, context) abort
  if empty(a:candidates)
    return a:candidates
  endif

  let sorter = unite#filters#sorter_task#build(a:context)
  if empty(sorter)
    return a:candidates
  endif

  return sort(a:candidates, sorter.func, sorter)
endfunction

function! unite#filters#sorter_task#define() abort
  return s:sorter
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
