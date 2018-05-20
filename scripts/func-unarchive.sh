#!/bin/bash
# Unarchive function
# Usage: unarchive entry1 entry2 ...
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"

function filter_entry {
    [ -f "$1" ]
}

##############################################################################
# Remove the extension from a filename if it's one of:
#   .tar.gz, .tgz,
#   .tar.xz, .txz,
#   .tar.bz2, .tb2, .tbz, tbz2,
#   .tar.lz,
#   .tar.lzma, .tlz,
#   .tar.Z, .tZ
# And return the stripped filename. If not, return the original filename.
# Arguments:
#   1: filename
# Stdout:
#   filename
##############################################################################
function strip_off_tar_xx {
    extensions=(.tar.gz .tgz)
    extensions+=(.tar.xz .txz)
    extensions+=(.tar.bz2 .tb2 .tbz2)
    extensions+=(.tar.lz)
    extensions+=(.tar.lzma .tlz)
    extensions+=(.tar.Z .tZ)
    for ext in "${extensions[@]}"; do
        output="$(basename "$1" "$ext")"
        ! [ "$output" = "$1" ] && break
    done
    echo "$output"
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

    basename_entry="$(strip_off_tar_xx "$ENTRY")"
    if [ "$basename_entry" != "$ENTRY" ]; then
        # Use 7z twice to unarchive .tar.xx files
        dir_name="$basename_entry"
        # Silence output to "return" dir_name
        7z x "$ENTRY" -o"$dir_name" -p"$password" >& /dev/null
        # TODO: Can't handle encrypted archives
        second_archive="$basename_entry.tar"
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
