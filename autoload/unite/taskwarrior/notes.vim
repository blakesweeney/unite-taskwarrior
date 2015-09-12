scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! unite#taskwarrior#notes#select(filt) abort
  let dir = unite#taskwarrior#config('note_directory')
  let files = vimproc#readdir(dir)
  let data = []
  let lines = unite#taskwarrior#config('notes_header_lines')
  let known = unite#taskwarrior#notes#tasks(a:filt)

  for file in files
    let header = join(readfile(file, '', lines), "\n")
    let uuid = fnamemodify(file, ':t:r')
    if !has_key(known, uuid)
      call add(data, {
            \ 'header': header,
            \ 'preview': header,
            \ 'uuid': uuid,
            \ 'path': file,
            \ })
    endif
    unlet file
  endfor

  return data
endfunction

function! unite#taskwarrior#notes#format(task) abort
  let formatter = unite#taskwarrior#config('note_formatter')
  let raw = call(formatter, [a:task, {}])
  return split(raw, "\n")
endfunction

function! unite#taskwarrior#notes#tasks(filt) abort
  let known = {}
  for uuid in unite#taskwarrior#call(a:filt . ' _uuids')
    let known[uuid] = 1
    let known[strpart(data.uuid, 0, 8)] = 1
    unlet uuid
  endfor
  return known
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
