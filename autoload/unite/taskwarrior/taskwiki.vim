function! unite#taskwarrior#taskwiki#base() abort
  let home = $WIKIHOME
  if home != ''
    return home
  endif
  return $HOME . '/vimwiki'
endfunction

function! unite#taskwarrior#taskwiki#filename(task) abort
  let home = unite#taskwarrior#taskwiki#base()
  for annotation in get(a:task, 'annotations', [])
    let match = matchlist(annotation.description, 'wiki: \(.\+\)$')
    if match != []
      return match[1]
    endif
  endfor

  if get(a:task, 'project', '') != ''
    return printf('%s/project/%s.project.wiki', home, a:task.project)
  endif

  return printf('%s/index.wiki', home)
endfunction