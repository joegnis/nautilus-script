#!/bin/bash
# Unarchive function
# Usage: unarchive entry1 entry2 ...
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"

function filter_entry {
    [ -f "$1" ]
}

##############################################################################
# Test if a file has the extension .tar.gz, .tar.xz, or .tar.bz2
# Arguments:
#   1: the file
# Returns:
#   None
##############################################################################
function is_tar_xx {
    result=1
    for ext in {.tar.gz,.tar.xz,.tar.bz2}; do
        output="$(basename "$1" $ext)"
        ! [ "$output" = "$1" ] || [ $result = 0 ]
        result=$?
    done
    [ $result = 0 ]
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

    if is_tar_xx "$ENTRY"; then
        # Use 7z twice to unarchive
        dir_name="${ENTRY%%.*}"
        # Silence output to "return" dir_name
        7z x "$ENTRY" -o"$dir_name" -p"$password" >& /dev/null
        # TODO: Can't handle encrypted archives
        second_archive="${ENTRY%.*}"
        7z x "$dir_name/$second_archive" -o"$dir_name" >& /dev/null
        rm "$dir_name/$second_archive"
        echo "$dir_name"
    else
        dir_name="${ENTRY%.*}"
        LC_ALL="$lc_all" 7z x "$ENTRY" -o"$dir_name" -p"$password" >& /dev/null
        echo "$dir_name"
    fi
}

function unarchive {
    entries=("$@")
    cmd=("unarchive_entry")
    foreach_entry entries cmd filter_entry "Unarchive Preview" "Unarchive these directories?"
}
