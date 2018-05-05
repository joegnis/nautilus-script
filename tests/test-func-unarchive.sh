#!/usr/bin/env bash_unit
source ../scripts/func-unarchive.sh

function test_func_is_tar_xx {
    assert "is_tar_xx abc.tar.gz"
    assert "is_tar_xx abc.tar.xz"
    assert "is_tar_xx abc.tar.bz2"
    assert_fail "is_tar_xx abc.tar"
    assert_fail "is_tar_xx abc"
    assert_fail "is_tar_xx a.b.c"
    assert_fail "is_tar_xx abc.tar.xx"
}

# vi: ft=sh
