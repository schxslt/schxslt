#!/usr/bin/env bats
#===============================================================================
#
#         USAGE:  bats schematron.bats
#
#   DESCRIPTION:  Unit tests for SchXslt
#
#         INPUT:  N/A
#
#        OUTPUT:  Unit tests results
#
#  DEPENDENCIES:  This script requires bats (https://github.com/sstephenson/bats)
#
#        AUTHOR:  David Maus
#
#       LICENSE:  MIT License (https://opensource.org/licenses/MIT)
#                 See 'LICENSE' in this directory
#
#===============================================================================

function setup () {
    export SCHEMATRON_XSLT_INCLUDE=${BATS_CWD}/src/xslt/include.xsl
    export SCHEMATRON_XSLT_EXPAND=${BATS_CWD}/src/xslt/expand.xsl
    export SCHEMATRON_XSLT_COMPILE=${BATS_CWD}/src/xslt/compile.xsl
}

function schematron () {
    run xspec -s ${BATS_CWD}/tests/impl/${1}
    echo "${output}"
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "failed: 0" ]]
    [[ "${output}" =~ "Done." ]]
}

function xslt () {
    run xspec ${BATS_CWD}/tests/xslt/${1}
    echo "${output}"
    [ "${status}" -eq 0 ]
    [[ "${output}" =~ "failed: 0" ]]
    [[ "${output}" =~ "Done." ]]
}

@test "let/let-scope-01.xspec" {
    schematron let/let-scope-01.xspec
}

@test "let/let-scope-02.xspec" {
    schematron let/let-scope-02.xspec
}

@test "name/svrl-name-01.xspec" {
    schematron name/svrl-name-01.xspec
}

@test "phase/phase-01.xspec" {
    schematron phase/phase-01.xspec
}

@test "phase/phase-02.xspec" {
    schematron phase/phase-02.xspec
}

@test "phase/phase-03.xspec" {
    schematron phase/phase-03.xspec
}

@test "phase/phase-04.xspec" {
    schematron phase/phase-04.xspec
}

@test "rule/rule-context-01.xspec" {
    schematron rule/rule-context-01.xspec
}

@test "rule/rule-order-01.xspec" {
    schematron rule/rule-order-01.xspec
}

@test "rule/rule-order-02.xspec" {
    schematron rule/rule-order-02.xspec
}

@test "value-of/svrl-value-of-01.xspec" {
    schematron value-of/svrl-value-of-01.xspec
}

@test "pattern/expand-abstract-01.xspec" {
    schematron pattern/expand-abstract-01.xspec
}

@test "pattern/expand-abstract-02.xspec" {
    schematron pattern/expand-abstract-02.xspec
}

@test "pattern/expand-abstract-03.xspec" {
    schematron pattern/expand-abstract-02.xspec
}

@test "pattern/expand-abstract-04.xspec" {
    schematron pattern/expand-abstract-04.xspec
}

@test "include/include-01.xspec" {
    schematron include/include-01.xspec
}

@test "include/include-02.xspec" {
    schematron include/include-02.xspec
}

@test "extends/extends-01.xspec" {
    schematron extends/extends-01.xspec
}

@test "xslt/expand.xspec" {
    xslt expand.xspec
}

@test "xslt/include.xspec" {
    xslt include.xspec
}
