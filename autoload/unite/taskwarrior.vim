scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite_taskwarrior')
let s:JSON = s:V.load('Web.JSON')
let s:JSON = s:JSON.Web.JSON

let s:defaults = {
      \ 'command': "task",
      \ 'note_directory': '~/.task/note',
      \ 'note_suffix': 'mkd',
      \ 'note_formatter': 'unite#taskwarrior#notes#simple_format',
      \ 'notes_header_lines': 1,
      \ "format_string": "[%s] %15s\t%s (%s)",
      \ 'tag_format_string': "%20s\t%5s",
      \ 'project_format_string': "%20s\t%5s",
      \ 'context_format_string': '%s%10s%5s',
      \ 'context_status_mapping': {'active': '>', 'inactive': ' '},
      \ "formatter": 'unite#taskwarrior#format',
      \ "tag_formatter": 'unite#taskwarrior#tags#format',
      \ "project_formatter": 'unite#taskwarrior#projects#format',
      \ 'context_formatter': 'unite#taskwarrior#context#format',
      \ 'filter': 'status.not:deleted',
      \ 'toggle_mapping': { 'pending': 'completed', 'completed': 'pending' },
      \ "status_mapping": { 'pending': ' ', 'waiting': '-', 'recurring': '+', 'unknown': 'N' },
      \ "projects_abbr": "$",
      \ "tags_abbr": "+",
      \ "fallback_match": "matcher_fuzzy",
      \ 'uri_format': '<task:%s>',
      \ 'missing_project': '(none)',
      \ 'show_annotations': 1,
      \ 'group_annotations_by': 'time',
      \ 'annotation_precision': 2
      \ }

let s:config = deepcopy(s:defaults)

function! unite#taskwarrior#config(key, ...) abort
  if type(a:key) == type({})
    return extend(s:config, a:key)
  endif

  if type(a:key) == type('')
    let prefix = 'unite_taskwarrior_'
    let key_name = substitute(a:key, prefix, '', "")

    if empty(a:000)
      let global_key = prefix . key_name
      if has_key(g:, global_key)
        let value = get(g:, global_key)
      else
        let value = s:config[key_name]
      endif

      if key_name == 'note_directory'
        let value = expand(value)
      endif

      return value
    endif

    let s:config[key_name] = a:1
    return s:config
  endif
endfunction

function! unite#taskwarrior#reset_config()
  let s:config = deepcopy(s:defaults)
endfunction

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

function! unite#taskwarrior#call(given)
  let command = unite#taskwarrior#config('command')
  if type(a:given) == type([])
    let args = [command]
    call extend(args, a:given)
    let args = unite#taskwarrior#flatten(args)
  else
    let args = printf('%s %s', command, a:given)
  endif

  return vimproc#system(args)
endfunction

function! unite#taskwarrior#run(task, cmd, ...)
  let task = unite#taskwarrior#new(a:task)
  let args = [l:task.uuid, a:cmd]
  call extend(args, a:000)
  return unite#taskwarrior#call(args)
endfunction

function! unite#taskwarrior#init()
  let directory = unite#taskwarrior#config('note_directory')
  if !isdirectory(directory)
    call mkdir(directory, 'p')
  endif
endfunction

function! unite#taskwarrior#load_config(filename)
  let file = vimproc#open(a:filename)
  let lines = file.read()
  return eval(lines)
endfunction

