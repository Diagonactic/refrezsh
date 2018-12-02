#!/usr/bin/env zsh
declare -gA refrezsh=( )
(( ${+REFREZSH_ROOT} ))     || declare -gh REFREZSH_ROOT="${${(%):-%x}:A:h:h}"

declare -gA refrezsh=(
    root-dir   "$REFREZSH_ROOT"
    themes-dir "$REFREZSH_ROOT/themes"
)
