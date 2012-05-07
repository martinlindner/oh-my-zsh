function precmd {

    ###
    # SCM

    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' unstagedstr '%F{red}●'   # display this when there are unstaged changes
    zstyle ':vcs_info:*' stagedstr '%F{green}●'  # display this when there are staged changes
    zstyle ':vcs_info:*' actionformats '%s' '%b|%a' '%u%c' '%i'
    zstyle ':vcs_info:*' formats '%s' '%b' '%u%c' '%i'
    zstyle ':vcs_info:*' branchformat '%b:%r'
    zstyle ':vcs_info:*' enable bzr git hg svn
    zstyle ':vcs_info:*' max-exports 4

    typeset scmName="" 

    vcs_info

    scmName="${vcs_info_msg_0_}" 
    case $scmName in
        "bzr")
            scmChar="β" 
            ;;
        "git")
            scmChar="±" 
            ;;
        "hg")
            scmChar="∂" 
            ;;
        "svn")
            scmChar="∫" 
            ;;
        *)
            scmChar="$" 
            ;;
    esac

    ###
    # Truncate the path if it's too long.

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 ))
    
    PR_FILLBAR=""
    PR_PWDLEN=""
    
    local lsize=${#${(%):--(%n@%m:%l${vcs_info_msg_0_:+:}${vcs_info_msg_0_}${vcs_info_msg_1_:+:}${vcs_info_msg_1_})--()-}}
    local rsize=${#${(%):-%~}}
    
    if [[ "$lsize + $rsize" -gt $TERMWIDTH ]]; then
	    ((PR_PWDLEN=$TERMWIDTH - $lsize))
    else
    	PR_FILLBAR="\${(l.(($TERMWIDTH - ($lsize + $rsize)))..${PR_HBAR}.)}"
    fi


}


setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
	local CMD=${1[(wr)^(*=*|sudo|-*)]}
	echo -n "\ek$CMD\e\\"
    fi
}


setprompt () {
    ###
    # Need this so the prompt will work.

    setopt prompt_subst

    autoload -Uz vcs_info

    ###
    # See if we can use colors.

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
	colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"


    ###
    # See if we can use extended characters to look nicer.
    
    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}
    
    ###
    # Decide if we need to set titlebar text.
    
    case $TERM in
	xterm*)
	    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
	    ;;
	screen)
	    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
	    ;;
	*)
	    PR_TITLEBAR=''
	    ;;
    esac
    
    
    ###
    # Decide whether to set a screen title
    if [[ "$TERM" == "screen" ]]; then
	PR_STITLE=$'%{\ekzsh\e\\%}'
    else
	PR_STITLE=''
    fi
    
    
    ###
    # Finally, the prompt.

    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_CYAN%(!.%SROOT%s.%n)$PR_BLUE@$PR_WHITE%m$PR_BLUE:$PR_MAGENTA%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR${(e)PR_FILLBAR}$PR_SHIFT_OUT(\
$PR_CYAN%l$PR_WHITE${vcs_info_msg_0_:+:}$PR_MAGENTA${vcs_info_msg_0_}$PR_WHITE${vcs_info_msg_1_:+:}$PR_CYAN${vcs_info_msg_1_}\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$scmChar$PR_BLUE>\
$PR_NO_COLOUR '

    RPROMPT='${vcs_info_msg_2_}$PR_NO_COLOUR'
}

setprompt