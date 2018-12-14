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
declare -gA refrezsh_colors=( )
() {
    local r0='#fe575f' r1='#d73142' r2='#b10028' r3='#8c000f' r4='#680000' \
          o0='#f5e775' o1='#ce8e2d' o2='#9f6500' o3='#713f00' o4='#e59d23' \
          g0='#56cfa9' g1='#1ec667' g2='#00953b' g3='#00660e' g4='#003a10'
          #
          local b0='#37b2fc' b1='#2c8bcc' b2='#0068a6' b3='#004781' b4='#00295e'
          declare -gA refrezsh_colors=(
              path-group-bg              $b4
              path-group-fg              $b0
              homedir-icon-fg            '#ffb857'
              dir-icon-fg                '#2c8bcc'
              account-group-bg           $b0
              account-group-fg           $b4
              vcsdirty-group-bg          $o4
              vcsdirty-group-fg          $b4
              vcsclean-group-bg          $g0
              vcsclean-group-fg          $g4
              tilde-icon-fg              '#8FD8FF'
              at-icon-fg                 '#ffffff'
              root-fg                    '#ff0000'
              user-fg                    '#ffffff'
              # github-icon-fg             '#002244'
              # bitbucket-icon-fg          '#002244'
              # keybase-icon-fg            '#002244'
              # local-changes-icon-fg      '#8c000f'
              # local-add-icon-fg          '#000000'
              # local-mod-icon-fg          '#000000'
              # local-del-icon-fg          '#000000'
              # local-ren-icon-fg          '#000000'
              # local-new-u-icon-fg        '#000000'
              # local-add-u-icon-fg        '#000000'
              # local-mod-u-icon-fg        '#000000'
              # local-del-u-icon-fg        '#000000'
              # local-ren-u-icon-fg        '#000000'
              # local-ahead-1-icon-fg      '#002244'
              # local-behind-1-icon-fg     '#002244'
              # mod-1-icon-fg              '#002244'
              # local-ahead-2-icon-fg      '#002244'
              # local-behind-2-icon-fg     '#002244'
              # mod-2-icon-fg              '#002244'
              # local-ahead-3-icon-fg      '#002244'
              # local-behind-3-icon-fg     '#002244'
              # mod-3-icon-fg              '#002244'
              # local-ahead-4-icon-fg      '#002244'
              # local-behind-4-icon-fg     '#002244'
              # mod-4-icon-fg              '#002244'
              # local-ahead-5-icon-fg      '#002244'
              # local-behind-5-icon-fg     '#002244'
              # mod-5-icon-fg              '#002244'
              # local-ahead-6-icon-fg      '#002244'
              # local-behind-6-icon-fg     '#002244'
              # mod-6-icon-fg              '#002244'
              # local-ahead-7-icon-fg      '#002244'
              # local-behind-7-icon-fg     '#002244'
              # mod-7-icon-fg              '#002244'
              # local-ahead-8-icon-fg      '#002244'
              # local-behind-8-icon-fg     '#002244'
              # mod-8-icon-fg              '#002244'
              # local-ahead-9-icon-fg      '#002244'
              # local-behind-9-icon-fg     '#002244'
              # mod-9-icon-fg              '#002244'
              # local-ahead-icon-fg        '#002244'
              # local-behind-icon-fg       '#002244'
              # local-ahead-behind-icon-fg '#002244'

              prompt-start-icon-fg       '#cccccc'
              prompt-end-icon-fg         '#cccccc'
              submodule-icon-fg          '#002244'
              subtree-icon-fg            '#aa0000'
              local-synced-icon-fg       $g3
              issubmod-icon-fg           $r3
          )

}

declare -gA refrezsh_tc=( ) # This should not be modified or set directly
is-valid-hashcode() {  }
separate-colors() {
    local SR="16${1:0:3}" SG="16#${1:3:2}" SB="16#${1:5:2}"
    typeset -gi red="$(( $SR ))" green="$(( $SG ))" blue="$(( $SB ))"
}
hash-to-ansi() {
    local -i {red,green,blue}=0
    separate-colors "$1"
    typeset -g ANSICODE="$red;$green;${blue}m"
}

