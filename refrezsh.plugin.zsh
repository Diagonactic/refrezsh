#!/usr/bin/env zsh
declare REFREZSH_PLUGIN_PATH="${${(%):-%x}:A}"

declare THEME_ROOT="${REFREZSH_PLUGIN_PATH:h}"
declare THEME_LIB_PATH="${THEME_ROOT}/lib"

export REFREZSH_IS_DEBUG=0

source "${THEME_LIB_PATH}/common.lib.zsh"
source "${THEME_LIB_PATH}/git.lib.zsh"
source "${THEME_LIB_PATH}/git.component.zsh"
source "${THEME_LIB_PATH}/path.component.zsh"
source "${THEME_LIB_PATH}/account.component.zsh"
declare -hgx REFREZSH_MODE="${1:-print}"

function __refrezsh-prompt() {
    local {PATH,ACCOUNT,VCS,NEXT,LAST,END}_GROUP=''
    local PE_ICON
    new-icon PE_ICON ''   prompt-end

    if (( REFREZSH_IS_DEBUG == 1 )); then
        print -- > ~/tmp/last_prompt.info
    fi

    path/path-group
    account/account-group

    # Version Control Component
    local -A git_property_map=( ) repo_status_unstaged=( ) repo_status_staged=( ) repo_submodule_branches=( ) repo_remote_url_to_name=( ) repo_remote_name_to_url=( )
    local -a repo_remotes=( ) repo_submodules=( ) repo_subtrees=( )

    if git/vcs-details; then
        git/vcs-group
    fi

    end-prompt END_GROUP

    (( EUID == 0 )) && local PARROW="${refrezsh_icons[root-icon-fg]}${refrezsh_icons[root-icon]}" || local PARROW="${refrezsh_icons[user-icon-fg]}${refrezsh_icons[user-icon]}"

    if [[ -n "${SSH_CONNECTION}" ]]; then
        local SSH_ICON=$'%{\e[38;2;240;0;25m%}'"${refrezsh_icons[ssh-icon]} ${SSH_CONNECTION%% *}"
        PARROW="$SSH_ICON "$'%{\e[0;37m%}'"$PARROW"
    fi
    setopt promptsubst
    PROMPT=$'\n'"$PATH_GROUP$ACCOUNT_GROUP$VCS_GROUP$END_GROUP ${refrezsh[prompt-end]}"$'\n%{\e[38;2;255;0;0m%}'"%(?:: %? )"$'%{\e[0;37;40m%}'"$PARROW"$'%{\e[0;37;40m%} '
    RPROMPT=''
    debug_logs() >> ~/tmp/last_prompt.info {
        dtitle() {
            print -- "$1 - $# - ${(j<:>)@}" >> ~/tmp/tmp.info
            (( $# >= 2 )) || { print "No $1"; return 1 }
            print -- $'\n'"${1}:"
        }
        dassoc() {
            dtitle $@ || return 0; shift
            printf $'%s: "%s"\n' "$@"
        }
        darray() {
            dtitle $@ || return 0; shift
            print -l -- "$@"
        }
        dassoc "Git Props" "${(kv@)git_property_map}"
        dassoc "Git Staged" "${(kv@)repo_status_staged}"
        dassoc "Git Unstaged" "${(kv@)repo_status_unstaged}"
        darray "Git Remotes" "${(@)repo_remotes}"
        darray "Git Submodules" "${repo_submodules[@]}"
        darray "Git Subtrees" "${repo_subtrees[@]}"
    }
    debug_logs
}

function refrezsh-{debug,load,start,unload,stop,print} {
    prompt-at() {
        one-prompt-at() {
            pushd "$1"
            {
                __refrezsh-prompt; print -n "$PROMPT"
            } always { popd }
        }


        while (( $# > 0 )); do {
            one-prompt-at "$1"
        } always { shift }; done
    }

    case "${0##*-}" in
        (debug)  cat ~/tmp/last_prompt.info > /dev/stderr ;;
        (load|start)
            export REFREZSH_IS_DEBUG="${REFREZSH_IS_DEBUG:-0}"
            add-zsh-hook precmd __refrezsh-prompt    ;;
        (unload|stop)
            unset REFREZSH_IS_DEBUG
            unset REFREZSH_MODE
            add-zsh-hook -d precmd __refrezsh-prompt
            unfunction refrezsh-debug refrezsh-unload refrezsh-load
            autoload refrezsh-load
            ;;
        (install-root)
            ;;
        (print)
            export REFREZSH_IS_DEBUG=1
            mkdir -p "$HOME/tmp" || export REFREZSH_IS_DEBUG=0

            print -- $'\e[0m\e[0;37m\e[0;40m'
            __refrezsh-prompt
            prompt-at .. "$@"
            print -P "${PROMPT}_"
    esac
}

autoload -- __refrezsh-prompt
autoload -- refrezsh-debug refrezsh-load refrezsh-unload
declare -ig REFREZSH_IS_DEBUG=0
if [[ "${2:-}" == "debug" ]]; then REFREZSH_IS_DEBUG=1; fi

"refrezsh-${1:-print}"
