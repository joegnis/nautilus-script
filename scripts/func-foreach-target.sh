#!/bin/bash
# Function that iterates each of the selected nodes and apply action on it
# Usage: foreach_target "preview_title" "preview_text" action_cmd...
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
function cgi_escape {
    /usr/bin/env python -c "import cgi; print(cgi.escape('$1'))"
}

function foreach_target {
    preview_title=$1; shift
    preview_text=$1; shift  # e.g. ".7z"

    declare -a targets
    declare -a targets_escaped  # text passed to zenity needs to be escaped
    declare -a targets_full  # full path to targets
    for target in "${BASH_ARGV[@]}"; do
        target_full="$(realpath "$target")"
        if [ -d "$target_full" ]; then
            targets+=("$target")
            targets_escaped+=("$( cgi_escape "$target")")
            targets_full+=("$target_full")
        fi
    done

    if [ "${#targets_full[@]}" -eq 0 ]; then
        zenity --info \
            --text "No directories selected"
        exit 0
    fi

    zenity --question \
        --title "$preview_title" \
        --text "$preview_text\n$(join_by $'\n' "${targets_escaped[@]}")"

    [ "$?" -ne 0 ] && exit 0

    for ((i = 0; i < ${#targets[@]}; i++)); do
        TARGET="${targets[$i]}"
        TARGET_ESCAPED="${targets_escaped[$i]}"
        TARGET_FULL="${targets_full[$i]}"
        "$@"
    done
}
