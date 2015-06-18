scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let g:unite_taskwarrior_command = get(g:,
      \ 'unite_taskwarrior_command',
      \ "task")

let g:unite_taskwarrior_note_directory = get(g:,
      \ 'unite_taskwarrior_note_directory',
      \ '~/.task/note')

let g:unite_taskwarrior_note_suffix = get(g:,
      \ 'unite_taskwarrior_note_suffix',
      \ 'mkd')

let g:unite_taskwarrior_note_formatter = get(g:,
      \ 'unite_taskwarrior_note_formatter',
      \ 'unite#taskwarrior#notes#simple_format')

let g:unite_taskwarrior_format_string = get(g:,
      \ "unite_taskwarrior_format_string",
      \ "[%s] %15s\t%s (%s)")

let g:unite_taskwarrior_tag_format_string = get(g:,
      \ 'unite_taskwarrior_tag_format_string',
      \ "%20s\t%5s")

let g:unite_taskwarrior_project_format_string = get(g:,
      \ 'unite_taskwarrior_project_format_string',
      \ "%20s\t%5s")

let g:unite_taskwarrior_formatter = get(g:,
      \ "unite_taskwarrior_formatter",
      \ 'unite#taskwarrior#format')

let g:unite_taskwarrior_tag_formatter = get(g:,
      \ "unite_taskwarrior_tag_formatter",
      \ 'unite#taskwarrior#tags#format')

let g:unite_taskwarrior_project_formatter = get(g:,
      \ "unite_taskwarrior_project_formatter",
      \ 'unite#taskwarrior#projects#format')

let g:unite_taskwarrior_filter = get(g:,
      \ 'unite_taskwarrior_filter',
      \ 'status.not:deleted')

let g:unite_taskwarrior_toggle_mapping = get(g:,
      \ 'unite_taskwarrior_toggle_mapping', {
      \ 'pending': 'completed',
      \ 'completed': 'pending'
      \ })

let g:unite_taskwarrior_status_mapping = get(g:,
      \ "unite_taskwarrior_stats_mapping", {
      \ 'pending': ' ',
      \ 'waiting': '-',
      \ 'completed': '✓',
      \ 'deleted': 'x',
      \ 'recurring': '+',
      \ 'unknown': 'N'
      \ })

let g:unite_taskwarrior_projects_abbr = get(g:,
      \ "unite_taskwarrior_projects_abbr",
      \ "$")

let g:unite_taskwarrior_tags_abbr = get(g:,
      \ "unite_taskwarrior_tags_abbr",
      \ "+")

let g:unite_taskwarrior_fallback_match = get(g:,
      \ "unite_taskwarrior_fallback_match",
      \ "matcher_fuzzy")

let g:unite_taskwarrior_uri_format = get(g:,
      \ 'unite_taskwarrior_uri_format',
      \ '<task:%s>')

let g:unite_taskwarrior_missing_project = get(g:,
      \'unite_taskwarrior_missing_project',
      \ '(none)')

function! unite#taskwarrior#trim(str)
  return substitute(a:str, '^\s\+\|\s\+$', '', 'g')
endfunction

