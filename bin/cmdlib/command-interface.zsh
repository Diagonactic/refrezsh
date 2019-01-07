#!/usr/bin/env zsh

typeset SCRIPT_PATH="$1"
check-include-parameter-sanity() {
    die() { print -- $'ERROR: command-interface.zsh include: '"$1"; return 1 }
    [[ -e "$1" && ! -d "$1" ]] || {
        die "The first parameter must be an absolute path to the including script -- $1 does not exist."
    }
}

check-include-parameter-sanity "$@" || return $?

typeset SCRIPT_DIR="${SCRIPT_PATH:A}" SCRIPT_NAME="${SCRIPT_PATH:t}"
typeset CMD_NAME="${SCRIPT_NAME%%.zsh}"
case "$1" in
    (title)                 print -- "Refrezsh Command $CMD_NAME $SCRIPT_VERSION";                    exit 1 ;;
    (description)           print -- "${SCRIPT_DESCRIPTION:+- $SCRIPT_DESCRIPTION}";     exit 1 ;;
    (command-help)          print -- "\"${(qqq)CMD_NAME}\" \"$SCRIPT_DESCRIPTION\""; exit 1 ;;
    (eval-command-metadata) print -- "_rzsh_commands[${(q)CMD_NAME}.description]=\"${(qqq)SCRIPT_DESCRIPTION}\""$'\n' \
                                     "_rzsh_commands[${(q)CMD_NAME}.version]=\"${(qqq)SCRIPT_VERSION}\""              \
                                     "_rzsh_commands[${(q)CMD_NAME}.path]=\"${(qqq)SCRIPT_PATH}\""                    \
                                     "_rzsh_commands[${(q)CMD_NAME}.dir]=\"${(qqq)SCRIPT_DIR}\""                      \
                                     ;;

esac
