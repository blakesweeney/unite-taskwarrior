let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior',
      \ 'syntax': 'TaskWarrior'
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let candidates = []
  let project = get(a:context, 'custom_project', '')
  let filter = unite#taskwarrior#filter(a:args, project)
  let loaded = unite#taskwarrior#select(filter)
  for todo in loaded
    let line = call(g:unite_taskwarrior_formatter, [todo])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior",
          \ "source__data": todo,
          \ })
    unlet todo
  endfor
  return candidates
endfunction

let s:source_cmd = {
      \ 'name': 'taskwarrior/cmd',
      \ 'default_kind': 'taskwarrior_cmd'
      \ }

function! s:source_cmd.change_candidates(args, context)
  return [{"word": a:context.input}]
endfunction

function! unite#sources#taskwarrior#define()
  return [s:source, s:source_cmd]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
