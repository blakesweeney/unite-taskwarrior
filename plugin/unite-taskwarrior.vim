if exists('g:loaded_unite_taskwarrior') && g:loaded_unite_taskwarrior
  finish
endif
let g:loaded_unite_taskwarrior = 1

let s:save_cpo = &cpo
set cpo&vim

let g:unite_taskwarrior_annotate_kind = get(g:,
      \ "unite_taskwarrior_annotate_kind",
      \ ["common"])

command! -nargs=* -range=0 UniteTaskWarriorAdd
      \ call unite#taskwarrior#input(<q-args>, <count>, <line1>, <line2>)

let s:annotate = {
      \ 'is_selectable': 1,
      \ 'description':  'Use this word to annotate tasks'
      \ }
function! s:annotate.func(candidates)
  let annotatations = map(a:candidates, "v:val.word")
  " TODO: Fetch tasks
  let tasks = []
  for task in tasks
    for annotatation in annotatations
      call unite#taskwarrior#annotate(task, annotatation)
    endfor
  endfor
  echomsg join(annotatations, ', ')
endfunction

for s:kind in g:unite_taskwarrior_annotate_kind
  call unite#custom#action(s:kind, 'annotate', s:annotate)
endfor

let &cpo = s:save_cpo
unlet s:save_cpo
