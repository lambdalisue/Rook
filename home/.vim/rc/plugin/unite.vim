scriptencoding utf-8

" grep
if executable('hw')
  " Use hw (highway)
  " https://github.com/tkengo/highway
  let g:unite_source_grep_command = 'hw'
  let g:unite_source_grep_default_opts = '--no-group --no-color'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ag')
  " Use ag (the silver searcher)
  " https://github.com/ggreer/the_silver_searcher
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts =
        \ '-i --vimgrep --hidden --ignore ' .
        \ '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
  let g:unite_source_grep_recursive_opt = ''
elseif executable('pt')
  " Use pt (the platinum searcher)
  " https://github.com/monochromegane/the_platinum_searcher
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('ack-grep')
  " Use ack
  " http://beyondgrep.com/
  let g:unite_source_grep_command = 'ack-grep'
  let g:unite_source_grep_default_opts =
        \ '-i --no-heading --no-color -k -H'
  let g:unite_source_grep_recursive_opt = ''
elseif executable('jvgrep')
  " Use jvgrep
  " https://github.com/mattn/jvgrep
  let g:unite_source_grep_command = 'jvgrep'
  let g:unite_source_grep_default_opts =
        \ '-i --exclude ''\.(git|svn|hg|bzr)'''
  let g:unite_source_grep_recursive_opt = '-R'
endif
if has('multi_byte') && $LANG !=# 'C'
  let config = {
        \ 'prompt': '» ',
        \ 'candidate_icon': '⋮',
        \ 'marked_icon': '✓',
        \ 'no_hide_icon': 1,
        \}
else
  let config = {
        \ 'prompt': '> ',
        \ 'candidate_icon': ' ',
        \ 'marked_icon': '*',
        \}
endif
call unite#custom#profile('source/bookmark', 'context', {
      \ 'no_start_insert': 1,
      \})
call unite#custom#profile('source/output', 'context', {
      \ 'no_start_insert': 1,
      \})
call unite#custom#profile('source/giti', 'context', {
      \ 'no_start_insert': 1,
      \})
call unite#custom#profile('source/menu', 'context', {
      \ 'no_start_insert': 1,
      \})
call unite#custom#profile('default', 'context', extend(config, {
      \ 'start_insert': 1,
      \ 'no_empty': 1,
      \}))
call unite#custom#default_action('directory', 'cd')
call unite#custom#alias('file', 'edit', 'open')

if neobundle#is_installed('agit.vim')
  " add unite interface
  let agit = {
        \ 'description': 'open the directory (or parent directory) in agit',
        \ }
  function! agit.func(candidate) abort
    if isdirectory(a:candidate.action__path)
      let path = a:candidate.action__path
    else
      let path = fnamemodify(a:candidate.action__path, ':h')
    endif
    execute 'Agit' '--dir=' . path
  endfunction

  let agit_file = {
        \ 'description': "open the file's history in agit.vim",
        \ }
  function! agit_file.func(candidate) abort
    execute 'AgitFile' '--file=' . a:candidate.action__path
  endfunction

  call unite#custom#action('file,cdable', 'agit', agit)
  call unite#custom#action('file', 'agit_file', agit_file)
endif

function! s:configure_unite() abort
  let unite = unite#get_current_unite()

  " map 'r' to 'replace' or 'rename' action
  if unite.profile_name ==# 'search'
    nnoremap <silent><buffer><expr><nowait> r
          \ unite#smart_map('r', unite#do_action('replace'))
  else
    nnoremap <silent><buffer><expr><nowait> r
          \ unite#smart_map('r', unite#do_action('rename'))
  endif

  " 'J' to select candidate instead of <Space> / <S-Space>
  nunmap <buffer> <Space>
  vunmap <buffer> <Space>
  nunmap <buffer> <S-Space>
  nmap <buffer><nowait> J <Plug>(unite_toggle_mark_current_candidate)
  vmap <buffer><nowait> J <Plug>(unite_toggle_mark_selected_candidate)

  " 'E' to open right
  nnoremap <silent><buffer><expr><nowait> E
        \ unite#smart_map('E', unite#do_action('right'))

  " force winfixheight
  setlocal winfixheight
endfunction
autocmd MyAutoCmd FileType unite call s:configure_unite()

