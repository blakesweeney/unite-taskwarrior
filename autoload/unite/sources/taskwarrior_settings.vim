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
  for setting in configuration
    let line = ''
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior/settings",
          \ "source__data": setting
          \ })
    unlet todo
  endfor
  return candidates
endfunction

function! unite#sources#taskwarrior_settings#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
