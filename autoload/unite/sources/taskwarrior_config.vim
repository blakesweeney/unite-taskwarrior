let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/config',
      \ 'description': 'show current configuration',
      \ 'hooks': {},
      \ }

function! s:source.gather_candidates(args, context)
  let filt = unite#taskwarrior#filters#from_source(a:args, a:context)
  let loaded = unite#taskwarrior#select(filt.str())
  let summary = unite#taskwarrior#formatters#size_summary(loaded)

  let candidates = []
  for todo in loaded
    let line = unite#taskwarrior#format(todo, summary)
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior/config",
          \ "source__data": config,
          \ })
    unlet todo
  endfor

  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  if unite#taskwarrior#config('define_mappings') == 0
    return
  endif

  call unite#taskwarrior#base_mappings()
endfunction

function! unite#sources#taskwarrior#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
