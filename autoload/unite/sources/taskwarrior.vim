let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior',
      \ 'syntax': 'TaskWarrior',
      \ 'hooks': {},
      \ 'source__name': 'taskwarrior',
      \ 'sorters': 'sorter_task_urgency'
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let candidates = []
  let project = get(a:context, 'custom_project', '')

  if has_key(a:context, 'custom_filter')
    let filter = unite#taskwarrior#filter(a:args, project, a:context.custom_filter)
  else
    let filter = unite#taskwarrior#filter(a:args, project)
  endif

  let loaded = []
  if len(filter) == 1
    let loaded = unite#taskwarrior#select(filter[0])
  else
    let loaded = unite#taskwarrior#select(filter)
  endif

  for todo in loaded
    let line = call(unite#taskwarrior#config('formatter'), [todo])
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior",
          \ "is_multiline": 1,
          \ "source__data": todo,
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
