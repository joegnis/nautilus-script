#!/bin/bash
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
function cgi_escape {
    /usr/bin/env python -c "import cgi; print(cgi.escape('$1'))"
}

##############################################################################
# Execute command on each entry and output exit code and entry to the named
# pipe.
#
# Arguments:
#   @: command
# Globals:
#   ENTRY, ENTRY_FULL, ENTRY_ESCAPED: current entry
#   RES_FILE: the named pipe
# Returns:
#   return of the command
##############################################################################
function execute_command {
    local ENTRY="$ENTRY"
    "$@"
    local EXIT_CODE="$?"
    (typeset -p EXIT_CODE ENTRY | tr '\n' ';' ; echo "") >> "$RES_FILE" >&5
    return $EXIT_CODE
}

##############################################################################
# Execute command to each selected entry and show summary dialog at the end
#
# Arguments:
#   1: Variable of an array of selected entries
#   2: Variable of an array of command and its args
#        that are going to be executed on each entry.
#        Variables available to the command:
#           ENTRY, ENTRY_FULL, ENTRY_ESCAPED,
#           RES_FILE
#   3: Name of a function which takes only one argument that is a
#        selected entry to filter out wanted entries
#   4: Title string of preview dialog
#   5: Text string of preview dialog
#
# Returns:
#   None
##############################################################################
function foreach_entry {
    declare -n _entries=$1; shift
    declare -n _command=$1; shift
    filter_func=$1; shift
    preview_title=$1; shift
    preview_text=$1; shift

    declare -a entries_escaped  # text passed to zenity needs to be escaped
    declare -a entries_full  # full path to entries
    for entry in "${_entries[@]}"; do
        entry_full="$(realpath "$entry")"
        if $filter_func "$entry_full"; then
            entries_escaped+=("$( cgi_escape "$entry")")
            entries_full+=("$entry_full")
        fi
    done

    if [ "${#entries_full[@]}" -eq 0 ]; then
        zenity --info \
            --text "No directories selected"
        exit 0
    fi

    zenity --question \
        --title "$preview_title" \
        --text "$preview_text\n$(join_by $'\n' "${entries_escaped[@]}")"

    [ "$?" -ne 0 ] && exit 0

    RES_FILE=$(mktemp --dry-run)
    trap "rm -f $RES_FILE" EXIT
    mkfifo "$RES_FILE"
    exec 5<>"$RES_FILE"

    declare -a pid_array
    declare -A pid_entry_dict
    num_entry=${#_entries[@]}
    for ((i = 0; i < num_entry; i++)); do
        ENTRY="${_entries[$i]}"
        ENTRY_ESCAPED="${entries_escaped[$i]}"
        ENTRY_FULL="${entries_full[$i]}"
        execute_command "${_command[@]}" &
    done

    result=$(mktemp)
    trap "rm -f $result" EXIT
    (
    progress=0
    step=$(echo "scale=4; 100/$num_entry" | bc)
    i=0
    while true; do
        if read res <"$RES_FILE"; then
            let i++
            eval "$res"  # get EXIT_CODE and ENTRY
            local entry_escaped="$( cgi_escape "$ENTRY")"
            if [ "$EXIT_CODE" -ne 0 ]; then
                echo "Fail: $entry_escaped" >> "$result"
                echo "# ($i/$num_entry) Failed to process: \"$ENTRY\""
            else
                echo "# ($i/$num_entry) Processed: \"$ENTRY\""
                echo "Success: $entry_escaped" >> "$result"
            fi

            progress=$(echo "scale=4; $progress + $step" | bc)
            echo "$progress"

            if [ "$i" -eq "$num_entry" ]; then
                sleep 1
                break
            fi
        fi
    done
    ) |
    zenity --progress \
        --text="Processing... " \
        --title="Processing" \
        --percentage=0 \
        --auto-close

    if [ "$?" -eq -1 ]; then
        zenity --error \
            --text="Process canceled."
        exit
    fi

    zenity --info \
        --text="$(<"$result")"
}
