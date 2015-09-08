let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#settings#load() abort
  let config = []
  let raw = unite#taskwarrior#call('_show')

  for line in split(raw, "\n")
    let idx = stridx(line, '=')
    let key = strpart(line, 0, idx)
    let value = strpart(line, idx + 1)
    call add(config, {'name', key, 'value': value})
  endfor

  return config
endfunction

function! unite#taskwarrior#settings#get(name) abort
  let value = unite#taskwarrior#call(['_get', 'rc.' . name])
  return {'name': a:name, 'value': value}
endfunction

function! unite#taskwarrior#settings#set(name, value) abort
  return unite#taskwarrior#call(['config', a:name, a:value])
endfunction

function! unite#taskwarrior#settings#delete(name) abort
  return unite#taskwarrior#call(['config', a:name, ''])
endfunction

function! unite#taskwarrior#settings#unset(name) abort
  return unite#taskwarrior#call(['config', a:name])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
