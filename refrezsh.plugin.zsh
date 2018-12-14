#!/usr/bin/env zsh
declare REFREZSH_PLUGIN_PATH="${${(%):-%x}:A}"

declare THEME_ROOT="${REFREZSH_PLUGIN_PATH:h}"
declare THEME_LIB_PATH="${THEME_ROOT}/lib"

source "${THEME_LIB_PATH}/common.lib.zsh"
source "${THEME_LIB_PATH}/git.lib.zsh"
source "${THEME_LIB_PATH}/git.component.zsh"
declare -hgx REFREZSH_MODE="${1:-print}"

function __refrezsh-prompt() {
    if [[ "$REFREZSH_MODE" == print ]]; then
        REFREZSH_IS_DEBUG=1
        export REFREZSH_IS_DEBUG
    fi
    if (( REFREZSH_IS_DEBUG == 1 )); then
        print -- > ~/tmp/last_prompt.info
    fi
    local {PATH,ACCOUNT,VCS,NEXT,END}_GROUP='' {PS,PE,FOLDER,TILDE,AT,VCS}_ICON=''

    local CURRENT_PATH="${${${(M)PWD:#$HOME*}:+${refrezsh_icons[homedir-tilde]}${PWD##$HOME}}:-$PWD}"
    [[ "$PWD" == "$HOME"* ]] && {
        new-icon FOLDER_ICON path homedir
        new-icon TILDE_ICON path tilde
        FOLDER_ICON+=" $TILDE_ICON"
    } || new-icon FOLDER_ICON path dir
    new-icon PS_ICON path prompt-start
    new-icon PE_ICON ''   prompt-end
    #FOLDER_ICON="$FOLDER_ICON"
    local TGT_USER="${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}"
    local LAST_GROUP=''

    new-group PATH_GROUP path "$FOLDER_ICON$CURRENT_PATH"

    new-icon  AT_ICON account at
    new-group ACCOUNT_GROUP account "${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}$AT_ICON$HOST"

    # Version Control Component
    local -A git_property_map=( ) repo_status_unstaged=( ) repo_status_staged=( ) repo_submodule_branches=( ) repo_remote_url_to_name=( ) repo_remote_name_to_url=( )
    local -a repo_remotes=( ) repo_submodules=( ) repo_subtrees=( )

    if git/vcs-details; then
        git/vcs-group
    fi

    end-prompt END_GROUP

    (( EUID == 0 )) && local PARROW="${refrezsh_icons[root-icon-fg]}${refrezsh_icons[root-icon]}" || local PARROW="${refrezsh_icons[user-icon-fg]}${refrezsh_icons[user-icon]}"
    PROMPT=$'\e[38;2;255;0;0m'"%(?::  %? )"$'\e[0;37;40m'"$PARROW"$'\e[0;37;40m '
    print -- "\n$PATH_GROUP$ACCOUNT_GROUP$VCS_GROUP$END_GROUP ${refrezsh[prompt-end]} "
    #RPROMPT=$'\e[38;2;255;0;0m'"%(?::%?)"$'\e[0;37;40m'
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
    prompt-at() { pushd "$1"; { __refrezsh-prompt } always { popd } }
    case "${0##*-}" in
        (debug)  cat ~/tmp/last_prompt.info > /dev/stderr ;;
        (load|start)
            add-zsh-hook precmd __refrezsh-prompt    ;;
        (unload|stop)
            add-zsh-hook -d precmd __refrezsh-prompt
            unfunction refrezsh-debug refrezsh-unload refrezsh-load
            autoload refrezsh-load
            ;;
        (print)
            print -- $'\e[0m\e[0;37m\e[0;40m'
            __refrezsh-prompt
            prompt-at ..
            prompt-at ~/git/GP/gripshape-build-automation
            prompt-at ~/git/GP/gripshape-build-automation/gripshape-backend-web
            prompt-at ~/git/alacritty
            #print > ~/tmp/tmp.info # TODO: REMOVE ME
            #prompt-at ~/git/wayward/Documentation
            prompt-at ~/git/zsh-language
            print -P "${PROMPT}_"
    esac
}

autoload -- __refrezsh-prompt
autoload -- refrezsh-debug refrezsh-load refrezsh-unload
declare -ig REFREZSH_IS_DEBUG=0
if [[ "${2:-}" == "debug" ]]; then REFREZSH_IS_DEBUG=1; fi

"refrezsh-${1:-print}"
