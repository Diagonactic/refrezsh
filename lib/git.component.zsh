#!/usr/bin/env zsh

git/vcs-group() { # $1=NEXT GROUP
    (( ${git_property_map[behind-by]} > 0 )) && local -ri IS_BEHIND=1 || local -ri IS_BEHIND=0
    (( ${git_property_map[ahead-by]} > 0 ))  && local -ri IS_AHEAD=1  || local -ri IS_AHEAD=0
    (( ${repo_status_staged[add-len]} + ${repo_status_staged[mod-len]} + ${repo_status_staged[del-len]} + ${repo_status_staged[ren-len]} > 0 )) \
        && local -ri HAS_STAGED_CHANGES=1 \
        || local -ri HAS_STAGED_CHANGES=0
    (( ${repo_status_unstaged[add-len]} + ${repo_status_unstaged[mod-len]} + ${repo_status_unstaged[del-len]} + ${repo_status_unstaged[ren-len]} + ${repo_status_unstaged[new-len]} != 0 )) \
        && local -ri HAS_UNSTAGED_CHANGES=1 \
        || local -ri HAS_UNSTAGED_CHANGES=0
    (( HAS_STAGED_CHANGES || HAS_UNSTAGED_CHANGES || IS_AHEAD || IS_BEHIND )) \
        && local -ri IS_DIRTY=1 \
        || local -ri IS_DIRTY=0
    (( IS_DIRTY )) && local -r VCS_GROUP_NAME='vcsdirty' || VCS_GROUP_NAME='vcsclean'
    vcs-icon() { new-icon "$1" $VCS_GROUP_NAME "$2"; }

    function {ahead,behind}-icon() { #set -x
        0="${0%%-*}"
        1="${(U)0}_BY_ICON"
        2="${git_property_map[$0-by]}"
        (( $2 > 0 )) || { typeset -g "$1"=''; return 0 }
        (( $2 < 9 )) || { vcs-icon "$1" "local-$0-9"; return 0 }
        vcs-icon "$1" "local-$0-$2"
    }
    typeset -g VCS_GROUP=''
    local {VCS,LOCAL,ADD,MOD,DEL,REN}{U,}_ICON='' NEWU_ICON=''
    local {{AHEAD,BEHIND}_BY,ARROW,{PUSH_PULL,STATUS,MOD,VCS,TREE}_DIVIDER,TREE,{TREE,MOD}_COUNT,{IS,}SUBMOD}_ICON=''

    local ORIGIN_REMOTE="${repo_remote_name_to_url[origin]:-}"
    case "$ORIGIN_REMOTE" in
        (*github.com[\:/]*)     vcs-icon VCS_ICON github ;;
        (*bitbucket.org[\:/]*)  vcs-icon VCS_ICON bitbucket ;;
        (*)                     vcs-icon VCS_ICON git ;;
    esac

    vcs-icon VCS_DIVIDER "${VCS_GROUP_NAME}-divider"
    if (( HAS_STAGED_CHANGES || HAS_UNSTAGED_CHANGES )); then
        (( ${repo_status_staged[add-len]} == 0 ))   || vcs-icon ADD_ICON local-add
        (( ${repo_status_staged[mod-len]} == 0 ))   || vcs-icon MOD_ICON local-mod
        (( ${repo_status_staged[ren-len]} == 0 ))   || vcs-icon REN_ICON local-ren
        (( ${repo_status_staged[del-len]} == 0 ))   || vcs-icon DEL_ICON local-del
        (( ${repo_status_unstaged[add-len]} == 0 )) || vcs-icon ADDU_ICON local-add-u
        (( ${repo_status_unstaged[mod-len]} == 0 )) || vcs-icon MODU_ICON local-mod-u
        (( ${repo_status_unstaged[ren-len]} == 0 )) || vcs-icon RENU_ICON local-ren-u
        (( ${repo_status_unstaged[del-len]} == 0 )) || vcs-icon DELU_ICON local-del-u
        (( ${repo_status_unstaged[new-len]} == 0 )) || vcs-icon NEWU_ICON local-new-u
        STATUS_DIVIDER_ICON="$VCS_DIVIDER"
    fi
    if [[ -n "$repo_submodules" ]]; then
        local -i repo_ct=$(( ${#${repo_submodules[@]}} ))
        if (( repo_ct > 0 )); then
            (( repo_ct <= 9 )) || repo_ct=9
            MOD_DIVIDER_ICON="$VCS_DIVIDER"
            vcs-icon MOD_COUNT_ICON "mod-${repo_ct}"
            vcs-icon SUBMOD_ICON submodule
        fi
    fi
    if [[ -n "$repo_subtrees" ]]; then
        local -i repo_ct=$(( ${#${repo_subtrees[@]}} ))
        if (( repo_ct > 0 )); then
            (( repo_ct <= 9 )) || repo_ct=9
            TREE_DIVIDER_ICON="$VCS_DIVIDER"
            vcs-icon TREE_COUNT_ICON "mod-${repo_ct}"
            vcs-icon TREE_ICON subtree
        fi
    fi
    ahead-icon local
    behind-icon local
    PUSH_PULL_DIVIDER_ICON="$VCS_DIVIDER"
    if (( IS_AHEAD || IS_BEHIND )); then
        if   (( IS_AHEAD && IS_BEHIND )); then  vcs-icon ARROW_ICON local-ahead-behind;
        elif (( IS_AHEAD )); then               vcs-icon ARROW_ICON local-ahead
        else                                    vcs-icon ARROW_ICON local-behind; fi
    else
        vcs-icon ARROW_ICON local-synced
    fi
    if (( git_property_map[is-submodule] )); then
        vcs-icon ISSUBMOD_ICON issubmod
    fi
    new-group VCS_GROUP $VCS_GROUP_NAME "$VCS_ICON$ISSUBMOD_ICON$VCS_DIVIDER$MOD_COUNT_ICON$SUBMOD_ICON$MOD_DIVIDER_ICON$TREE_COUNT_ICON$TREE_ICON$TREE_DIVIDER_ICON$NEWU_ICON$ADD_ICON$ADDU_ICON$MOD_ICON$MODU_ICON$DEL_ICON$DELU_ICON$REN_ICON$RENU_ICON$STATUS_DIVIDER_ICON${git_property_map[local-branch]}${refrezsh_tc[vcs-group-fg]}$AHEAD_BY_ICON$ARROW_ICON$BEHIND_BY_ICON${git_property_map[remote-branch]} ${refrezsh_tc[vcs-group-rfg]}"
}