" Taken from https://gist.github.com/dahu/3322468
function! unite#taskwarrior#flatten(list) abort
  let val = []
  for elem in a:list
    if type(elem) == type([])
      call extend(val, unite#taskwarrior#flatten(elem))
    else
      call extend(val, [elem])
    endif
    unlet elem
  endfor
  return val
endfunction

function! unite#taskwarrior#call(filter, cmd, ...)
  let args = [g:unite_taskwarrior_command, a:filter, a:cmd]
  call extend(args, a:000)
  if a:filter == ''
    call remove(args, 1)
  endif
  return  vimproc#system(args)
endfunction

function! unite#taskwarrior#run(task, cmd, ...)
  let task = unite#taskwarrior#new(a:task)
  let args = [l:task.uuid, a:cmd]
  call extend(args, a:000)
  return call('unite#taskwarrior#call', args)
endfunction

function! unite#taskwarrior#init()
  let g:unite_taskwarrior_note_directory = expand(g:unite_taskwarrior_note_directory)
  if !isdirectory(g:unite_taskwarrior_note_directory)
    call mkdir(g:unite_taskwarrior_note_directory, 'p')
  endif
endfunction

function! unite#taskwarrior#load_config(filename)
  let file = vimproc#open(a:filename)
  let lines = file.read()
  return eval(lines)
endfunction

function! unite#taskwarrior#filter(strings, project)
  let filters = []
  for entry in a:strings
    if strpart(entry, 0, 1) == '@'
      call add(filters, 'tag:' . strpart(entry, 1))
    endif
    if strpart(entry, 0, 1) == '$'
      call add(filters, 'project:' . strpart(entry, 1))
    endif
  endfor

  if a:project ==? 'infer'
    if filereadable("./unite-taskwarior")
      let config = unite#taskwarrior#load_config("./unite-taskwarior")
      call add(filters, 'project:' . config.project)
    else
      call add(filters, "project:" . fnamemodify(getcwd(), ":t"))
    endif
  endif

  return filters
endfunction

function! unite#taskwarrior#format(task)
  let project = unite#taskwarrior#projects#abbr(a:task.project)
  let tags = map(a:task.tags, "unite#taskwarrior#tags#abbr(v:val)")
  let status = get(g:unite_taskwarrior_status_mapping, a:task.status, '?')
  if filereadable(a:task.note)
    call add(tags, g:unite_taskwarrior_tags_abbr . "NOTE")
  endif

  return printf(g:unite_taskwarrior_format_string,
        \ status,
        \ project,
        \ a:task.description,
        \ join(tags, ' '))
endfunction

function! unite#taskwarrior#format_taskwiki(task) abort
  let format = "* [ ] %s%s  #%s"
  let date = ''
  let due = get(a:task, 'due', '')
  if due != ''
    let date = printf(" (%s-%s-%s %s:%s)",
          \ strpart(due, 0, 4),
          \ strpart(due, 4, 2),
          \ strpart(due, 6, 2),
          \ strpart(due, 9, 2),
          \ strpart(due, 11, 2))
  endif
  return printf(format, a:task.description, date, a:task.short)
endfunction

function! unite#taskwarrior#parse(raw)
  let line = substitute(a:raw, "\n$", "", "")
  " Who needs safety?
  let data = eval(line)
  " TODO: Fix safe version
  " let data = pyeval("json.loads(vim.eval('a:raw'))")
  let data.note = printf('%s/%s.%s',
        \ g:unite_taskwarrior_note_directory,
        \ strpart(data.uuid, 0, 8),
        \ g:unite_taskwarrior_note_suffix)

  if !has_key(data, 'tags')
    let data.tags = []
  endif

  if !has_key(data, 'annotations')
    let data.annotations = []
  endif

  if !has_key(data, 'project')
    let data.project = ''
  endif

  let data.started = 0
  let data.start_time = ''
  if has_key(data, 'start_time')
    let data.started = 1
  endif

  let data.stopped = 0
  let data.stop_time = ''
  if has_key(data, 'stop_time')
    let data.stopped = 1
  endif

  let data.short = strpart(data.uuid, 0, 8)
  let data.uri = printf(g:unite_taskwarrior_uri_format, data.uuid)

  return data
endfunction

function! unite#taskwarrior#new_dict(raw) abort
  return {
        \ 'description': a:raw,
        \ 'status': 'unknown',
        \ 'tags': [],
        \ 'project': '',
        \ 'start_time': '',
        \ 'started': 0,
        \ 'stop_time': '',
        \ 'stopped': 0,
        \ 'short': '',
        \ 'uuid': '',
        \ 'uri': '',
        \ 'urgency': 0.0,
        \ 'note': ''
        \ }
endfunction

function! unite#taskwarrior#urgency_sorter(task1, task2) abort
  return float2nr(get(a:task2, 'urgency', 0.0) - get(a:task1, 'urgency', 0.0))
endfunction

function! unite#taskwarrior#select(pattern)
  let args = []
  if type(g:unite_taskwarrior_filter) == type([])
    call extend(args, g:unite_taskwarrior_filter)
  else
    call add(args, g:unite_taskwarrior_filter)
  endif
  call extend(args, ["export"])
  call extend(args, a:pattern)
  let raw = call("unite#taskwarrior#call", args)
  let lines = split(raw, "\n")
  let data = map(lines, 'unite#taskwarrior#parse(v:val)')
  return sort(data, "unite#taskwarrior#urgency_sorter")
endfunction

function! unite#taskwarrior#all()
  return unite#taskwarrior#select([])
endfunction

function! unite#taskwarrior#new(data)
  let args = ["", "add"]
  if type(a:data) == type([])
    call extend(args, unite#taskwarrior#flatten(a:data))
  elseif type(a:data) == type("")
    call extend(args, split(a:data))
  elseif type(a:data) == type({})
    if a:data.status != 'unknown'
      return a:data
    endif
    call extend(args, split(a:data.description))
  endif
  call call("unite#taskwarrior#call", args)
  return unite#taskwarrior#newest()
endfunction

function! unite#taskwarrior#newest() abort
  let tasks = split(unite#taskwarrior#call("", "newest"), "\n")
  let task_id = split(tasks[2])[0]
  let raw = unite#taskwarrior#call("export", task_id)
  return unite#taskwarrior#parse(raw)
endfunction

function! unite#taskwarrior#input(args, use_range, line1, line2)
  if a:use_range
    let lines = join(getline(a:line1, a:line2))
    call unite#taskwarrior#new(split(lines))
  else
    if a:args == ""
      call unite#taskwarrior#new(input('Task: '))
    else
      call unite#taskwarrior#new(a:args)
    endif
  endif
endfunction

function! unite#taskwarrior#do(task)
  return unite#taskwarrior#run(a:task, 'do')
endfunction

function! unite#taskwarrior#delete(task)
  return unite#taskwarrior#run(a:task, "delete")
endfunction

function! unite#taskwarrior#modify(task, data)
  return unite#taskwarrior#run(a:task, "modify", a:data)
endfunction

function! unite#taskwarrior#rename(task)
  return unite#taskwarrior#modify(a:task, "description:'" . a:task.description . "'")
endfunction

function! unite#taskwarrior#open(task)
  let task = unite#taskwarrior#new(a:task)
  if !filereadable(l:task.note)
    let content = call(g:unite_taskwarrior_note_formatter, [l:task])
    call writefile(content, l:task.note)
  endif
  execute ':edit ' . l:task.note
endfunction

function! unite#taskwarrior#toggle(task)
  let a:task.status = get(g:unite_taskwarrior_toggle_mapping,
        \ a:task.status,
        \ 'pending')
  return unite#taskwarrior#modify(a:task, "status:" . a:task.status)
endfunction

function! unite#taskwarrior#project(task, project)
  return unite#taskwarrior#modify(a:task, "proj:'" . a:project . "'")
endfunction

function! unite#taskwarrior#annotate(task, text)
  return unite#taskwarrior#run(a:task, "annotate", a:text)
endfunction

function! unite#taskwarrior#undo() abort
  return unite#taskwarrior#call('', 'undo')
endfunction

function! unite#taskwarrior#start(task)
  return unite#taskwarrior#run(a:task, "start")
endfunction

function! unite#taskwarrior#stop(task)
  return unite#taskwarrior#run(a:task, "stop")
endfunction

function! unite#taskwarrior#yank(task, formatter) abort
  if has_key(a:task, a:formatter)
    let @@ = get(a:task, a:formatter)
  else
    let @@ = call(a:formatter, a:task)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
