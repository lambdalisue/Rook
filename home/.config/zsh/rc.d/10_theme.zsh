# Colon
# Author:  lambdalisue
# License: MIT

__colon::util::timeout() {
  command perl -e 'alarm shift; exec @ARGV' "$@"
}

__colon::util::git() {
  __colon::util::timeout 1 command git "$@" 2>/dev/null
}

__colon::util::is_git_worktree() {
  [[ $(__colon::util::git rev-parse --is-inside-work-tree) == 'true' ]]
}

__colon::util::eliminate_empty_elements() {
  for element in ${1[@]}; do
    [[ -n "$element" ]]; echo -en $element
  done
}

__colon::get_segment() {
  local text="$1"
  local fcolor="$2"
  local kcolor="$3"
  if [ -n "$fcolor" -a -n "$kcolor" ]; then
    echo -n "%{%K{$kcolor}%F{$fcolor}%}$text%{%k%f%}"
  elif [ -n "$fcolor" ]; then
    echo -n "%{%F{$fcolor}%}$text%{%f%}"
  elif [ -n "$kcolor" ]; then
    echo -n "%{%K{$kcolor}%}$text%{%k%}"
  else
    echo -n "$text"
  fi
}

__colon::get_root() {
  local fcolor='white'
  local kcolor='red'
  # show hostname only when user connect to a remote machine
  if [ $(id -u) -eq 0 ]; then
    __colon::get_segment "%{%B%} %n %{%b%}" $fcolor $kcolor
  fi
}

__colon::get_time() {
  local fcolor=245
  local kcolor=''
  local date="%D{%H:%M}"
  __colon::get_segment "$date" $fcolor $kcolor
}

__colon::get_symbol() {
  local fcolor_normal='blue'
  local kcolor_normal=''
  local fcolor_error='red'
  local kcolor_error=''
  if [[ $1 > 0 ]]; then
    __colon::get_segment "%{%B%}:%{%b%}" $fcolor_error $kcolor_error
  else
    __colon::get_segment "%{%B%}:%{%b%}" $fcolor_normal $kcolor_normal
  fi
}

__colon::get_exitstatus() {
  local fcolor='red'
  local kcolor=''
  if [[ $1 > 0 ]]; then
    __colon::get_segment " $1" $fcolor $kcolor
    #__colon::get_segment "(!)$1" $fcolor $kcolor
  fi
}

__colon::get_cwd() {
    local fcolor='blue'
    local kcolor=''
    local lock='⭤'
    local PWD="$(pwd)"
    # current path state
    local pwd_state
    if [[ ! -O "$PWD" ]]; then
        if [[ -w "$PWD" ]]; then
            pwd_state="%{%F{blue}%}$lock "
        elif [[ -x "$PWD" ]]; then
            pwd_state="%{%F{yellow}%}$lock "
        elif [[ -r "$PWD" ]]; then
            pwd_state="%{%F{red}%}$lock "
        fi
    fi
    if [[ ! -w "$PWD" && ! -r "$PWD" ]]; then
        pwd_state="%{%F{red}%}$lock "
    fi
    local pwd_path="%50<...<%~"
    __colon::get_segment "%{%B%}$pwd_state$pwd_path%{%f%b%}" $fcolor $kcolor
}

__colon::get_vcs() {
    local fcolor_normal='green'
    local fcolor_error='red'
    local kcolor_normal=''
    local kcolor_error=''
    vcs_info 'colon'

    local -a messages
    [[ ! "$vcs_info_msg_0_" =~ "^[ ]*$" ]] && messages+=( $(__colon::get_segment "$vcs_info_msg_0_" $fcolor_normal  $kcolor_normal ) )
    [[ ! "$vcs_info_msg_1_" =~ "^[ ]*$" ]] && messages+=( $(__colon::get_segment " %{%B%}$vcs_info_msg_1_%{%b%}" ) )
    [[ ! "$vcs_info_msg_2_" =~ "^[ ]*$" ]] && messages+=( $(__colon::get_segment " $vcs_info_msg_2_" $fcolor_error   $kcolor_error ) )
    echo -n "${(j: :)messages}"
}

