let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior_annotate',
      \ 'syntax': 'TaskWarrior',
      \ 'default_action': 'annotate',
      \ 'action_table': {}
      \ }

let s:taskwarrior = unite#sources#taskwarrior#define()[0]

function! s:source.gather_candidates(args, context)
  let candidates = s:taskwarrior.gather_candidates([], {})
  for candidate in candidates
    let candidate['source__annotations'] = a:args[0]
  endfor
  return candidates
endfunction

let s:source.action_table.annotate = {
      \ 'description': 'annotate a task',
      \ 'is_selectable': 1
      \ }
function! s:source.action_table.annotate.func(candidates)
  for candidate in a:candidates
    let task = candidate.source__data
    for annotatation in candidate.source__annotations
      call unite#taskwarrior#annotate(task, annotatation)
    endfor
  endfor
endfunction

function! unite#sources#taskwarrior_annotate#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
