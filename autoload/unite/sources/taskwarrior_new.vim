let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/new',
      \ 'description': 'Create a new task',
      \ 'default_kind': 'taskwarrior'
      \ }

function! s:source.change_candidates(args, context) abort
  let input = a:context.input
  if input == ''
    return []
  endif

  let task = unite#taskwarrior#new_dict(input)
  let line = call(g:unite_taskwarrior_formatter, [task])
  return [{ "word": line, "source__data": task, }]
endfunction

function! unite#sources#taskwarrior_new#define()
  return [s:source]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
