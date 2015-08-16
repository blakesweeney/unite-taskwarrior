let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/context',
      \ 'syntax': 'TaskWarrior',
      \ 'hooks': {},
      \ 'source__name': 'taskwarrior/context',
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let loaded = unite#taskwarrior#context#select()
  for todo in loaded
    let line = call(unite#taskwarrior#config('context_formatter'), [todo])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_context",
          \ "source__data": todo,
          \ })
    unlet todo
  endfor
  return candidates
endfunction

function! unite#sources#taskwarrior_context#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
