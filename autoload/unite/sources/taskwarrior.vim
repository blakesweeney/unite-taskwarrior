let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior',
      \}

" Consider using async
function! s:source.gather_candidates(args, context)
  let candidates = []
  let tags = unite#taskwarrior#filter(a:args)
  let loaded = unite#taskwarrior#select(tags)
  for todo in loaded
    let line = call(g:unite_taskwarrior_formatter, [todo])
    call add(candidates, {
          \   "word": line,
          \   "kind": "taskwarrior",
          \   "source__data": todo,
          \ })
    unlet todo
  endfor
  return candidates
endfunction

function! unite#sources#taskwarrior#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
