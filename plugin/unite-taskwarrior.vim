if exists('g:loaded_unite_taskwarrior') && g:loaded_unite_taskwarrior
  finish
endif
let g:loaded_unite_taskwarrior = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -range=0 UniteTaskWarriorAdd
      \ call unite#taskwarrior#input(<q-args>, <count>, <line1>, <line2>)

let g:unite_taskwarrior_add_annotations = get(g:,
      \ "unite_taskwarrior_add_annotations",
      \ ["common"])

let s:annotate = {
      \ 'is_selectable': 1,
      \ 'description': 'Use this word to annotate tasks',
      \ 'is_quit': 1
      \ }
function! s:annotate.func(candidates)
  let annotatations = map(a:candidates, "v:val.word")
  call unite#start([["taskwarrior/annotate", annotatations]])
endfunction

for s:kind in g:unite_taskwarrior_add_annotations
  call unite#custom#action(s:kind, 'annotate', s:annotate)
endfor

function! s:taskwarrior_settings() abort
  if get(g:, 'unite_taskwarrior_define_mappings', 0) ==  1
    return 0
  endif

  if get(unite#get_context(), 'source', '') == 'taskwarrior'
    nmap <buffer><expr> <TAB>       <Plug>(unite#do_action('toggle'))
    nmap <buffer><expr> <CR>        <Plug>(unite#do_action('view'))
    nmap <buffer><expr> d           <Plug>(unite#do_action('do'))
    nmap <buffer><expr> D           <Plug>(unite#do_action('delete'))
    nmap <buffer><expr> P           <Plug>(unite#do_action('edit_proj'))
  endif
endfunction

autocmd FileType unite call s:taskwarrior_settings()

let &cpo = s:save_cpo
unlet s:save_cpo
