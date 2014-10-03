if exists('g:loaded_unite_task') && g:loaded_unite_task
  finish
endif
let g:loaded_unite_todo = 0

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -range=0 UniteTaskWarriorAdd call unite#todo#input(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
