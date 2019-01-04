#!/usr/bin/env zsh

() {
    die() { print-error "This script should not be run manually; it should only be called by refrezsh-install-root"; exit 1; }
    is-installed() { which "$1" > /dev/null 2>&1; }
    install-zplugin() {
        print-info "Installing zdharma/zplugin"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/install.sh)"     || die "Failed to install zplugin for $USER"
    }
    install-zmod() {
        print-info "Compiling/installing ZPlugin module"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zplugin/master/doc/mod-install.sh)" || die "Failed to install zplugin binary module for $USER"
    }

    is-installed zplugin && print-info "ZPlugin is already instaled for $USER; skipping"             || install-zplugin
    is-installed zmod && print-info "ZPlugin binary module is already installed for $USER; skipping" || install-zmod

    local LOCAL_PATH="${1:-$HOME/.zplugin/plugins/Diagonactic---refrezsh}" \
        CENTRAL_PATH="${2:-/usr/local/src/refrezsh}"

    (( EUID == 0 ))         || die
    [[ -d "$LOCAL_PATH" ]]  || die
    [[ -d "$CENTRAL_PATH"]] || die


    if [[ -d "$LOCAL_PATH" && "${LOCAL_PATH:A}" == "$LOCAL_PATH" ]]; then
        die "Refrezsh appears to be directly installed to $LOCAL_PATH; Remove this and re-run the script"
    fi

    try-link "$CENTRAL_PATH" "$LOCAL_PATH"

} "$@"
