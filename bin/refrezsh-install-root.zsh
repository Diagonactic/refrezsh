#!/usr/bin/env zsh
() {
    local EXPECTED_REFREZSH_PATH="$HOME/.zplugin/plugins/Diagonactic---refrezsh"
    local TARGET_REFREZSH_PATH="/usr/local/src/refrezsh"
    die() { print-error "$1"; exit 1; }

    move-link-refrezsh() {
        [[ -d "/usr/local/src" ]] || { sudo mkdir -p /usr/local/src || die "Failed to create /usr/local/src" }
        pushd "/usr/local/src"    || die "Couldn't change directory to /usr/local/src"
        {
            mv "$EXPECTED_REFREZSH_PATH"  "$TARGET_REFREZSH_PATH"   && print-info "Moved $EXPECTED_REFREZSH_PATH to $TARGET_REFREZSH_PATH"     || die "Failed to move $EXPECTED_REFREZSH_PATH to $TARGET_REFREZSH_PATH"
            ln -s "$TARGET_REFREZSH_PATH" "$EXPECTED_REFREZSH_PATH" && print-info "Symlinked $TARGET_REFREZSH_PATH to $EXPECTED_REFREZSH_PATH" || die "Failed to symlink $TARGET_REFREZSH_PATH to $EXPECTED_REFREZSH_PATH"
        } always { popd }
    }

    [[ -d "$EXPECTED_REFREZSH_PATH" ]] || print-error "Refrezsh must be loaded/installed to $EXPECTED_REFREZSH_PATH"
    (( EUID != 0 ))                    || print-error "This must be run as a regular user, not root"

    # Move Diagonactic---refrezsh to /usr/local/src
    if [[ "${THEME_ROOT:A}" == "/usr/local/src/refrezsh" ]]; then
        print-info "Refrezsh is already in a central location; skipping symlink"
    else
        move-link-refrezsh
    fi
    print-info "Installing for root (you may be prompted for a password)"
    sudo "$THEME_ROOT/user-install.zsh"
} "$@"
