#!/usr/bin/env zsh

account/account-group() {
    local TGT_USER="${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}" {AT,ACCOUNT,U}_ICON

    [[ -z "$SUDO_USER" ]] && new-icon U_ICON account user || new-icon U_ICON account root
    new-icon  AT_ICON account at
    new-group ACCOUNT_GROUP account "${${SUDO_USER:+$USER($SUDO_USER)}:-$USER}$AT_ICON$HOST"
}
