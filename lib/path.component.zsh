#!/usr/bin/env zsh

path/path-group() {
    local  {PS,PE,FOLDER,TILDE,AT,VCS}_ICON=''

    local CURRENT_PATH="${${${(M)PWD:#$HOME*}:+${refrezsh_icons[homedir-tilde]}${PWD##$HOME}}:-$PWD}"
    [[ "$PWD" == "$HOME"* ]] && {
        new-icon FOLDER_ICON path homedir
        new-icon TILDE_ICON path tilde
        FOLDER_ICON+=" $TILDE_ICON"
    } || new-icon FOLDER_ICON path dir
    new-icon PS_ICON path prompt-start
    new-icon PE_ICON ''   prompt-end

    local LAST_GROUP=''
    if [[ "$CURRENT_PATH" == "$PWD" ]]; then
        CURRENT_PATH=''
    fi
    new-group PATH_GROUP path "$FOLDER_ICON$CURRENT_PATH"
}
