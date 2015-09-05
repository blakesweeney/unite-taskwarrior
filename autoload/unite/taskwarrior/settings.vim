let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#settings#load() abort
  let config = {}
  let raw = unite#taskwarrior#call('_show')

  for line in split(raw, "\n")
    let idx = stridx(line, '=')
    let key = strpart(line, 0, idx)
    let value = strpart(line, idx + 1)
    let config[key] = value
  endfor

  return config
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