function! unite#taskwarrior#filter(strings, project, ...)
  let filters = []
  for entry in a:strings
    if strpart(entry, 0, 1) == '@'
      call add(filters, 'tag:' . strpart(entry, 1))
    endif
    if strpart(entry, 0, 1) == '$'
      let name = strpart(entry, 1)
      if name == ''
        call add(filters, 'project:')
      else
        call add(filters, 'project.is:' . name)
      endif
    endif
  endfor

  if a:000 != []
    call extend(filters, a:000)
  else
    if type(unite#taskwarrior#config('filter')) == type([])
      call extend(filters, unite#taskwarrior#config('filter'))
    else
      call add(filters, unite#taskwarrior#config('filter'))
    endif
  endif

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
  let status = get(unite#taskwarrior#config('status_mapping'), a:task.status, '?')
  if filereadable(a:task.note)
    call add(tags, unite#taskwarrior#config('tags_abbr') . "NOTE")
  endif

  let formatted = printf(unite#taskwarrior#config('format_string'),
        \ status,
        \ project,
        \ a:task.description,
        \ join(tags, ' '))

  if unite#taskwarrior#config('show_annotations')
    let annotations = join(
          \ map(a:task.annotations, 'printf("%20s%s", " ", v:val.description)'),
          \ "\n")

    if !empty(annotations)
      let formatted = printf("%s\n%s", formatted, annotations)
    endif
  endif

  return formatted
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
  if stridx(a:raw, "The") == 0
    return {}
  endif

  let line = substitute(a:raw, "\n$", "", "")
  let parsed = s:JSON.decode(a:raw)
  if type(parsed) == type([])
    return map(parsed, 'unite#taskwarrior#defaults(v:val)')
  endif

  return unite#taskwarrior#defaults(parsed)
endfunction

function! unite#taskwarrior#defaults(parsed) abort
  let data = extend(unite#taskwarrior#new_dict(a:parsed.description), a:parsed)
  let data.note = printf('%s/%s.%s',
        \ unite#taskwarrior#config('note_directory'),
        \ strpart(data.uuid, 0, 8),
        \ unite#taskwarrior#config('note_suffix'))

  let data.short = strpart(data.uuid, 0, 8)
  let data.uri = printf(unite#taskwarrior#config('uri_format'), data.uuid)
  let deps = get(data, 'depends', [])
  if type(deps) == type('')
    let data.depends = split(deps, ',')
  else
    let data.depends = deps
  endif

  let data.started = has_key(data, 'start')
  let data.stopped = !data.started

  return data
endfunction

function! unite#taskwarrior#is_empty(task) abort
  return get(a:task, 'uuid', '') != ''
endfunction

function! unite#taskwarrior#new_dict(raw) abort
  let desc = a:raw
  if type(desc) == type([])
    let desc = join(desc, ' ')
  endif

  return {
        \ 'description': desc,
        \ 'depends': '',
        \ 'status': 'unknown',
        \ 'tags': [],
        \ 'project': '',
        \ 'annotations': [],
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

function! unite#taskwarrior#select(pattern)
  let raw = ''
  if type(a:pattern) == type([])
    let args = extend(['export'], a:pattern)
    let raw = unite#taskwarrior#call(args)
  elseif type(a:pattern) == type('')
    let raw = unite#taskwarrior#call('export ' . a:pattern)
  endif

  let data = []
  try
    let data = s:JSON.decode(raw)
    let data = map(data, 'unite#taskwarrior#defaults(v:val)')
  catch
    try
      let lines = split(raw, "\n")
      let data = map(lines, 'unite#taskwarrior#parse(v:val)')
    catch
      " call unite#print_error("Could not parse taskwarrior output")
      return []
    endtry
  endtry

  let filtered = filter(copy(data), 'unite#taskwarrior#is_empty(v:val)')
  if len(filtered) != len(data)
    " call unite#print_error("Could not parse all taskwarrior output")
    return []
  endif

  return filtered
endfunction

function! unite#taskwarrior#all()
  return unite#taskwarrior#select([])
endfunction

function! unite#taskwarrior#new(data)
  if type(a:data) == type([])
    let args = ["add"]
    call unite#taskwarrior#call(extend(args, unite#taskwarrior#flatten(a:data)))
  elseif type(a:data) == type("")
    call unite#taskwarrior#call('add ' . a:data)
    let args = 'add ' . a:data
  elseif type(a:data) == type({})
    if a:data.status != 'unknown'
      return a:data
    endif
    call unite#taskwarrior#call('add ' . a:data.description)
  endif
  return unite#taskwarrior#newest()
endfunction

function! unite#taskwarrior#newest() abort
  let tasks = split(unite#taskwarrior#call("newest"), "\n")
  let task_id = split(tasks[2])[0]
  let raw = unite#taskwarrior#call(["export", task_id])
  let parsed = unite#taskwarrior#parse(raw)
  if type(parsed) == type([])
    return parsed[0]
  endif
  return parsed
endfunction

function! unite#taskwarrior#input(args, use_range, line1, line2)
  if a:use_range
    let lines = join(getline(a:line1, a:line2))
    call unite#taskwarrior#new(split(lines))
  elseif a:args == ""
    call unite#taskwarrior#new(input('Task: '))
  else
    call unite#taskwarrior#new(a:args)
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

function! unite#taskwarrior#edit_tags(task, tags) abort
  let args = [a:task, 'modify']
  call extend(args, a:tags)
  return call('unite#taskwarrior#run', args)
endfunction

function! unite#taskwarrior#rename(task)
  return unite#taskwarrior#modify(a:task, "description:'" . a:task.description . "'")
endfunction

function! unite#taskwarrior#open(task)
  let task = unite#taskwarrior#new(a:task)
  if !filereadable(l:task.note)
    let content = call(unite#taskwarrior#config('note_formatter'), [l:task])
    call writefile(content, l:task.note)
  endif
  execute ':edit ' . l:task.note
endfunction

function! unite#taskwarrior#toggle(task)
  if get(a:task, 'status') == 'unknown'
    return unite#taskwarrior#new(a:task)
  endif

  let a:task.status = get(unite#taskwarrior#config('toggle_mapping'),
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
  return unite#taskwarrior#call(['undo'])
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

function! unite#taskwarrior#bindings() abort
  nnoremap <silent><buffer><expr> <TAB>       unite#do_action('toggle')
  nnoremap <silent><buffer><expr> <CR>        unite#do_action('view')
  nnoremap <silent><buffer><expr> <BS>        unite#do_action('previous')
  nnoremap <silent><buffer><expr> <C-D>       unite#do_action('add_dependency')
  nnoremap <silent><buffer><expr> d           unite#do_action('do')
  nnoremap <silent><buffer><expr> D           unite#do_action('delete')
  nnoremap <silent><buffer><expr> P           unite#do_action('edit_proj')
  nnoremap <silent><buffer><expr> A           unite#do_action('annotate')
  nnoremap <silent><buffer><expr> m           unite#do_action('modify')
  nnoremap <silent><buffer><expr> e           unite#do_action('edit')
  nnoremap <silent><buffer><expr> u           unite#do_action('undo')
  nnoremap <silent><buffer><expr> +           unite#do_action('start')
  nnoremap <silent><buffer><expr> -           unite#do_action('stop')
endfunction

function! unite#taskwarrior#depends(task, parents) abort
  if type(a:parents) == type([])
    let parent_ids = join(a:parents, ',')
  endif
  return unite#taskwarrior#call([parent_ids, 'modify', 'depends:' . a:task.uuid])
endfunction

function! unite#taskwarrior#count(query) abort
  let result = unite#taskwarrior#call(printf('%s %s', a:query, ' count'))
  return str2nr(result)
endfunction

function! unite#taskwarrior#version() abort
  return '0.0.1'
endfunction

function! unite#taskwarrior#similar(tasks)
  let tags = []
  for task in a:tasks
    for tag in task.tags
      call add(tags, 'tag:' . strpart(tag, 1))
    endfor
  endfor
  let projects = join(map(a:tasks, '"project:" . v:val.project'), " or ")

  return printf("( %s ) and ( %s )", projects, join(tags, ' or '))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
