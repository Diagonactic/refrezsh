#!/usr/bin/env zsh

git/vcs-group() { # $1=NEXT GROUP
    setopt localoptions typesetsilent
    typeset -g VCS_GROUP=''

    vcs-icon() { new-icon "$1" $VCS_GROUP_NAME "$2"; }

    local VCS_ICON
    origin-icon() {
        case "${1:-${repo_remote_name_to_url[origin]:-}}" in
            (*github.com[\:/]*)     vcs-icon VCS_ICON github    ;;
            (*bitbucket.org[\:/]*)  vcs-icon VCS_ICON bitbucket ;;
            (*keybase\:*)           vcs-icon VCS_ICON keybase   ;;
            (*)                     vcs-icon VCS_ICON git       ;;
        esac
    }

    (( ${git_property_map[behind-by]} > 0 )) && local -ri IS_BEHIND=1 || local -ri IS_BEHIND=0
    (( ${git_property_map[ahead-by]}  > 0 )) && local -ri IS_AHEAD=1  || local -ri IS_AHEAD=0

    (( ${repo_status_staged[add-len]} + ${repo_status_staged[mod-len]} + ${repo_status_staged[del-len]} + ${repo_status_staged[ren-len]} + ${repo_status_staged[unm-len]} != 0 )) \
        && local -ri HAS_STAGED_CHANGES=1 || local -ri HAS_STAGED_CHANGES=0

    (( ${repo_status_unstaged[add-len]} + ${repo_status_unstaged[mod-len]} + ${repo_status_unstaged[del-len]} + ${repo_status_unstaged[ren-len]} + ${repo_status_unstaged[new-len]} + ${repo_status_unstaged[unm-len]} != 0 )) \
        && local -ri HAS_UNSTAGED_CHANGES=1 || local -ri HAS_UNSTAGED_CHANGES=0

    (( HAS_STAGED_CHANGES || HAS_UNSTAGED_CHANGES || IS_AHEAD || IS_BEHIND )) \
        && local -ri IS_DIRTY=1 || local -ri IS_DIRTY=0

    (( IS_DIRTY )) && local -r VCS_GROUP_NAME='vcsdirty' || VCS_GROUP_NAME='vcsclean'

    local {AHEAD,BEHIND}_BY_ICON
    function {ahead,behind}-icon() { #set -x
        0="${0%%-*}"
        1="${(U)0}_BY_ICON"
        2="${git_property_map[$0-by]}"
        (( $2 > 0 )) || { typeset -g "$1"=''; return 0 }
        (( $2 < 9 )) || { vcs-icon "$1" "local-$0-9"; return 0 }
        vcs-icon "$1" "local-$0-$2"
    }

    origin-icon

    local VCS_DIVIDER_ICON;     vcs-icon VCS_DIVIDER_ICON "${VCS_GROUP_NAME}-divider"
    local STATUS_ICONS
    if (( HAS_STAGED_CHANGES || HAS_UNSTAGED_CHANGES )); then
        function status-icon() {
            (( $1 > 0 )) || return 0
            local ICON; vcs-icon ICON "local-$2"
            STATUS_ICONS+="$ICON"
        }

        local {RP,KEY}
        for RP in {ren,mod,add,del,unm}; do
            KEY="${RP}-len"
            status-icon "${repo_status_unstaged[$KEY]}" "$RP"
            status-icon "${repo_status_staged[$KEY]}"   "$RP";
        done
        status-icon "${repo_status_unstaged[new-len]}" "$1"

        STATUS_DIVIDER_ICON="$VCS_DIVIDER_ICON"
    fi
    
    local MOD{,_{COUNT,DIVIDER}}_ICON
    if [[ -n "$repo_submodules" ]]; then
        local -i repo_ct=$(( ${#${repo_submodules[@]}} ))
        (( repo_ct <= 9 )) || repo_ct=9
        if (( repo_ct > 0 )); then
            MOD_DIVIDER_ICON="$VCS_DIVIDER_ICON"
            vcs-icon MOD_COUNT_ICON "mod-${repo_ct}"
            vcs-icon MOD_ICON submodule
        fi
    fi

    local TREE{,_{COUNT,DIVIDER}}_ICON
    if [[ -n "$repo_subtrees" ]]; then
        local -i repo_ct=$(( ${#${repo_subtrees[@]}} ))
        (( repo_ct <= 9 )) || repo_ct=9
        if (( repo_ct > 0 )); then
            TREE_DIVIDER_ICON="$VCS_DIVIDER_ICON"
            vcs-icon TREE_COUNT_ICON "mod-${repo_ct}"
            vcs-icon TREE_ICON subtree
        fi
    fi

    local {AHEAD,BEHIND}_BY_ICON
    ahead-icon
    behind-icon

    local {PUSH_PULL_DIVIDER,ARROW}_ICON
    PUSH_PULL_DIVIDER_ICON="$VCS_DIVIDER_ICON"
    if (( IS_AHEAD || IS_BEHIND )); then
        if   (( IS_AHEAD && IS_BEHIND )); then  vcs-icon ARROW_ICON local-ahead-behind;
        elif (( IS_AHEAD )); then               vcs-icon ARROW_ICON local-ahead
        else                                    vcs-icon ARROW_ICON local-behind; fi
    else
        vcs-icon ARROW_ICON local-synced
    fi

    local ISMOD_ICON
    if (( git_property_map[is-submodule] )); then
        vcs-icon ISMOD_ICON issubmod
    fi

    new-group VCS_GROUP $VCS_GROUP_NAME "$VCS_ICON$ISMOD_ICON$VCS_DIVIDER_ICON$MOD_COUNT_ICON$MOD_ICON$MOD_DIVIDER_ICON$TREE_COUNT_ICON$TREE_ICON$TREE_DIVIDER_ICON$STATUS_ICONS$STATUS_DIVIDER_ICON${git_property_map[local-branch]}${refrezsh_tc[vcs-group-fg]}$AHEAD_BY_ICON$ARROW_ICON$BEHIND_BY_ICON${git_property_map[remote-branch]} ${refrezsh_tc[vcs-group-rfg]}"
}
