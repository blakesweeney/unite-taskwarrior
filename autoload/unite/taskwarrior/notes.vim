function! unite#taskwarrior#notes#simple_format(task) abort
  return [a:task.description]
endfunction

function! unite#taskwarrior#notes#markdown_format(task) abort
  let header = printf("# %s #", a:task.description)
  return [header]
endfunction
