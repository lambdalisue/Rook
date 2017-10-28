" <C-z> is used in tmux so remap it to <C-s>
call denite#custom#map('_', '<C-s>', '<denite:suspend>', 'noremap')

" Use C-n/C-p to select candidates
call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')

" Swap C-g/Down C-t/Up
call denite#custom#map('insert', '<C-g>', '<denite:assign_next_matched_text>', 'noremap')
call denite#custom#map('insert', '<C-t>', '<denite:assign_previous_matched_text>', 'noremap')
call denite#custom#map('insert', '<Down>', '<denite:assign_next_text>', 'noremap')
call denite#custom#map('insert', '<Up>', '<denite:assign_previous_text>', 'noremap')

" Emacs like mapping
call denite#custom#map('insert', '<C-f>', '<Right>')
call denite#custom#map('insert', '<C-b>', '<Left>')
call denite#custom#map('insert', '<C-a>', '<Home>')
call denite#custom#map('insert', '<C-e>', '<End>')
call denite#custom#map('insert', '<C-d>', '<Del>')

" Use <C-Space> to select candidate in insert mode
call denite#custom#map('insert', '<C-@>', '<denite:toggle_select_down>', 'noremap')
call denite#custom#map('insert', '<C-Space>', '<denite:toggle_select_down>', 'noremap')

" grep
if executable('pt')
  " Use pt (the platinum searcher)
  " https://github.com/monochromegane/the_platinum_searcher
  call denite#custom#var('grep', 'command', ['pt'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('grep', 'separator', [])
  call denite#custom#var('grep', 'default_opts', [
        \ '--nocolor', '--nogroup', '--column',
        \])
endif

call denite#custom#option('_', 'cursor_wrap', v:true)

function! s:build_filemenu(description, precursors) abort
  let candidates = []
  for precursor in a:precursors
    if type(precursor) == type('')
      call add(candidates, [precursor, expand(precursor)])
    else
      call add(candidates, precursor)
    endif
  endfor
  let menu = {'description': a:description}
  let menu.file_candidates = candidates
  return menu
endfunction

let s:menus = {}
let s:menus.shortcut = s:build_filemenu('Shortcut menu:', [
      \ '~/.homesick/repos/rook',
      \ '~/Code/github.com/lambdalisue',
      \ '$MYVIM_HOME/',
      \ '$MYVIM_HOME/ftplugin/',
      \ '$MYVIM_HOME/syntax/',
      \ '$MYVIM_HOME/template/',
      \ '~/.vimrc.local',
      \ '~/.gvimrc.local',
      \ '$MYVIM_HOME/init.vim',
      \ '$MYVIM_HOME/ginit.vim',
      \ '$MYVIM_HOME/vimrc.min',
      \ '$MYVIM_HOME/filetype.vim',
      \ '$MYVIM_HOME/rc.d/gina.vim',
      \ '$MYVIM_HOME/rc.d/dein.toml',
      \ '$MYVIM_HOME/rc.d/unite.vim',
      \ '$MYVIM_HOME/rc.d/denite.vim',
      \ '$MYVIM_HOME/rc.d/lexima.vim',
      \ '$MYVIM_HOME/rc.d/vimfiler.vim',
      \ '$MYVIM_HOME/rc.d/vimshell.vim',
      \ '$MYVIM_HOME/rc.d/lightline.vim',
      \ '$MYVIM_HOME/rc.d/quickrun.vim',
      \ '$MYVIM_HOME/after/ftplugin/vim.vim',
      \ '$MYVIM_HOME/after/ftplugin/perl.vim',
      \ '$MYVIM_HOME/after/ftplugin/python.vim',
      \ '$MYVIM_HOME/after/ftplugin/jason.vim',
      \ '$MYVIM_HOME/after/ftplugin/javascript.vim',
      \ '$MYVIM_HOME/after/ftplugin/typescript.vim',
      \ '$MYVIM_HOME/after/ftplugin/xslate.vim',
      \ '$MYVIM_HOME/after/ftplugin/help.vim',
      \ '$MYVIM_HOME/after/ftplugin/html.vim',
      \ '$MYVIM_HOME/after/ftplugin/qf.vim',
      \ '~/.config/nyaovim/nyaovimrc.html',
      \ '~/.config/nyaovim/browser-config.json',
      \ '~/.themisrc',
      \ '~/.config/zsh/',
      \ '~/.config/zsh/rc.d/',
      \ '~/.zshenv',
      \ '~/.config/zsh/.zshrc',
      \ '~/.config/zsh/zplug.zsh',
      \ '~/.config/zsh/bookmark.txt',
      \ '~/.config/zsh/rc.d/10_config.zsh',
      \ '~/.config/zsh/rc.d/10_theme.zsh',
      \ '~/.config/zsh/rc.d/20_keymap.zsh',
      \ '~/.config/zsh/rc.d/50_config_peco.zsh',
      \ '~/.config/zsh/rc.d/50_extend_rsync.zsh',
      \ '~/.config/zsh/rc.d/90_functions.zsh',
      \ '~/.config/tmux/',
      \ '~/.config/tmux/tmux.conf',
      \ '~/.config/tmux/rc.d/00_keymap.conf',
      \ '~/.config/tmux/rc.d/50_plugin.conf',
      \ '~/.config/karabiner/karabiner.json',
      \ '~/.config/karabiner/assets/complex_modifications/pinkyless.json',
      \ '~/.config/karabiner/assets/complex_modifications/terminal.json',
      \ '~/.config/alacritty/alacritty.yml',
      \ '~/.config/lemonade.toml',
      \ '~/.gitconfig.local',
      \ '~/.gitconfig',
      \ '~/.gitignore',
      \ '~/.vimperatorrc',
      \ '~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1',
      \ 'https://raw.githubusercontent.com/codemirror/CodeMirror/HEAD/keymap/vim.js',
      \])
call denite#custom#var('menu', 'menus', s:menus)
