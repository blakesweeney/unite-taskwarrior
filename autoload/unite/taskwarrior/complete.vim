let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#complete#next_status(head, cmdline, pos) abort
  let known = unite#taskwarrior#config('toggle_mapping')
  if has_key(known, a:head)
    return [known[a:head]]
  endif

  for key in keys(known)
    if match(key, '^' . a:head) != -1
      return [key]
    endif
  endfor

  return []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
