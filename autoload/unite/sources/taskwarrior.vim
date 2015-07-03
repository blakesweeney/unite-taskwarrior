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
  let filter = unite#taskwarrior#filter(a:args, project)
  let loaded = unite#taskwarrior#select(filter)
  for todo in loaded
    let line = call(g:unite_taskwarrior_formatter, [todo])
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
  if get(g:, 'unite_taskwarrior_define_mappings', 0) == 0
    return
  endif

  nnoremap <silent><buffer><expr> <TAB>       unite#do_action('toggle')
  nnoremap <silent><buffer><expr> <CR>        unite#do_action('view')
  nnoremap <silent><buffer><expr> d           unite#do_action('do')
  nnoremap <silent><buffer><expr> D           unite#do_action('delete')
  nnoremap <silent><buffer><expr> P           unite#do_action('edit_proj')
  nnoremap <silent><buffer><expr> A           unite#do_action('annotate')
  nnoremap <silent><buffer><expr> m           unite#do_action('modify')
  nnoremap <silent><buffer><expr> e           unite#do_action('edit')
  nnoremap <silent><buffer><expr> u           unite#do_action('undo')
  nnoremap <silent><buffer><expr> +           unite#do_action('start')
  nnoremap <silent><buffer><expr> -           unite#do_action('stop')
  " nnoremap <silent><buffer><expr> DA           unite#do_action('denotate')
endfunction

let s:source_cmd = {
      \ 'name': 'taskwarrior/cmd',
      \ 'default_kind': 'taskwarrior_cmd'
      \ }

function! s:source_cmd.change_candidates(args, context)
  return [{"word": a:context.input}]
endfunction

function! unite#sources#taskwarrior#define()
  return [s:source, s:source_cmd]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
