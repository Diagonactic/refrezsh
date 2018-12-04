#!/usr/bin/env zsh
clear
print -- $'\e[0m\e[0;37m\e[0;40m'
declare REFREZSH_PLUGIN_PATH="${${(%):-%x}:A}"

declare THEME_ROOT="${REFREZSH_PLUGIN_PATH:h}"
declare THEME_LIB_PATH="${THEME_ROOT}/lib"

source "${THEME_LIB_PATH}/common.lib.zsh"
source "${THEME_LIB_PATH}/git.lib.zsh"
source "${THEME_LIB_PATH}/git.component.zsh"


function output-prompt() {
    new-group() { # 1- refvar 2- group name 3- next group name 4- group value
        [[ "$3" == 'prompt-end' ]] \
            && typeset -g "$1"="${refrezsh_tc[$2-group]}${4:-}${refrezsh[prompt-end]}" \
            || typeset -g "$1"="${refrezsh_tc[$2-group]}${4:-}${refrezsh_tc[$3-group-bg]}${refrezsh_tc[$2-group-rfg]}${refrezsh_icons[$2-sep]}"
    }
    new-icon() { #local REFVAR="$1" GROUP_NAME ICON_NAME
        typeset -g "$1"="${refrezsh_tc[$3-icon-fg]}${refrezsh_icons[$3-icon]}${refrezsh_tc[$2-group-fg]}"
    }
    local {PATH,ACCOUNT,VCS,NEXT}_GROUP='' {FOLDER,TILDE,AT}_ICON=''
    local CURRENT_PATH="${${${(M)PWD:#$HOME*}:+${refrezsh_icons[homedir-tilde]}${PWD##$HOME}}:-$PWD}"
    [[ "$PWD" == "$HOME"* ]] && {
        new-icon FOLDER_ICON path homedir
        new-icon TILDE_ICON path tilde
        FOLDER_ICON+=" $TILDE_ICON"
    } || new-icon FOLDER_ICON path dir

    FOLDER_ICON=" $FOLDER_ICON"
    #local FICON="${${${(M)CURRENT_PATH:#${refrezsh_icons[homedir-pfx]}*}:+${refrezsh_icons[homedir-icon]}}:-${refrezsh_icons[dir-icon]}}"
    local TGT_USER="${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}"
    new-group PATH_GROUP path account "$FOLDER_ICON$CURRENT_PATH"
    # Version Control Component
    local -A git_property_map=( ) repo_status_unstaged=( ) repo_status_staged=( ) repo_subtrees=( ) repo_submodule_branches=( )
    local -a repo_remotes=( ) repo_submodules=( )

    if git/vcs-details; then NEXT_GROUP="vcs"; else NEXT_GROUP="prompt-end" fi
    new-group VCS_GROUP vcs prompt-end ""
    new-group ACCOUNT_GROUP account "$NEXT_GROUP" "${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}@$HOST"
    local VCS_GROUP="${refrezsh_tc[vcs-sep]}${refrezsh_icons[git-icon]}"
    print -Pn -- "\n$PATH_GROUP$ACCOUNT_GROUP$VCS_GROUP ${refrezsh[prompt-end]} _"
    print -- $'\nGit Props:'
    printf $'%s: %s\n' "${(kv@)git_property_map}"
}

output-prompt