__colon::configure_vcsstyles() {
    autoload -Uz vcs_info 
    local branchfmt="%b%m"
    local actionfmt="%a%f"

    # $vcs_info_msg_0_ : Normal
    # $vcs_info_msg_1_ : Warning
    # $vcs_info_msg_2_ : Error
    zstyle ':vcs_info:*:colon:*' max-exports 3

    zstyle ':vcs_info:*:colon:*' enable git svn hg bzr
    zstyle ':vcs_info:*:colon:*' formats "%s $branchfmt"
    zstyle ':vcs_info:*:colon:*' actionformats "%s $branchfmt" '%m' '<!%a>'

    if is-at-least 4.3.10; then
        zstyle ':vcs_info:git:colon:*' formats "$branchfmt" '%m'
        zstyle ':vcs_info:git:colon:*' actionformats "$branchfmt" '%m' '<!%a>'
    fi

    if is-at-least 4.3.11; then
        zstyle ':vcs_info:git+set-message:colon:*' hooks \
            git-hook-begin \
            git-status \
            git-push-status \
            git-pull-status

        function +vi-git-hook-begin() {
            if ! __colon::util::is_git_worktree; then
                # stop further hook functions
                return 1
            fi
            return 0
        }

        function +vi-git-status() {
            # do not handle except the 2nd message of zstyle formats, actionformats
            if [[ "$1" != "1" ]]; then
                return 0
            fi
            local gitstatus="$(__colon::util::git status --ignore-submodules=all --porcelain)"
            if [[ $? == 0 ]]; then
                local staged="$(command echo $gitstatus | grep -E '^([MARC][ MD]|D[ M])' | wc -l | tr -d ' ')"
                local unstaged="$(command echo $gitstatus | grep -E '^([ MARC][MD]|DM)' | wc -l | tr -d ' ')"
                local untracked="$(command echo $gitstatus | grep -E '^\?\?' | wc -l | tr -d ' ')"
                local indicator="•"
                local -a messages
                [[ $staged > 0    ]] && messages+=( "%{%F{blue}%}$indicator%{%f%}" )
                [[ $unstaged > 0  ]] && messages+=( "%{%F{red}%}$indicator%{%f%}" )
                [[ $untracked > 0 ]] && messages+=( "%{%F{yellow}%}$indicator%{%f%}" )
                hook_com[misc]+="%{%B%}${(j::)messages}%{%b%}"
            fi
        }

        function +vi-git-push-status() {
            # do not handle except the 2nd message of zstyle formats, actionformats
            if [[ "$1" != "1" ]]; then
                return 0
            fi

            # get the number of commits ahead of remote
            local ahead
            ahead=$(__colon::util::git log --oneline @{upstream}.. | wc -l | tr -d ' ')

            if [[ "$ahead" -gt 0 ]]; then
                if [[ ! "${hook_com[misc]}" =~ '^[ ]*$' ]]; then
                   hook_com[misc]+=" "
                fi
                hook_com[misc]+="%{%B%F{green}%}⋀%{%b%f%}"
            fi
        }

        function +vi-git-pull-status() {
            # do not handle except the 2nd message of zstyle formats, actionformats
            if [[ "$1" != "1" ]]; then
                return 0
            fi

            # get the number of commits behind remote
            local behind
            behind=$(__colon::util::git log --oneline ..@{upstream} | wc -l | tr -d ' ')

            if [[ "$behind" -gt 0 ]]; then
                if [[ ! "${hook_com[misc]}" =~ '^[ ]*$' ]]; then
                    hook_com[misc]+=" "
                fi
                hook_com[misc]+="%{%B%F{green}%}⋁%{%b%f%}"
            fi
        }
    fi
}

__colon::configure_prompt() {
  __colon::prompt_precmd() {
    local exitstatus=$?
    __colon_prompt_1st_bits=(
      "$(__colon::get_root)"
      "$(__colon::get_time)"
      "$(__colon::get_exitstatus $exitstatus)"
      "$(__colon::get_symbol $exitstatus)"
    )
    __colon_prompt_2nd_bits=(
      "$(__colon::get_vcs)"
      "$(__colon::get_cwd)"
    )
    # Remove empty elements
    __colon_prompt_1st_bits=${(M)__colon_prompt_1st_bits:#?*}
    __colon_prompt_2nd_bits=${(M)__colon_prompt_2nd_bits:#?*}
    # Array to String
    __colon_prompt_1st_bits=${(j: :)__colon_prompt_1st_bits}
    __colon_prompt_2nd_bits=${(j: :)__colon_prompt_2nd_bits}
  }
  add-zsh-hook precmd __colon::prompt_precmd

  PROMPT="\$__colon_prompt_1st_bits "
  RPROMPT=" \$__colon_prompt_2nd_bits"
}

{
  # load required modules
  autoload -Uz terminfo
  autoload -Uz is-at-least
  autoload -Uz add-zsh-hook
  autoload -Uz colors && colors
  # enable variable extraction in prompt
  setopt prompt_subst
  __colon::configure_prompt
  __colon::configure_vcsstyles
}
# vim: ft=zsh
