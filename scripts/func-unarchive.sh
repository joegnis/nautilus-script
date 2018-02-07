#!/bin/bash
# Unarchive function
# Usage: unarchive (No arguments)
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"

function filter_entry {
    [ -f "$1" ]
}

function unarchive_entry {
    # Test if encrypted
    encrypted=false
    num_encrypted=$( 7z l -slt -- "$ENTRY" | grep -i -c "Encrypted = +" )
    if [ "$num_encrypted" -gt 0 ]; then
        encrypted=true
    fi
    if [ "$encrypted" = true ]; then
        entry="$(zenity --title "$ENTRY_ESCAPED" --password)"
        case $? in
            0)
                password="$(echo "$entry" | cut -d'|' -f2)"
                ;;
            1)
                return ;;
            -1)
                ERROR=An unexpected error has occurred.
                return 1 ;;
        esac
    fi

    dir_name="${ENTRY%.*}"
    7z x "$ENTRY" -o"$dir_name" -p"$password"
}

function unarchive {
    entries=("$@")
    cmd=("unarchive_entry")
    foreach_entry entries cmd filter_entry "Unarchive Preview" "Unarchive these directories?"
}
