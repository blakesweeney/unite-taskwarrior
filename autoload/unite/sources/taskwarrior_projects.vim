let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/projects',
      \ 'description': 'Show a listing of know projects',
      \ 'syntax': 'TaskWarrior',
      \ 'sorters': 'sorter_count',
      \ 'hooks': {}
      \ }

" Consider using async
function! s:source.gather_candidates(args, context)
  let filt = unite#taskwarrior#filters#from_source(a:args, a:context)
  let projects = unite#taskwarrior#projects#select(filt.str())
  let summary = unite#taskwarrior#formatters#size_summary(projects)

  let candidates = []
  for project in projects
    let line = unite#taskwarrior#projects#format(project, summary)
    call add(candidates, {
          \ "word": line,
          \ "kind": "taskwarrior_project",
          \ "source__data": project
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

function! unite#sources#taskwarrior_projects#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