darken() {
    typeset -gi {red,green,blue}=0
    separate-colors "$1"
    (( red -= $2 )) && (( green -= $2 )) && (( blue -= $2 ))
    (( red > 0 )) || red=0
    (( green > 0 )) || green=0
    (( blue > 0 )) || blue=0
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
    local KEY=''
    for KEY in ${(Mk@)refrezsh_colors[@]:#*-icon-*}; do convert-code "$KEY"; done
    for KEY in  ${(k@)refrezsh_colors[@]:#*-icon-*}; do convert-code "${KEY%%-[fb]g}"; done

    local -i {red,green,blue}=0
    darken "${refrezsh_colors[vcsclean-group-bg]}" 50
    refrezsh_tc+=( vcsclean-divider-icon-fg $'\e['"38;2;$red;$green;${blue}m" )
    darken "${refrezsh_colors[vcsdirty-group-bg]}" 50
    refrezsh_tc+=( vcsdirty-divider-icon-fg $'\e['"38;2;$red;$green;${blue}m" )
}

declare -gA refrezsh_codes=(
    pfx-1 $'\e[48;2;20;168;250m\e[38;2;0;0;0m'
    fg-1 $''
)
declare -gA refrezsh_icons=(
    dir-icon                $'\uf74a'
    prompt-start-icon       $'\uff62'
    prompt-end-icon         $'\u23a3'
    homedir-icon            $'\uf74b'
    tilde-icon              $'~'
    githubdir-icon          $'\ue5fd'
    npmdir-icon             $'\ue5fa'
    gitdir-icon             $'\ue5fb'
    account-icon            $'\uf2bd'
    path-sep                $'\ue0b4\ue0b5 '
    account-sep             $'\ue0b4\ue0b5 '
    vcs-sep                 $'\ue0b4\ue0b5 '
    vcsclean-sep                 $'\ue0b4\ue0b5 '
    vcsdirty-sep                 $'\ue0b4\ue0b5 '
    github-icon             $'\uf7a3 '
    keybase-icon            $'\uf084'
    bitbucket-icon          $'\uf171 '
    git-icon                $'\ue0a0'
    at-icon                 $'@'
    newrepo-icon            $'\uf005'
    local-changes-icon      $'\uf109  '
    local-add-icon          $'\uf916'
    local-mod-icon          $'\ufbfd '
    local-del-icon          $'\uf875 '
    local-ren-icon          $'\uf109'
    local-add-u-icon        $'\uf918'
    local-mod-u-icon        $'\ufc74 '
    local-del-u-icon        $'\uf876 '
    local-ren-u-icon        $'\uf109'
    local-new-u-icon        $'\uf917'
    local-ahead-1-icon      $' \uf8a3'
    local-behind-1-icon     $'\uf8a3 '
    mod-1-icon              $'\uf8a3'
    local-ahead-2-icon      $' \uf8a6'
    local-behind-2-icon     $'\uf8a6 '
    mod-2-icon              $'\uf8a6'
    local-ahead-3-icon      $' \uf8a9'
    local-behind-3-icon     $'\uf8a9 '
    mod-3-icon              $'\uf8a9'
    local-ahead-4-icon      $' \uf8ac'
    local-behind-4-icon     $'\uf8ac '
    mod-4-icon              $'\uf8ac'
    local-ahead-5-icon      $' \uf8af'
    local-behind-5-icon     $'\uf8af '
    mod-5-icon              $'\uf8af'
    local-ahead-6-icon      $' \uf8b2'
    local-behind-6-icon     $'\uf8b2 '
    mod-6-icon              $'\uf8b2'
    local-ahead-7-icon      $' \uf8b5'
    local-behind-7-icon     $'\uf8b5 '
    mod-7-icon              $'\uf8b5'
    local-ahead-8-icon      $' \uf8b8'
    local-behind-8-icon     $'\uf8b8 '
    mod-8-icon              $'\uf8b8'
    local-ahead-9-icon      $' \uf8be'
    local-behind-9-icon     $'\uf8be '
    mod-9-icon              $'\uf8be'
    local-ahead-icon        $' \uf178 '
    local-behind-icon       $'\uf177 '
    local-ahead-behind-icon $' ⇆ '
    local-synced-icon       $' \uf9e5'
    subtree-icon            $' \uf828 '
    submodule-icon          $' \uf827 '
    vcsclean-divider-icon   $'\uf142'
    vcsdirty-divider-icon   $'\uf142'
    issubmod-icon           $'\uf827 '
    root-icon               $'\uf292'
    user-icon               $'\uf155'
)


new-group() { # 1- refvar 2- group name 3- next group name 4- group value

    argv=( "${argv[@]}" )
    if [[ -z "$LAST_GROUP" ]]; then
        typeset -g "$1"="${refrezsh_tc[${2}-group]}${3:-}"
    else
        typeset -g "$1"="${refrezsh_tc[${2}-group-bg]}${refrezsh_tc[${LAST_GROUP}-group-rfg]}${refrezsh_icons[$2-sep]}${refrezsh_tc[${2}-group]}${3:-}"
    fi
    LAST_GROUP="$2"
}
new-icon() { #local REFVAR="$1" GROUP_NAME ICON_NAME APPEND_VAL
    4="${4:-}"
    typeset -g "$1"="${refrezsh_tc[$3-icon-fg]}${refrezsh_icons[$3-icon]}${refrezsh_tc[$2-group-fg]}$4"
}

end-prompt() {
    argv=( "${argv[@]}" )
    if [[ -z "$LAST_GROUP" ]]; then
        typeset -g "$1"="${refrezsh_tc[${LAST_GROUP}-group]}"
    else
        true
        typeset -g "$1"=$'\e[40m'"${refrezsh_tc[${LAST_GROUP}-group-rfg]}${refrezsh_icons[${LAST_GROUP}-sep]}"
    fi
    LAST_GROUP="!"
}
