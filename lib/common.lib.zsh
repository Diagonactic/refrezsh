#!/usr/bin/env zsh
declare -gA refrezsh=( )
(( ${+REFREZSH_ROOT} ))     || declare -gh REFREZSH_ROOT="${${(%):-%x}:A:h:h}"

declare -gA refrezsh=(
    root-dir     "$REFREZSH_ROOT"
    themes-dir   "$REFREZSH_ROOT/themes"
    prompt-end $'\e[0m\e[0;37;40m'
)

local FGC=$'\e[38;2;' BGC=$'\e[48;2;'
# Reds:    #fe575f -- #d73142 #b10028 ... #8c000f #680000
# Oranges: #ffb857 -- #ce8e2d #9f6500 ... #713f00 #4a1c00
# Greens:  #64f995 -- #1ec667 #00953b ... #00660e #003a00
# Blues:   #5eaff3 -- #2c8bcc #0068a6 ... #004781 #00295e

declare -gA refrezsh_colors=(
    path-group-bg       '#00295e'
    path-group-fg       '#7ecfff'
    homedir-icon-fg     '#ffb857'
    dir-icon-fg         '#2c8bcc'
    account-group-bg    '#2c8bcc'
    account-group-fg    '#00194e'
    vcs-group-bg        '#ce8e2d'
    vcs-group-fg        '#FFFFFF'
    vcs-group-dirty-bg  '#000000'
    vcs-group-dirty-fg  '#FFFFFF'
    vcs-group-clean-bg  '#000000'
    vcs-group-clean-fg  '#FFFFFF'
    tilde-icon-fg       '#8FD8FF'
    at-icon-fg          '#004781'
)
declare -gA refrezsh_tc=( ) # This should not be modified or set directly
hash-to-ansi() {
    typeset -g ANSICODE=''
    local HASHCODE="$1"
    [[ "$HASHCODE" == '#'[[:digit:]ABCDEFabcdef](c#6,6) ]] || ANSICODE='0;0;0m'
    local -i {dec{1,2,3},x}=0
    for (( x=1; x<=3; x++ )); do
        printf -v "dec$x" "%d" "0x${1:$(( x * 2 - 1 )):2}"
    done
    ANSICODE="$dec1;$dec2;${dec3}m"
}

() {
    setopt localoptions extendedglob
    local BG=$'\e[48;2;' FG=$'\e[38;2;'
    convert-code() {
        local ANSICODE=''
        [[ "$1" != *-[fb]g ]] || {
            hash-to-ansi "${refrezsh_colors[$1]}"; refrezsh_tc+=( "$1" "$FG$ANSICODE" )
            return $?
        }
        hash-to-ansi "${refrezsh_colors[${1}-fg]}"
        refrezsh_tc+=( "$1-fg" "$FG$ANSICODE" "$1-rbg" "$BG$ANSICODE" )
        hash-to-ansi "${refrezsh_colors[${1}-bg]}"
        refrezsh_tc+=( "$1-bg" "$BG$ANSICODE" "$1-rfg" "$FG$ANSICODE" )
        refrezsh_tc+=( "$1" "${refrezsh_tc[$1-bg]}${refrezsh_tc[$1-fg]}" "$1-r" "${refrezsh_tc[$1-rbg]}${refrezsh_tc[$1-rfg]}" )
    }
    convert-code tilde-icon-fg
    convert-code at-icon-fg
    convert-code homedir-icon-fg
    convert-code dir-icon-fg
    convert-code path-group
    convert-code account-group
    convert-code vcs-group
}
declare -gA refrezsh_codes=(
    pfx-1 $'\e[48;2;20;168;250m\e[38;2;0;0;0m'
    fg-1 $''

)
declare -gA refrezsh_icons=(
    dir-icon        $'\uf74a'
    homedir-icon    $'\uf74b'
    tilde-icon      $'~'
    githubdir-icon  $'\ue5fd'
    npmdir-icon     $'\ue5fa'
    gitdir-icon     $'\ue5fb'
    bitbucket-icon  $'\uf171'
    account-icon    $'\uf2bd'
    path-sep        $'\ue0b4\ue0b5 '
    account-sep     $'\ue0b4\ue0b5 '
    git-icon        $'\ue0a0'
    at-icon         $'@'
)
