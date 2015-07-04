let s:save_cpo = &cpo
set cpo&vim

call unite#taskwarrior#init()

let s:source = {
      \ 'name': 'taskwarrior/new',
      \ 'description': 'Create a new task',
      \ 'default_kind': 'taskwarrior',
      \ 'hooks': {},
      \ }

function! s:source.change_candidates(args, context) abort
  let input = a:context.input
  if input == ''
    return []
  endif

  let task = unite#taskwarrior#new_dict(input)
  let line = call(unite#taskwarrior#config('formatter'), [task])
  return [{ "word": line, "source__data": task, }]
endfunction

function! unite#sources#taskwarrior_new#define()
  return [s:source]
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
  nnoremap <silent><buffer><expr> +           unite#do_action('start')
  nnoremap <silent><buffer><expr> -           unite#do_action('stop')
  " nnoremap <silent><buffer><expr> DA           unite#do_action('denotate')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
