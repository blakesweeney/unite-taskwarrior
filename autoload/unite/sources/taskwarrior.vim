let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior',
      \ 'description': 'Show a list of tasks',
      \ 'syntax': 'TaskWarrior',
      \ 'hooks': {},
      \ 'source__name': 'taskwarrior',
      \ 'sorters': 'sorter_task_urgency'
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let filt = unite#taskwarrior#filters#from_source(a:args, a:context)
  let loaded = unite#taskwarrior#select(filt.str())
  let summary = unite#taskwarrior#formatters#size_summary(loaded)
  let summary.annotation_indent = unite#taskwarrior#settings#get('indent.annotation').value

  let candidates = []
  for todo in loaded
    let line = unite#taskwarrior#format(todo, summary)
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior",
          \ "is_multiline": 1,
          \ "source__data": todo,
          \ 'action__path': todo.note
          \ })
    unlet todo
  endfor

  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context) abort
  if unite#taskwarrior#config('define_mappings') == 0
    return
  endif

  call unite#taskwarrior#bindings() 
endfunction

function! unite#sources#taskwarrior#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
