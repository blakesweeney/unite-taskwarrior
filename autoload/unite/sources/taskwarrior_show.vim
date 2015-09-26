let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/show',
      \ 'description': 'list and modify taskwarrior settings',
      \ }

function! s:source.gather_candidates(args, context)
  let candidates = []

  let configuration = unite#taskwarrior#settings#load()
  let summary = unite#taskwarrior#formatters#size_summary(configuration)
  let summary.value = 'value'
  for setting in configuration
    let line = unite#taskwarrior#settings#format(setting, summary)
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior/show",
          \ "source__data": setting
          \ })
    unlet setting
  endfor
  return candidates
endfunction

function! unite#sources#taskwarrior_show#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
