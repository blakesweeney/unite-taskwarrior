let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/context',
      \ 'description': 'Show a listing of all contexts',
      \ 'syntax': 'TaskWarrior',
      \ 'hooks': {},
      \ 'source__name': 'taskwarrior/context',
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let loaded = unite#taskwarrior#context#select()
  let candidates = []

  for context in loaded
    let line = call(unite#taskwarrior#config('context_formatter'), [context])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_context",
          \ "source__data": context
          \ })
    unlet context
  endfor

  return candidates
endfunction

function! unite#sources#taskwarrior_context#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
