let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/annotations',
      \ 'syntax': 'TaskWarrior',
      \ 'default_action': 'edit',
      \ 'default_kind': 'taskwarrior_annotations',
      \ 'action_table': {}
      \ }


function! unite#sources#taskwarrior_annotations#define()
  return s:source
endfunction

function! s:source.gather_candidates(args, context)
  let candidates = []
  for group in unite#taskwarrior#annotations#groups(a:args)
    call add(candidates, {
          \ 'word': unite#taskwarrior#annotations#format(group),
          \ 'is_multiline': 1,
          \ 'source__data': group
          \ })
    unlet group
  endfor
  return candidates
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
