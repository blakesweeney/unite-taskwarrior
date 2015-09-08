scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#context#select() abort
  let raw = unite#taskwarrior#call('_show')
  let active = ''
  let contexts = [{
        \ 'name': 'none',
        \ 'count': unite#taskwarrior#count('+PENDING'),
        \ 'definition': '',
        \ 'status': 'active',
        \ }]

  for line in split(raw, '\n')

    let active_matches = matchlist(line, 'context=\(.\+\)')
    if active_matches != []
      let active = active_matches[1]
      call unite#taskwarrior#call(['context', 'none'])
    endif

    let matches = matchlist(line, '^context\.\(.\+\)=\(.\+\)$')
    if matches != []
      let name = matches[1]
      let def = matches[2]
      let status = 'inactive'

      if name == active
        let status = 'active'
        let contexts[0].status = 'inactive'
      endif

      let counts = unite#taskwarrior#count('( ' . def . ' ) and +PENDING')
      call add(contexts, {
            \ 'name': name,
            \ 'count': counts,
            \ 'definition': def,
            \ 'status': status
            \ })
    endif
  endfor

  call unite#taskwarrior#call(['context', active])

  return contexts
endfunction

function! unite#taskwarrior#context#filter(context) abort
  let default = unite#taskwarrior#config('filter')
  let filter = a:context.definition

  if empty(default)
    return filter
  endif

  let simple = ''
  if type(default) == type('')
    let simple = default
  elseif type(default) == type([])
    let simple = join(default, ' and ')
  endif

  return printf('( %s ) and ( %s )', filter, simple)
endfunction

function! unite#taskwarrior#context#set(context) abort
  call unite#taskwarrior#call(['context', a:context.name])
endfunction

function! unite#taskwarrior#context#delete(context) abort
  call unite#taskwarrior#call(['context', 'delete', a:context.name])
endfunction

function! unite#taskwarrior#context#rename(new_name, context) abort
  call unite#taskwarrior#context#define(a:new_name, a:context.definition)
  call unite#taskwarrior#context#delete(a:context)
endfunction

function! unite#taskwarrior#context#define(name, def) abort
  call unite#taskwarrior#call(printf('context define %s %s', a:name, a:def))
endfunction

function! unite#taskwarrior#context#current() abort
  let raw = unite#taskwarrior#call('_show')
  let active = ''
  for line in split(raw, '\n')
    let matches = matchlist(line, 'context=\(.\+\)')
    if !empty(matches)
      let active = matches[1]
    endif

    if !empty(active)
      let matches = matchlist(line, '^context\.' . active . '=\(.\+\)$')
      if !empty(matches)
        return { 'name': active, 'definition': matches[1] }
      endif
    endif
  endfor

  return {}
endfunction

function! unite#taskwarrior#context#get(name) abort
  let raw = unite#taskwarrior#call('_show')
  let active = ''

  for line in split(raw, '\n')
    let matches = matchlist(line, '^context\.' . a:name . '=\(.\+\)$')
    if !empty(matches)
      return {'name': a:name, 'definition': matches[1]}
    endif
  endfor

  return {}
endfunction

function! unite#taskwarrior#context#format(context, summary) abort
  let formatter = unite#taskwarrior#config('context_formatter')
  return call(formatter, [a:context, a:summary])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
