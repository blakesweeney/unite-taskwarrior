scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:defaults = {
      \ 'command': "task",
      \ 'note_directory': '~/.task/note',
      \ 'note_suffix': 'mkd',
      \ 'note_formatter': 'unite#taskwarrior#formatters#simple',
      \ 'notes_header_lines': 1,
      \ "format_string": "[%s] %15s\t%s (%s)",
      \ "formatter": 'unite#taskwarrior#formatters#simple',
      \ "tag_formatter": 'unite#taskwarrior#formatters#named',
      \ "project_formatter": 'unite#taskwarrior#formatters#named',
      \ 'context_formatter': 'unite#taskwarrior#formatters#named_status',
      \ 'setting_formatter': 'unite#taskwarrior#formatters#named',
      \ 'filter': 'status.not:deleted',
      \ 'toggle_mapping': { 'pending': 'completed', 'completed': 'pending' },
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
      \ "projects_abbr": "$",
      \ "tags_abbr": "+",
      \ "fallback_match": "matcher_fuzzy",
      \ 'uri_format': '<task:%s>',
      \ 'missing_project': '(none)',
      \ 'show_annotations': 1,
      \ 'group_annotations_by': 'time',
      \ 'annotation_precision': 2,
      \ 'use_taskwiki': 0,
      \ 'respect_context': 0,
      \ 'wiki_root': $HOME . '.vim/wiki'
      \ }

let s:config = deepcopy(s:defaults)

function! unite#taskwarrior#config#set(key, ...) abort
  if type(a:key) == type({})
    return deepcopy(extend(s:config, a:key))
  endif

  let prefix = 'unite_taskwarrior_'
  let key_name = substitute(a:key, prefix, '', '')
  let s:config[key_name] = a:1

  return deepcopy(s:config)
endfunction

function! unite#taskwarrior#config#get(key) abort
  let prefix = 'unite_taskwarrior_'
  let name = substitute(a:key, prefix, '', "")

  let value = get(g:, prefix . name, s:config[name])

  if name == 'note_directory' || name == 'wiki_root'
    let value = expand(value)
  endif

  if name == 'note_formatter'
        \ && unite#taskwarrior#config('use_taskwiki')
    let value = 'unite#taskwarrior#formatters#taskwiki'
  endif

  return value
endfunction

function! unite#taskwarrior#config#reset()
  let s:config = deepcopy(s:defaults)
endfunction

function! unite#taskwarrior#config#defaults() abort
  return deepcopy(s:defaults)
endfunction

function! unite#taskwarrior#config#current() abort
  return deepcopy(s:config)
endfunction

function! unite#taskwarrior#config#as_list() abort
  let config = []
  for key in keys(s:config)
    call add(config, {
          \ 'key': key,
          \ 'value': s:config[key],
          \ 'is_default': s:config[key] == get(s:defaults[key], '')
          \ })
    unlet key
  endfor
  return config
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
