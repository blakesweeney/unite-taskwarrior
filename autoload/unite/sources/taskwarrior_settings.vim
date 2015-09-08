let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/settings',
      \ 'description': 'list and modify taskwarrior settings',
      \ }

function! s:source.gather_candidates(args, context)
  let candidates = []

  let configuration = unite#taskwarrior#settings#load()
  for key in keys(configuration)
    let value = configuration[key]
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior/settings",
          \ "source__data": todo,
          \ })
    unlet todo
  endfor
  return candidates
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
