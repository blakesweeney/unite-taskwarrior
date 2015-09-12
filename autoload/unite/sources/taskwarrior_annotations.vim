let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/annotations',
      \ 'description': 'Show a listing of all annotations',
      \ 'syntax': 'TaskWarrior',
      \ 'default_action': 'edit',
      \ 'default_kind': 'taskwarrior_annotations',
      \ 'action_table': {},
      \ 'hooks': {}
      \ }

function! unite#sources#taskwarrior_annotations#define()
  return s:source
endfunction

function! s:source.gather_candidates(args, context)
  let candidates = []
  let filt = unite#taskwarrior#filters#from_source(a:args, a:context)
  for group in unite#taskwarrior#annotations#groups(filt.str())
    call add(candidates, {
          \ 'word': unite#taskwarrior#annotations#format(group),
          \ 'is_multiline': 1,
          \ 'source__data': group
          \ })
    unlet group
  endfor
  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  if unite#taskwarrior#config('define_mappings') == 0
    return
  endif

  call unite#taskwarrior#base_mappings() 
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
