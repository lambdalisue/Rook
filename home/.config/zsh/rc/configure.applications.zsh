# homeshick
if [[ -d "$HOME/.homesick/repos/homeshick" ]]; then
    source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fi

# - ls:     use GNU ls when available.
# - ps:     display processes related to the user
case $(uname) in
    *BSD|Darwin)
        if [ -x "$(which gnuls)" ]; then
            alias ls="gnuls --color=auto"
            alias la="ls -lhAF"
        else
            alias ls="ls -G -w"
            alias la="ls -lhAFG"
        fi
        alias ps="ps -fU$(whoami)"
        ;;
    SunOS)
        if [ -x "`which gls`" ]; then
            alias ls="gls --color=auto"
            alias la="ls -lhAF"
        fi
        alias ps="ps -fl -u$(/usr/xpg4/bin/id -un)"
        ;;
    *)
        alias ls="ls --color=auto"
        alias la="ls -lhAF"
        alias ps="ps -fU$(whoami) --forest"
        ;;
esac

# less
#   M - display percentage and filename
#   i - ignore case in search
#   R - display ANSI color escape sequence as colors
#   N - show linenumber (heavy)
#   S - do not wrap long lines
export LESS="-iMRS"

# use GNU grep if possible
if type ggrep > /dev/null 2>&1; then
    alias grep=ggrep
fi
# use GNU sed if possible
if type gsed > /dev/null 2>&1; then
    alias sed=gsed
fi
# trash command
if type rmtrash > /dev/null 2>&1; then
    # brew install rmtrash
    alias trash=rmtrash
    alias rm="echo 'Use trash <path> instead or \\\\rm <path> to delete the file.'; false"
elif type trash-put > /dev/null 2>&1; then
    # pip install trash-put
    alias trash=trash-put
    alias rm="echo 'Use trash <path> instead or \\\\rm <path> to delete the file.'; false"
fi

# vim
export EDITOR=vim
if [[ -d "/Applications/MacVim.app" ]]; then
    alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"
elif ! type vim > /dev/null 2>&1; then
    alias vim=vi
fi

# hub
if type hub > /dev/null 2>&1; then
    eval "$(hub alias -s)"
fi

# xdg-open
if type xdg-open > /dev/null 2>&1; then
    alias open="xdg-open"
fi
# anyenv
if type anyenv > /dev/null 2>&1; then
    eval "$(anyenv init - zsh)"
fi

# xclip
if type xclip > /dev/null 2>&1; then
    alias xclip="xclip -selection clipboard"
fi

# go
export GOPATH="$HOME/.go"

# ghq
if [[ -d "$GOPATH/src/github.com/motemen/ghq" ]]; then
    fpath=(
        $GOPATH/src/github.com/motemen/ghq/zsh/_ghq(N-/)
        $fpath
    )
fi
