#!/bin/bash
# Unarchive function
# Usage: unarchive entry1 entry2 ...
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"

function filter_entry {
    [ -f "$1" ]
}

##############################################################################
# Unarchive a file, prompt for password if file is encrypted
# Globals:
#   ENTRY
#   ENTRY_FULL
#   ENTRY_ESCAPED
# Arguments:
#   1: if set to true, set LC_ALL=C when unarchiving
# Returns:
#   None
# Stdout:
#   Target directory, if 7z is executed
##############################################################################
function unarchive_entry {
    lc_all="$LC_ALL"
    shopt -s nocasematch
    if [ "$#" -gt 0 ] && [[ $1 = true ]]; then
        lc_all=C; shift
    fi
    shopt -u nocasematch
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
            255)
                ERROR=An unexpected error has occurred.
                return 1 ;;
        esac
    fi

    dir_name="${ENTRY%.*}"
    echo "$dir_name"
    # Silence output to "return" dir_name
    LC_ALL="$lc_all" 7z x "$ENTRY" -o"$dir_name" -p"$password" >& /dev/null
}

function unarchive {
    entries=("$@")
    cmd=("unarchive_entry")
    foreach_entry entries cmd filter_entry "Unarchive Preview" "Unarchive these directories?"
}
