#!/usr/bin/env zsh

path/path-group() { #set -x
    local  {PS,FOLDER,TILDE,AT,VCS}_ICON=''
    local CURRENT_PATH="${${${(M)PWD:#$HOME*}:+${refrezsh_icons[homedir-tilde]}${PWD##$HOME}}:-$PWD}"

    [[ "$PWD" == "$HOME"* ]] && {
        new-icon FOLDER_ICON path homedir
        new-icon TILDE_ICON path tilde
        FOLDER_ICON+=" $TILDE_ICON"
        if [[ "$PWD" == "$HOME" ]]; then CURRENT_PATH=''; fi
    } || new-icon FOLDER_ICON path dir

    new-icon PS_ICON path prompt-start

    new-group PATH_GROUP path "$FOLDER_ICON$CURRENT_PATH"
}
