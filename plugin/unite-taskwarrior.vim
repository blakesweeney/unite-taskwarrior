if exists('g:loaded_unite_taskwarrior') && g:loaded_unite_taskwarrior
  finish
endif
let g:loaded_unite_taskwarrior = 0

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -range=0 UniteTaskWarriorAdd call unite#taskwarrior#input(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
