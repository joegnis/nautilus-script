#!/bin/bash
# Archive function used by scripts: "archive *"
#   which archive all the files in each selected directory into a file of the name of
#   the corresponding directory
# Usage: archive "cmd" ".suffix"
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"

function filter_entry {
    [ -d "$1" ]
}

function archive_entry {
    cmd=$1
    suffix=$2  # e.g. ".7z"
    current_directory="$(pwd)"

    archive_name="$ENTRY$suffix"
    count=1
    while [ -e "$current_directory/$archive_name" ]; do
        archive_name="${ENTRY}_$count$suffix"
        count=$(( count + 1 ))
    done

    cd "$ENTRY_FULL"
    $cmd "$current_directory/$archive_name" -- *
}

function archive {
    archive_cmd="$1"; shift
    archive_suffix="$1"; shift
    entries=("$@")
    cmd=("archive_entry" "$archive_cmd" "$archive_suffix")
    foreach_entry entries cmd filter_entry "Archive Preview" "Archive these directories?"
}
