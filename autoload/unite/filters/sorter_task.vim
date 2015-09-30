let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite_taskwarrior')
let s:DT = s:V.load('DateTime')
let s:DT = s:DT.DateTime

let s:sorter = {
      \ 'name' : 'sorter_task',
      \ 'description' : 'taskwiki style sorting',
      \}

function! s:less(name, a1, a2, dir) abort
  let p1 = forward ? a:a1[a:name] : a:a2[a:name]
  let p2 = forward ? a:a2[a:name] : a:a1[a:name]
  return type(p1) == type([]) ? len(p1) < len(p2) : p1 < p2
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

function! s:sorting(definitions, candidates) abort
  for definition in a:definitions
    if 
  endfor
endfunction

function! unite#filters#sorter_task#get_sorting_definition(context) abort
  let key = get(a:context, 'custom_sorting',
        \ unite#taskwarrrior#config('default_sorting'))
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

function! s:sorter.filter(candidates, context) abort
  if empty(a:candidates)
    return a:candidates
  endif

  let def = unite#filters#sorter_task#get_sorting_definition(a:context)
  let attrs = unite#filters#sorter_task#parse(def)
  let sorting = {'attrs': attrs}

  function! sorter.compare(c1, c2) abort
    for attr in self.attrs
      let current = attr.func(attr.name, c1, c2, attr.ordering)
      if current
        return current
      endif
    endfor
    return 0
  endfunction

  return sort(a:candidates, sorter.compare, sorter)
endfunction

function! unite#filters#sorter_task#define() abort
  return s:sorter
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
