#!/usr/bin/env zsh

is-git-repository() { \git rev-parse --is-inside-work-tree 2>/dev/null }

(( ${+gitrp_safeparms} == 1 )) || local -ar gitrp_safeparms=(
    --show-toplevel
    --git-dir
    --is-bare-repository
    --show-superproject-working-tree
)
# NOTE: --show-superproject-working-tree This must be last; it returns nothing (not even a blank line) when there's no submodule

# Associations set - git_property_map repo_status_unstaged repo_status_staged repo_subtrees repo_submodule_branches
# Arrays set       - repo_remotes git_status repo_submodules
repo-details() {
    get-gitinfo() {
        \git remote -v 2>/dev/null || { return 1 }
        print -- --
        \git rev-parse HEAD 2>/dev/null || print detached
        \git rev-parse "${gitrp_safeparms[@]}" 2>/dev/null || {
            print -- 'not initialized'
            return 1
        }
        print -- --
        \git submodule --quiet foreach 'git rev-parse --show-toplevel --abbrev-ref HEAD'
        print -- --
        \git status --porcelain -b 2>/dev/null
    }
    store-array-slice() {
        # If the first element in the array is a --, then the "section" was empty
        [[ "${2:---}" != '--' ]] || { set -A "$1"; shift 2; typeset -ga new_argv=( "$@" ); return 0 }

        local __AR_NAME="$1"; shift
        (( $# == 0 )) && set -A "$__AR_NAME" || set -A "$__AR_NAME" "${(@)${(@)argv[1,$(( ${argv[(i)--]} - 1 ))]}[@]}"
        shift $(( ${#${(P@)__AR_NAME}} + 1 ))
        typeset -ga new_argv=( "$@" )
    }

    typeset -gA git_property_map=( ) repo_status_unstaged=( ) repo_status_staged=( ) repo_subtrees=( ) repo_submodule_branches=( )
    typeset -ga repo_remotes=( ) repo_submodules=( )
    is-git-repository || return $?

    local -a git_remotes=( ) git_props=( ) submod_result=( ) git_submodule_branches=( )

    () {
        local -a new_argv=( )
        store-array-slice git_remotes "$@"
        argv=( "${new_argv[@]}" )
        [[ "$1" == '--' ]] && { shift; typeset -gxa git_props=( ) } || {
            [[ "${argv[1]}" != 'HEAD' ]] || shift
            store-array-slice git_props "$@"; argv=( "${new_argv[@]}" )
        }
        store-array-slice submod_result "$@"
        argv=( "${new_argv[@]}" )
        typeset -gxa git_status=( "$@" )
    } "${${(f)$(get-gitinfo)}[@]}" || return $?

    local -r  REPO_CONFIG="${${(M)git_status[@]:#\#*}##\#\# }"
    local -ra git_status=( "${git_status[@]:#\#\# *}" )

    local -A prop_map=(
        nearest-root  "${git_props[2]}"
        git-rev       "${git_props[1]}"
        local-branch  "${${${(M)REPO_CONFIG:#* on *}:+${REPO_CONFIG##* }}:-${REPO_CONFIG%%...*}}"
        remote-branch "${${${${(M)REPO_CONFIG:#* on *}:+[none]}:-${REPO_CONFIG##*...}}%%[[:space:]\[]*}"
        has-commits   "${${${(M)REPO_CONFIG:#No commits yet on *}:+0}:-1}"
        has-remotes   "${${${(M)${#git_remotes[@]}:#0}:+no}:-yes}"
        ahead-by      "${${${(M)REPO_CONFIG:#*\[ahead*}:+${${REPO_CONFIG##*\[ahead[[:space:]]}%%[\],]*}}:-0}"
        behind-by     "${${${(M)REPO_CONFIG:#*(\[|, )behind*}:+${${REPO_CONFIG##*(\[|, )behind[[:space:]]}%%[\],]*}}:-0}"
        git-dir       "${${${git_props[3]}:A}##${git_props[2]}/}"
        is-bare       "${${${(M)${git_props[4]}:#true}:+1}:-0}"
        parent-repo   "${git_props[5]:-}"
        is-submodule  0
    )

    [[ "${${prop_map[git-dir]}:h:t}" != "modules" ]] || prop_map[is-submodule]=1
    [[ "${prop_map[local-branch]}" != "${prop_map[remote-branch]}" ]] || prop_map[remote-branch]=''

    [[ -z "${submod_result}" ]] || {
        typeset -ga repo_submodules=( "${${(M@)submod_result[@]:#/*}[@]##${prop_map[nearest-root]}/}" )
        typeset -gA repo_submodule_branches=( "${submod_result[@]}" )
    }

    typeset -ga u_ren=( ${(@)${(M)git_status:#([AMDR ]R *)}##???} )  s_ren=( ${(@)${(M)git_status:#M[AMDR ] *}##???} )  \
                u_mod=( ${(@)${(M)git_status:#([AMDR ]M *)}##???} )  s_mod=( ${(@)${(M)git_status:#R[AMDR ] *}##???} )  \
                u_add=( ${(@)${(M)git_status:#([AMDR ]A *)}##???} )  s_add=( ${(@)${(M)git_status:#A[AMDR ] *}##???} )  \
                u_del=( ${(@)${(M)git_status:#([AMDR ]D *)}##???} )  s_del=( ${(@)${(M)git_status:#D[AMDR ] *}##???} )  \
                u_new=( ${(@)${(M)git_status:#\?\?*}##???} )

    local RP
    for RP in u_{ren,mod,add,del,new}; do repo_status_unstaged+=( "${RP##u_}-paths"  "${(j.:.)${(q@)${(P@)RP}}}" "${RP##u_}-len" ${#${(P@)RP}} ); done
    for RP in s_{ren,mod,add,del}; do repo_status_staged+=( "${RP##s_}-paths"  "${(j.:.)${(q@)${(P@)RP}}}" "${RP##s_}-len" ${#${(P@)RP}} ); done

    typeset -gA git_property_map=( "${(kv)prop_map[@]}" )

    if [[ "${git_property_map[remote-branch]}" == '[none]' ]]; then git_property_map[remote-branch]=''; fi
}
