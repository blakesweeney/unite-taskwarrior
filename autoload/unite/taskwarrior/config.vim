let s:save_cpo = &cpo
set cpo&vim

let s:DEFAULTS = {
      \ 'command': "task",
      \ 'note_directory': '~/.task/note',
      \ 'note_suffix': 'mkd',
      \ 'note_formatter': 'unite#taskwarrior#formatters#simple',
      \ 'notes_header_lines': 1,
      \ "formatter": 'unite#taskwarrior#formatters#simple',
      \ "tag_formatter": 'unite#taskwarrior#formatters#named',
      \ "project_formatter": 'unite#taskwarrior#formatters#named',
      \ 'context_formatter': 'unite#taskwarrior#formatters#named_status',
      \ 'setting_formatter': 'unite#taskwarrior#formatters#named',
      \ 'config_formatter': 'unite#taskwarrior#formatters#named',
      \ 'annotation_formatter': 'unite#taskwarrior#formatters#flipped',
      \ 'filter': 'status.not:deleted',
      \ 'toggle_mapping': { 
      \   'pending': 'completed', 
      \   'completed': 'deleted',
      \   'deleted': 'pending'
      \ },
      \ "status_mapping": { 
      \   'active_context': '@',
      \   'active': '#',
      \   'inactive': ' ',
      \   'pending': ' ', 
      \   'deleted': 'D',
      \   'completed': 'X',
      \   'waiting': 'W',
      \   'recurring': 'R',
      \   'started': 'S',
      \   'unknown': 'N',
      \ },
      \ "tags_abbr": "+",
      \ "fallback_match": "matcher_fuzzy",
      \ 'uri_format': '<task:%s>',
      \ 'missing_project': '(none)',
      \ 'show_annotations': 1,
      \ 'group_annotations_by': 'time',
      \ 'annotation_precision': 2,
      \ 'use_taskwiki': 0,
      \ 'respect_context': 0,
      \ 'wiki_root': $HOME . '.vim/wiki',
      \ 'define_mappings': 0,
      \ 'preview_action': 'preview_info',
      \ 'prompt_on_toggle': 1,
      \ 'default_ordering': "urgency-",
      \ 'sort_orders': {}
      \ }

let s:config = deepcopy(s:DEFAULTS)

let s:PREFIX = 'unite_taskwarrior_'

function! s:lookup(dict, key) abort
  if type(a:dict) != type({}) || empty(a:key)
    return a:dict
  endif

  return s:lookup(a:dict[remove(a:key, 0)], a:key)
endfunction

function! s:define(dict, key, value) abort
  if len(a:key) == 1
    let a:dict[a:key[0]] = a:value
    return a:dict
  endif

  let head = remove(a:key, 0)
  let current = a:dict[head]
  return extend(current, s:define(current, a:key, a:value))
endfunction

function! s:flatten(dict) abort
  let pairs = []
  for key in keys(a:dict)
    let value = a:dict[key]

    if type({}) == type(value)
      let subpairs = s:flatten(value)

      for pair in subpairs
        let name = printf('%s.%s', key, pair.name)
        call add(pairs, {'name': name, 'value': pair.value})
      endfor

    else
      call add(pairs, {'name': key, 'value': value})
    endif

    unlet value
  endfor

  return pairs
endfunction

function! unite#taskwarrior#config#short_key(key) abort
  return substitute(a:key, s:PREFIX, '', '')
endfunction

function! unite#taskwarrior#config#set(key, ...) abort
  if type(a:key) == type({})
    return extend(s:config, a:key)
  end

  let name = unite#taskwarrior#config#short_key(a:key)
  let parts = split(name, '\.')
  call s:define(s:config, parts, a:1)
endfunction

function! unite#taskwarrior#config#get(key) abort
  let name = unite#taskwarrior#config#short_key(a:key)
  let long = s:PREFIX . name
  let value = get(b:, long, get(g:, long, s:lookup(s:config, split(name, '\.'))))

  if name == 'note_directory' || name == 'wiki_root'
    let value = expand(value)
  endif

  if name == 'note_formatter' && unite#taskwarrior#config('use_taskwiki')
    let value = 'unite#taskwarrior#formatters#taskwiki'
  endif

  if name == 'sort_orders'
    let value = extend(get(g:, 'taskwiki_sort_orders', {}), value)
  endif

  return value
endfunction

function! unite#taskwarrior#config#reset(...)
  if empty(a:000)
    let s:config = deepcopy(s:DEFAULTS)
  else
    for key in unite#taskwarrior#flatten(a:000)
      let short = unite#taskwarrior#config#short_key(key)
      call unite#taskwarrior#config#set(key, s:DEFAULTS[short])
    endfor
  endif
endfunction

function! unite#taskwarrior#config#defaults() abort
  return deepcopy(s:DEFAULTS)
endfunction

function! unite#taskwarrior#config#current() abort
  let config = {}
  for key in keys(s:config)
    let config[key] = unite#taskwarrior#config#get(key)
  endfor

  return config
endfunction

function! unite#taskwarrior#config#as_list() abort

  let defaults = {}
  for pair in s:flatten(s:DEFAULTS)
    let defaults[pair.name] = pair.value
    unlet pair
  endfor

  let config = []
  for pair in s:flatten(s:config)
    let status = defaults[pair.name] == pair.value ? 'default' : 'modified'

    call add(config, {
          \ 'name': pair.name,
          \ 'value': pair.value,
          \ 'status': status
          \ })

    unlet pair
  endfor

  return config
endfunction

function! unite#taskwarrior#config#format(config, summary) abort
  let formatter = unite#taskwarrior#config#get('config_formatter')
  return call(formatter, [a:config, a:summary])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
