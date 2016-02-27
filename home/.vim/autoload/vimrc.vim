let s:is_windows = has('win16') || has('win32') || has('win64')
let s:path_delimiter = s:is_windows ? ';' : ':'

function! vimrc#prepend_envpath(name, pathlist) abort
  let pathlist = split(eval(a:name), s:path_delimiter)
  for path in map(filter(a:pathlist, 'v:val'), 'expand(v:val)')
    if isdirectory(path) && index(pathlist, path) == -1
      call insert(pathlist, path, 0)
    endif
  endfor
  execute printf('let %s = join(pathlist, s:path_delimiter)', a:name)
endfunction

function! vimrc#pick_path(pathlist, ...) abort
  for path in map(filter(a:pathlist, 'v:val'), 'expand(v:val)')
    if isdirectory(path)
      return path
    endif
  endfor
  return ''
endfunction

function! vimrc#ensure_path(path, ...) abort
  let path = expand(a:path)
  if !isdirectory(path)
    call mkdir(path, 'p', get(a:000, 0, 0700))
  endif
endfunction

function! vimrc#source_path(path) abort
  let path = expand(a:path)
  if filereadable(path)
    execute printf('source %s', fnameescape(path))
  endif
endfunction
