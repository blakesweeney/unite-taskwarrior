let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/tags',
      \ 'description': 'Show a listing of all known tags',
      \ 'syntax': 'TaskWarrior',
      \ 'sorters': 'sorter_count',
      \ 'hooks': {}
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let filt = unite#taskwarrior#filters#from_source(a:args, a:context)
  let tags = unite#taskwarrior#tags#select(filt.str())
  let summary = unite#taskwarrior#formatters#size_summary(tags)

  let candidates = []
  for tag in tags
    let line = unite#taskwarrior#tags#format(tag, summary)
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_tag",
          \ "source__data": tag
          \ })
  endfor
  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  if unite#taskwarrior#config('define_mappings') == 0
    return
  endif

  call unite#taskwarrior#base_mappings() 
endfunction

function! unite#sources#taskwarrior_tags#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
