scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite_taskwarrior')
let s:JSON = s:V.load('Web.JSON')
let s:JSON = s:JSON.Web.JSON

function! unite#taskwarrior#config(...) abort
  if empty(a:000)
    return unite#taskwarrior#config#current()
  endif

  if a:0 == 1 && type({}) != type(a:1)
    return unite#taskwarrior#config#get(a:1)
  endif

  return call('unite#taskwarrior#config#set', a:000)
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

function! unite#taskwarrior#format(task, summary)
  let formatter = unite#taskwarrior#config('formatter')
  return call(formatter, [a:task, a:summary])
endfunction

function! unite#taskwarrior#parse(raw)
  if stridx(a:raw, "The") == 0 || empty(a:raw)
    return {}
  endif

  let line = substitute(a:raw, "\n$", "", "")
  try
    let parsed = s:JSON.decode(a:raw)
  catch
    let lines = split(a:raw, "\n")
    try
      let parsed = map(lines, 's:JSON.decode(v:val)')
    catch
      throw printf("Could not parse taskwarrior output: '%s' (%s)",
            \ a:raw, string(v:exception))
    endtry
  endtry

  if type(parsed) == type([])
    return map(parsed, 'unite#taskwarrior#defaults(v:val)')
  endif

  return unite#taskwarrior#defaults(parsed)
endfunction

function! unite#taskwarrior#defaults(parsed) abort
  let desc = get(a:parsed, 'description', '')
  let data = extend(unite#taskwarrior#new_dict(desc), a:parsed)
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
  call unite#taskwarrior#edit_tags(task, ['+note'])
  if !filereadable(l:task.note)
    let content = unite#taskwarrior#notes#format(l:task)
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

function! unite#taskwarrior#base_mappings() abort
  nnoremap <silent><buffer><expr> <BS>        unite#do_action('previous')
endfunction

function! unite#taskwarrior#bindings() abort
  call unite#taskwarrior#base_mappings()
  nnoremap <silent><buffer><expr> <TAB>       unite#do_action('toggle')
  nnoremap <silent><buffer><expr> <CR>        unite#do_action('view')
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
  let result = unite#taskwarrior#call([a:query, 'count'])
  return str2nr(result)
endfunction

function! unite#taskwarrior#version() abort
  return '0.0.1'
endfunction

function! unite#taskwarrior#similar(tasks)
  let filt = unite#taskwarrior#filters#new()
  for task in a:tasks
    let filt = filt.tags(task.tags)
    let filt = filt.projects(task.project)
  endfor

  return filt.str()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
