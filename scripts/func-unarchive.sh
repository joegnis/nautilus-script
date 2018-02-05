#!/bin/bash
# Unarchive function
# Usage: unarchive (No arguments)
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-target.sh"

function filter_target {
    [ -f "$1" ]
}

function unarchive_target {
    # Test if encrypted
    encrypted=false
    num_encrypted=$( 7z l -slt -- "$TARGET" | grep -i -c "Encrypted = +" )
    if [ "$num_encrypted" -gt 0 ]; then
        encrypted=true
    fi
    if [ "$encrypted" = true ]; then
        entry="$(zenity --title "$TARGET_ESCAPED" --password)"
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

    dir_name="${TARGET%.*}"
    7z x "$TARGET" -o"$dir_name" -p"$password" &
    pid_task=$!

    ( while [ -e /proc/$pid_task ]; do sleep 0.1; done
      echo "# Unarchive"
      echo 100 ) | {
      zenity --progress \
        --text="Unarchiving... (fake progress)" \
        --title="Unarchiving $TARGET_ESCAPED" \
        --percentage=$(( 20 + RANDOM % 41 )) || {
            [ -e /proc/$pid_task ] && to_delete=1
            kill $pid_task
            [ "$to_delete" -eq 1 ] && rm -r "$dir_name"
        }
    } &
}

function unarchive {
    foreach_target filter_target "Unarchive Preview" "Unarchive these directories?" unarchive_target
}
