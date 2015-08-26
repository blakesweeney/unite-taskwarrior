let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:parent = unite#sources#file#get_file_source()

let s:source = {
      \ 'name': 'taskwarrior/notes',
      \ 'description': 'get a listing of all note files',
      \ 'default_kind': 'file'
      \ }

function! s:source.gather_candidates(args, context)
  let candidates = []

  for file in unite#taskwarrior#notes#select(a:context)
    call add(candidates, {
          \ 'word': file.preview,
          \ 'source__data': file,
          \ 'action__path': file.path,
          \ 'is_multiline': 1,
          \ })
    unlet file
  endfor

  return candidates
endfunction

function! unite#sources#taskwarrior_notes#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
