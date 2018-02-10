#!/bin/bash
# Unarchive and convmv function
# Usage: unarchive_and_convmv entry1 entry2 ...
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"
source "$dir_script/func-unarchive.sh"

##############################################################################
# Unarchive a file using function unarchive_entry, and convmv the directory
# from GBK to UTF8.
# Before unarchiving, prompt for from encoding.
# Globals:
#   ENTRY
#   ENTRY_FULL
#   ENTRY_ESCAPED
# Arguments:
#   None
# Returns:
#   None
##############################################################################
function unarchive_and_convmv_entry {
    # If user enters nothing/invalid from encoding, unarchive as it is
    unarchive_para=true
    if from_encoding="$(zenity --entry \
        --title="Convmv filename to UTF-8" \
        --text="Enter encoding\ne.g. GBK, Shift-JIS" \
        --entry-text "GBK")"
    then
        from_encoding="$(sed 's/-//g' <<<"$from_encoding")"
        shopt -s nocasematch
        if [ -z "$from_encoding" ] || \
            ([[ $from_encoding != gbk ]] && \
             ! convmv --list | grep -iqF "$from_encoding")
        then
            unarchive_para=
        fi
        shopt -u nocasematch
    else
        unarchive_para=
    fi

    dir_name="$(unarchive_entry $unarchive_para)"
    exit_code="$?"
    [ "$exit_code" -ne 0 ] && return $exit_code

    # Sort all entries by depth descendingly
    if [ "$unarchive_para" = true ]; then
        find "$dir_name" ! -path "$dir_name" -printf "%d %p\n" | \
            sort -nr | sed -r 's#^[0-9]+\s##' | \
            while read -r entry; do
                convmv -f "$from_encoding" -t utf8 --notest -- "$entry"
            done
    fi
}

function unarchive_and_convmv {
    entries=("$@")
    cmd=("unarchive_and_convmv_entry")
    foreach_entry entries cmd filter_entry "Unarchive Preview" "Unarchive these directories?"
}
