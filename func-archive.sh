#!/bin/bash
# Archive function used by scripts: "archive *"
#   which archive all the files in each selected directory into a file of the name of
#   the corresponding directory
# Usage: archive "cmd" ".suffix"
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
function cgi_escape {
    /usr/bin/env python -c "import cgi; print(cgi.escape('$1'))"
}

function archive {
    cmd=$1
    suffix=$2  # e.g. ".7z"
    current_directory="$(pwd)"

    declare -a targets
    declare -a targets_escaped  # text passed to zenity needs to be escaped
    declare -a targets_full  # full path to targests
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
        --title "Archive Preview" \
        --text "Archive these directories?\n\n$(join_by $'\n' "${targets_escaped[@]}")"

    [ "$?" -ne 0 ] && exit 0

    for ((i = 0; i < ${#targets[@]}; i++)); do
        target="${targets[$i]}"
        target_escaped="${targets_escaped[$i]}"
        target_full="${targets_full[$i]}"

        archive_name="$target$suffix"
        count=1
        while [ -e "$current_directory/$archive_name" ]; do
            archive_name="${target}_$count$suffix"
            count=$(( count + 1 ))
        done

        cd "$target_full"
        $cmd "$current_directory/$archive_name" -- * &
        pid_task=$!

        ( while [ -e /proc/$pid_task ]; do sleep 0.1; done
          echo "# Compressed"
          echo 100 ) | {
          zenity --progress \
            --text="Compressing... (fake progress)" \
            --title="Compressing $target_escaped" \
            --percentage=$(( 20 + RANDOM % 41 )) || {
                [ -e /proc/$pid_task ] && to_delete=1
                kill $pid_task
                [ "$to_delete" -eq 1 ] && rm "$current_directory/$archive_name"
            }
        } &
    done
}
