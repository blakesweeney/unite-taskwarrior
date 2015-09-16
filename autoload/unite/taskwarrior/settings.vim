let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#settings#load() abort
  let config = []
  let raw = unite#taskwarrior#call('_show')

  for line in split(raw, "\n")
    let idx = stridx(line, '=')
    let key = strpart(line, 0, idx)
    let value = strpart(line, idx + 1)
    call add(config, {'name': key, 'value': value})
  endfor

  return config
endfunction

function! unite#taskwarrior#settings#get(raw) abort
  let name = unite#taskwarrior#settings#name(a:raw)
  let value = unite#taskwarrior#call(['_get', name])
  if value == "\n"
    return {}
  endif
  let found = split(value, "\n")
  return {'name': strpart(name, 3), 'value': found[0]}
endfunction

function! unite#taskwarrior#settings#name(value, ...) abort
  let use_rc = get(a:000, 0, 1)
  let raw = type(a:value) == type('') ? a:value : a:value.name

  if strpart(raw, 0, 3) == 'rc.'
    return use_rc ? raw : strpart(raw, 3)
  endif

  return use_rc ? 'rc.' . raw : raw
endfunction

function! unite#taskwarrior#settings#set(setting, value) abort
  let name = unite#taskwarrior#settings#name(a:setting, 0)
  return unite#taskwarrior#call(['config', name, a:value])
endfunction

function! unite#taskwarrior#settings#delete(setting) abort
  let name = unite#taskwarrior#settings#name(a:setting, 0)
  return unite#taskwarrior#call(['config', name, ''])
endfunction

function! unite#taskwarrior#settings#unset(setting) abort
  let name = unite#taskwarrior#settings#name(a:setting, 0)
  return unite#taskwarrior#call(['config', name])
endfunction

function! unite#taskwarrior#settings#format(setting, summary) abort
  let formatter = unite#taskwarrior#config('setting_formatter')
  return call(formatter, [a:setting, a:summary])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
