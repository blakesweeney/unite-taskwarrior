let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/config',
      \ 'description': 'show current configuration',
      \ 'hooks': {},
      \ }

function! s:source.gather_candidates(args, context)
  let loaded = unite#taskwarrior#config#as_list()
  let summary = unite#taskwarrior#formatters#size_summary(loaded)
  let summary.value = 'value'

  let candidates = []
  for config in loaded
    call add(candidates, {
          \ "word": unite#taskwarrior#config#format(config, summary),
          \ "kind": "taskwarrior/config",
          \ "source__data": config,
          \ })
    unlet config
  endfor

  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  if unite#taskwarrior#config('define_mappings') == 0
    return
  endif

  call unite#taskwarrior#base_mappings()
endfunction

function! unite#sources#taskwarrior_config#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
