autoload -Uz vcs_info
autoload -U colors && colors
autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd

theme_precmd () {
    typeset scmName="" 

    vcs_info

    scmName="${vcs_info_msg_0_}" 
    case $scmName in
    	"bzr")
            scmChar="%F{blue}β%f" 
            ;;
    	"git")
            scmChar="%F{blue}±%f" 
            ;;
        "hg")
            scmChar="%F{blue}∂%f" 
            ;;
        "svn")
            scmChar="%F{blue}∫%f" 
            ;;
        *)
            scmChar=" %f" 
            ;;
    esac
}


zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%F{red}●'   # display this when there are unstaged changes
zstyle ':vcs_info:*' stagedstr '%F{green}●'  # display this when there are staged changes
zstyle ':vcs_info:*' actionformats '%s' '%u%c' '%f[ %F{red}%s%f: %b|%a ]' '%i'
zstyle ':vcs_info:*' formats '%s' '%u%c' '%f[ %F{red}%s%f: %b ]' '%i'
zstyle ':vcs_info:*' branchformat '%b:%r'
zstyle ':vcs_info:*' enable bzr git hg svn
zstyle ':vcs_info:*' max-exports 4

PROMPT='%{%f%k%b%}
%{%K{black}%B%F{green}%}%n%{%B%F{blue}%}@%{%B%F{cyan}%}%m%{%B%F{green}%} %{%b%F{yellow}%K{black}%}%~%{%B%F{green}%} ${vcs_info_msg_2_}%E%{%f%k%b%}
%{%K{black}%}$scmChar%{%K{black}%} %#%{%f%k%b%} '

RPROMPT='${vcs_info_msg_1_}'