function! s:register_filemenu(name, description, precursors) abort " {{{
  " find the length of the longest name
  let max_length = max(map(
        \ filter(deepcopy(a:precursors), 'len(v:val) > 1'),
        \ 'len(v:val[0])'
        \))
  let format = printf('%%-%ds : %%s', max_length)
  let candidates = []
  for precursor in a:precursors
    if len(precursor) == 1
      call add(candidates, [
            \ precursor[0],
            \ '',
            \])
    elseif len(precursor) >= 2
      let name = precursor[0]
      let desc = precursor[1]
      let path = get(precursor, 2, '')
      let path = resolve(expand(empty(path) ? desc : path))
      let kind = isdirectory(path) ? 'directory' : 'file'
      call add(candidates, [
            \ printf(format, name, desc),
            \ path,
            \])
    else
      let msg = printf(
            \ 'A candidate precursor must has 1 or more than two terms : %s',
            \ string(precursor)
            \)
      call add(candidates, [
            \ 'ERROR : ' . msg,
            \ '',
            \])
    endif
  endfor

  let menu = {}
  let menu.candidates = candidates
  let menu.description = a:description
  let menu.separator_length = max(map(
        \ deepcopy(candidates),
        \ 'len(v:val[0])',
        \))
  if menu.separator_length % 2 != 0
    let menu.separator_length += 1
  endif
  function! menu.map(key, value) abort
    let word = a:value[0]
    let path = a:value[1]
    if empty(path)
      if word ==# '-'
        let word = repeat('-', self.separator_length)
      else
        let length = self.separator_length - (len(word) + 3)
        let word = printf('- %s %s', word, repeat('-', length))
      endif
      return {
            \ 'word': '',
            \ 'abbr': word,
            \ 'kind': 'common',
            \ 'is_dummy': 1,
            \}
    else
      let kind = isdirectory(path) ? 'directory' : 'file'
      let directory = isdirectory(path) ? path : fnamemodify(path, ':h')
      return {
            \ 'word': word,
            \ 'abbr': printf('[%s] %s', toupper(kind[0]), word),
            \ 'kind': kind,
            \ 'action__path': path,
            \ 'action__directory': directory,
            \}
    endif
  endfunction

  " register to 'g:unite_source_menu_menus'
  let g:unite_source_menu_menus = get(g:, 'unite_source_menu_menus', {})
  let g:unite_source_menu_menus[a:name] = menu
endfunction " }}}
call s:register_filemenu('shortcut', 'Shortcut menu', [
      \ ['rook'],
      \ [
      \   'rook',
      \   '~/.homesick/repos/rook',
      \ ],
      \ ['vim'],
      \ [
      \   'vimrc',
      \   fnamemodify($MYVIMRC, ':~'),
      \ ],
      \ [
      \   'gvimrc',
      \   fnamemodify($MYGVIMRC, ':~'),
      \ ],
      \ [
      \   'autoload/rook.vim',
      \   fnamemodify(rook#normpath('autoload/rook.vim'), ':~'),
      \ ],
      \ [
      \   'ftdetect/ftdetect.vim',
      \   fnamemodify(rook#normpath('ftdetect/ftdetect.vim'), ':~'),
      \ ],
      \ [
      \   'rc/plugin.vim',
      \   fnamemodify(rook#normpath('rc/plugin.vim'), ':~'),
      \ ],
      \ [
      \   'rc/plugin.define.toml',
      \   fnamemodify(rook#normpath('rc/plugin.define.toml'), ':~'),
      \ ],
      \ [
      \   'rc/plugin.config.vim',
      \   fnamemodify(rook#normpath('rc/plugin.config.vim'), ':~'),
      \ ],
      \ [
      \   'rc/plugin/lightline.vim',
      \   fnamemodify(rook#normpath('rc/plugin/lightline.vim'), ':~'),
      \ ],
      \ [
      \   'rc/plugin/unite.vim',
      \   fnamemodify(rook#normpath('rc/plugin/unite.vim'), ':~'),
      \ ],
      \ [
      \   'rc/plugin/vimfiler.vim',
      \   fnamemodify(rook#normpath('rc/plugin/vimfiler.vim'), ':~'),
      \ ],
      \ [
      \   'rc/plugin/vimshell.vim',
      \   fnamemodify(rook#normpath('rc/plugin/vimshell.vim'), ':~'),
      \ ],
      \ [
      \   'vim',
      \   expand('~/.vim'),
      \ ],
      \ ['zsh'],
      \ [
      \   'zshrc',
      \   '~/.config/zsh/.zshrc',
      \ ],
      \ [
      \   'rc/theme.dust.zsh',
      \   '~/.config/zsh/rc/theme.dust.zsh',
      \ ],
      \ [
      \   'rc/configure.applications.zsh',
      \   '~/.config/zsh/rc/configure.applications.zsh',
      \ ],
      \ [
      \   'zsh',
      \   '~/.config/zsh',
      \ ],
      \ ['tmux'],
      \ [
      \   'tmux.conf',
      \   '~/.tmux.conf',
      \ ],
      \ [
      \   'tmux.osx.conf',
      \   '~/.tmux.osx.conf',
      \ ],
      \ [
      \   'tmux',
      \   '~/.config/tmux',
      \ ],
      \])
