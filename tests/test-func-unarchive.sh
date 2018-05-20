#!/usr/bin/env bash_unit
source ../scripts/func-unarchive.sh

function test_strip_off_tar_xx {
    assert_equals "$(strip_off_tar_xx abc.tar.gz)" abc
    assert_equals "$(strip_off_tar_xx abc.tgz)" abc
    assert_equals "$(strip_off_tar_xx abc.tar.xz)" abc
    assert_equals "$(strip_off_tar_xx abc.txz)" abc
    assert_equals "$(strip_off_tar_xx abc.tar.bz2)" abc
    assert_equals "$(strip_off_tar_xx abc.tb2)" abc
    assert_equals "$(strip_off_tar_xx abc.tbz2)" abc
    assert_equals "$(strip_off_tar_xx abc.tar.lz)" abc
    assert_equals "$(strip_off_tar_xx abc.tar.lzma)" abc
    assert_equals "$(strip_off_tar_xx abc.tlz)" abc
    assert_equals "$(strip_off_tar_xx abc.tar.Z)" abc
    assert_equals "$(strip_off_tar_xx abc.tZ)" abc

    assert_equals "$(strip_off_tar_xx abc.0.1.0.tar.gz)" abc.0.1.0
}
# vi: ft=sh
