#!/bin/bash
# Archive function used by scripts: "archive *"
#   which archive all the files in each selected directory into a file of the name of
#   the corresponding directory
# Usage: archive "cmd" ".suffix"
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-target.sh"

function archive_target {
    cmd=$1
    suffix=$2  # e.g. ".7z"
    current_directory="$(pwd)"

    archive_name="$TARGET$suffix"
    count=1
    while [ -e "$current_directory/$archive_name" ]; do
        archive_name="${TARGET}_$count$suffix"
        count=$(( count + 1 ))
    done

    cd "$TARGET_FULL"
    $cmd "$current_directory/$archive_name" -- * &
    pid_task=$!

    ( while [ -e /proc/$pid_task ]; do sleep 0.1; done
      echo "# Compressed"
      echo 100 ) | {
      zenity --progress \
        --text="Compressing... (fake progress)" \
        --title="Compressing $TARGET_ESCAPED" \
        --percentage=$(( 20 + RANDOM % 41 )) || {
            [ -e /proc/$pid_task ] && to_delete=1
            kill $pid_task
            [ "$to_delete" -eq 1 ] && rm "$current_directory/$archive_name"
        }
    } &
}

function archive {
    foreach_target "Archive Preview" "Archive these directories?" archive_target "$@"
}
