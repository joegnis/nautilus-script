#!/bin/bash
dir_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$dir_script/func-foreach-entry.sh"

function filter_target {
    return
}

function action_target {
    local sleep_time=$((RANDOM % 1))
    sleep $sleep_time
}

function test {
    entries=("$@")
    cmd=("action_target")
    foreach_entry entries cmd filter_target "Test Preview" "Test these?"
}

test "$@"
