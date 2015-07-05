if exists('g:loaded_unite_taskwarrior') && g:loaded_unite_taskwarrior
  finish
endif
let g:loaded_unite_taskwarrior = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -range=0 UniteTaskWarriorAdd
      \ call unite#taskwarrior#input(<q-args>, <count>, <line1>, <line2>)

command -nargs=0 -range=0 UniteTaskWarriorUndo
      \ call unite#taskwarrior#undo()

let g:unite_taskwarrior_add_annotations = get(g:,
      \ "unite_taskwarrior_add_annotations",
      \ ["common"])

let s:annotate = {
      \ 'is_selectable': 1,
      \ 'description': 'Use this word to annotate tasks',
      \ 'is_quit': 1
      \ }
function! s:annotate.func(candidates)
  let annotations = map(a:candidates, "v:val.word")
  let args = ["taskwarrior/annotate"]
  call extend(args, annotations)
  call unite#start([args])
endfunction

for s:kind in g:unite_taskwarrior_add_annotations
  call unite#custom#action(s:kind, 'annotate_task', s:annotate)
endfor

let &cpo = s:save_cpo
unlet s:save_cpo
