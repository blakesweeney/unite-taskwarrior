scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite_taskwarrior')
let s:DT = s:V.load('DateTime')
let s:DT = s:DT.DateTime

function! unite#taskwarrior#formatters#simple(task, ...) abort
  let tags = ''
  if a:task.tags != []
    let tags = printf(':%s:', join(map(a:task.tags, "v:val"), ':'))
  endif
  let options = get(a:000, 0, {})

  let mapping = unite#taskwarrior#config('status_mapping')
  let status = get(mapping, a:task.status, '?')
  let total = get(options, 'total', 80)
  let project_size = get(options, 'project', 10)

  let leader = index(a:task.tags, 'note') == -1 ?  '-' : '+'
  if get(a:task, 'started', 0)
    let mapping = unite#taskwarrior#config('status_mapping')
    let leader = mapping.active
  endif

  let description_size = total - (project_size + 7 + len(tags))
  let description_format = '%-' . description_size . 's'
  if len(a:task.description) > description_size
    let description_format = '%-.' . description_size . 's'
  endif

  let formatted = printf("%s [%s] %-" . project_size . "s " . description_format . " %s",
        \ leader,
        \ status,
        \ a:task.project,
        \ a:task.description,
        \ tags)

  if unite#taskwarrior#config('show_annotations')
    let annotations = []
    for annotation in get(a:task, 'annotations', [])
      let pretty = printf("  %.78s", annotation.description)
      call add(annotations, pretty)
    endfor
    if !empty(annotations)
      let formatted = printf("%s\n%s", formatted, join(annotations, "\n"))
    endif
  endif

  return formatted
endfunction

function! unite#taskwarrior#formatters#taskwiki(task, ...) abort
  let date = ''
  if get(a:task, 'due')
    let datetime = s:DT.from_format(a:task.due, '%Y%m%dT%H%M%SZ')
    let date = datetime.format('%Y-%m-%d')

    if datetime.hour() && datetime.minute()
      let date = date . ' ' . datetime.format('%H:%M')
    endif

    let date = printf('(%s)', date)
  endif

  let mapping = unite#taskwarrior#config('status_mapping')
  if has_key(a:task, 'start')
    let status = 'started'
  endif

  return printf('* [%s] %s%s  #%s', 
        \ get(mapping, a:task.status, '?'),
        \ a:task.description, 
        \ date, 
        \ a:task.short)
endfunction

function! unite#taskwarrior#formatters#description(task, ...) abort
  return a:task.description
endfunction

function! unite#taskwarrior#formatters#markdown(task, ...) abort
  return printf("# %s #", a:task.description)
endfunction

function! unite#taskwarrior#formatters#named(entry, ...) abort
  let config = get(a:000, 0, {})
  let name_size = get(config, 'name', 30)
  let format_string = "%-" . name_size . "s  %s"

  return printf(format_string, a:entry.name, a:entry.count)
endfunction

function! unite#taskwarrior#formatters#named_status(entry, ...) abort
  let config = get(a:000, 0, {})
  let mapping = get(config, 'mapping', 
        \ unite#taskwarrior#config('status_mapping'))
  let name_size = get(config, 'name', 30)
  let format_string = "%s %-" . name_size . "s  %s"
  let status_flag = get(mapping, a:entry.status, '?')

  return printf(format_string, status_flag, a:entry.name, a:entry.count)
endfunction

function! unite#taskwarrior#formatters#size_summary(tasks) abort
  let summary = {'project': [], 'description': [], 'name': []}

  for task in a:tasks
    call add(summary.project, len(get(task, 'project', '')))
    call add(summary.description, len(get(task, 'description', '')))
    call add(summary.name, len(get(task, 'name', '')))
  endfor

  return {
        \ 'project': max(summary.project),
        \ 'description': max(summary.description),
        \ 'name': max(summary.name)
        \ }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
