scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! s:append_to_entry(filter, name, value, ...) abort

  if empty(a:value)
    return a:filter
  endif

  let prefix = get(a:000, 0, '')

  let terms = type(a:value) == type([]) ? a:value : [a:value]
  for term in terms
    if empty(prefix)
      call add(a:filter[a:name], term)
    else
      if strpart(term, 0, 1) != prefix
        let term = prefix . term
      end
      call add(a:filter[a:name], term)
    endif
  endfor

  return a:filter
endfunction

function! s:set_entry(filter, name, value, ...) abort
  if empty(a:value)
    return a:filter
  endif
  let prefix = get(a:000, 0, '')

  let term = type(a:value) == type([]) ? a:value[-1] : a:value
  if !empty(prefix) && strpart(term, 0, 1) != prefix
    let term = prefix . term
  endif

  let a:filter[a:name] = term
  return a:filter
endfunction

function! unite#taskwarrior#filters#from_source(args, options) abort
  let processed = {}

  if get(a:options, 'custom_infer_project', 0)
    let processed.infer_project = 1
  endif

  if has_key(a:options, 'custom_filter')
    let processed.ignore_filter = 1
  endif

  if has_key(a:options, 'custom_ignore_filter')
    let processed.ignore_filter = 1
  endif

  let filt = unite#taskwarrior#filters#new(processed)

  if has_key(a:options, 'custom_filter')
    let filt = filt.raw(a:options.custom_filter)
  endif

  for arg in a:args
    let head = strpart(arg, 0, 1)
    if head == '+'
      let filt = filt.tags(arg)
    elseif head == '@'
      let filt = filt.context(arg)
    else
      let filt = filt.projects(arg)
    endif
  endfor

  return filt
endfunction

function! unite#taskwarrior#filters#new(...) abort
  let options = get(a:000, 0, {})
  let obj = {'_projects': [], '_tags': [], '_raw': [], '_context': ''}

  function! obj.projects(value) abort
    return s:append_to_entry(self, '_projects', a:value)
  endfunction

  function! obj.tags(value) abort
    return s:append_to_entry(self, '_tags', a:value, '+')
  endfunction

  function! obj.context(value) abort
    return s:set_entry(self, '_context', a:value, '@')
  endfunction

  function! obj.raw(value) abort
    return s:append_to_entry(self, '_raw', a:value)
  endfunction

  function! obj.current_context() abort
    return self.context('@')
  endfunction

  function! obj.array() abort
    let parts = []

    if !empty(self._projects)
      let projects = map(self._projects, '"project.is:" . v:val')
      call add(parts, join(projects, ' or '))
    endif

    if !empty(self._tags)
      call add(parts, join(self._tags, ' or '))
    endif

    if !empty(self._raw)
      call add(parts, join(self._raw, ' and '))
    endif

    if !empty(self._context)
      let context = self._context == '@' ? 
            \ unite#taskwarrior#context#current() :
            \ unite#taskwarrior#context#get(self._context)
      let def = get(context, 'definition', '')
      if !empty(def)
        call add(parts, def)
      endif
    endif

    return parts
  endfunction

  function! obj.str() abort
    let parts = map(self.array(), 'printf("( %s )", v:val)')
    return join(parts, ' and ')
  endfunction

  if get(options, 'context')
    let obj = obj.context(options.context)
  elseif unite#taskwarrior#config('respect_context')
    let obj  = obj.current_context()
  endif

  if get(options, 'infer_project')
    let current = fnamemodify(getcwd(), ":t")
    let obj = obj.projects(current)
  endif

  let obj = obj.projects(get(options, 'projects', []))
  let obj = obj.tags(get(options, 'tags', []))
  let obj = obj.raw(get(options, 'raw', []))

  if !get(options, 'ignore_filter')
    let obj = obj.raw(unite#taskwarrior#config('filter'))
  endif

  return obj
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
