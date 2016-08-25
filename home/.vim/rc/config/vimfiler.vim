let g:vimfiler_as_default_explorer = 1
let g:vimfiler_ignore_pattern = printf('\%%(%s\)', join([
      \ '^\..*',
      \ '\.pyc$',
      \ '^__pycache__$',
      \ '\.egg-info$',
      \], '\|'))

call vimfiler#custom#profile('default', 'context', {
      \ 'auto_cd': 1,
      \ 'parent': 1,
      \ 'safe': 0,
      \ })

function! s:configure_vimfiler() abort
  " use 'J' to select candidates instead of <Space> / <S-Space>
  silent! nunmap <buffer> <Space>
  silent! nunmap <buffer> <S-Space>
  silent! vunmap <buffer> <Space>
  nmap <buffer> J <Plug>(vimfiler_toggle_mark_current_line)
  vmap <buffer> J <Plug>(vimfiler_toggle_mark_selected_lines)
  " ^^ to go parent directory
  nmap <buffer> ^^ <Plug>(vimfiler_switch_to_parent_directory)
  " X to execute on the directory
  nmap <buffer> X
        \ <Plug>(vimfiler_switch_to_parent_directory)
        \ <Plug>(vimfiler_execute_system_associated)
        \ <Plug>(vimfiler_execute)
  " t to open tab
  nnoremap <buffer><silent> <Plug>(vimfiler_tab_edit_file)
        \ :<C-u>call vimfiler#mappings#do_action(b:vimfiler, 'tabopen')<CR>
  nmap <buffer> t <Plug>(vimfiler_tab_edit_file)
  " <Space>k to open bookmark
  nmap <buffer><silent> <Space>k :<C-u>Unite bookmark<CR>
endfunction
autocmd MyAutoCmd FileType vimfiler call s:configure_vimfiler()

function! s:cd_all_vimfiler(path) abort
  let current_nr = winnr()
  try
    for winnr in filter(range(1, winnr('$')),
          \ "getwinvar(v:val, '&filetype') ==# 'vimfiler'")
      call vimfiler#util#winmove(winnr)
      call vimfiler#mappings#cd(a:path)
    endfor
  finally
    call vimfiler#util#winmove(current_nr)
  endtry
endfunction
autocmd MyAutoCmd User my-workon-post call s:cd_all_vimfiler(getcwd())

" XXX: This is a work around
" Note:
"   Somehow, &winfixwidth of a buffer opened from VimFilerExplorer is set to
"   1 and thus <C-w>= or those kind of command doesn't work.
"   This work around stands for fixing that.
function! s:force_nofixwidth() abort
  if &buftype =~# '^\%(\|nowrite\|acwrite\)$'
    setlocal nowinfixwidth
  endif
endfunction
autocmd MyAutoCmd BufWinEnter * call s:force_nofixwidth()

" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
