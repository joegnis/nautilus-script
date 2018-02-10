#!/bin/bash
# Unarchive and convmv function
# Usage: unarchive_and_convmv entry1 entry2 ...
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"
source "$dir_script/func-unarchive.sh"

##############################################################################
# Convmv filename from GBK to UTF8
# Arguments:
#   @: filenames
# Returns:
#   None
##############################################################################
function convmv_filename {
    convmv -f gbk -t utf8 --notest -- "$@"
}

##############################################################################
# Unarchive a file using function unarchive_entry, and convmv the directory
# from GBK to UTF8.
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
    export LC_ALL=C
    dir_name="$(unarchive_entry)"
    exit_code="$?"
    export LC_ALL=
    [ "$exit_code" -ne 0 ] && return $exit_code

    # Sort all entries by depth descendingly
    find "$dir_name" ! -path "$dir_name" -printf "%d %p\n" | \
        sort -nr | sed -r 's#^[0-9]+\s##' | \
        while read -r entry; do
            convmv_filename "$entry"
        done
}

function unarchive_and_convmv {
    entries=("$@")
    cmd=("unarchive_and_convmv_entry")
    foreach_entry entries cmd filter_entry "Unarchive Preview" "Unarchive these directories?"
}
