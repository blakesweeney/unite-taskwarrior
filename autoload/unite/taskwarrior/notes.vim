scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#notes#select(context) abort
  let dir = unite#taskwarrior#config('note_directory')
  let files = vimproc#readdir(dir)
  let data = []
  let lines = unite#taskwarrior#config('notes_header_lines')

  for file in files
    let header = join(readfile(file, '', lines), "\n")

    call add(data, {
          \ 'header': header,
          \ 'preview': header,
          \ 'uuid': fnamemodify(file, ':t:r'),
          \ 'path': file,
          \ })
    unlet file
  endfor

  return data
endfunction

function! unite#taskwarrior#notes#format(task) abort
  let formatter = unite#taskwarrior#config('note_formatter')
  let raw = call(formatter, [a:task, {}])
  return split(raw, "\n")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
