#!/usr/bin/env zsh

account/account-group() { 
    local IS_ROOT="${${${(M)EUID:#0}:+1}:-0}" {AT,ACCOUNT,U}_ICON
    local TGT_USER="${${SUDO_USER:+root($SUDO_USER)}:-$USER}"
    local TGT_NAME="${${${IS_ROOT:#1}:-root}##*0}account"

    new-icon U_ICON  "$TGT_NAME" "$TGT_NAME"
    new-icon AT_ICON "$TGT_NAME" at
    new-group ACCOUNT_GROUP "$TGT_NAME" "$U_ICON${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}$AT_ICON$HOST"
}
