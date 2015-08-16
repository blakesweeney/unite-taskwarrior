scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#context#select() abort
  let raw = unite#taskwarrior#call('_show')
  let contexts = []
  for line in split(raw, '\n')
    let matches = matchlist(name, '^context\.\(\w\+\)=\(.\+\)$')
    if matches != []
      let name = matches[1]
      let def = matches[2]
      call append(contexts, {
            \ 'name': name,
            \ 'count': unite#taskwarrior#count(def),
            \ 'definition': def
            \ })
    endfor
  endif
  return contexts
endfunction

function unite#taskwarrior#context#basic_format(context) abort
  return printf("unite#taskwarrior#config('context_format_string'),
        \ a:context.name,
        \ a:context.count)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
