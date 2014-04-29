#! /usr/bin/env bats
## -*- sh -*-

load "../../../tests/incubator"

@test 'basicfuncs+: $(or) returns the first non-empty element' {
        send_log_to basicfuncs-plus.or
        cmp_log_with_string basicfuncs-plus.or "prg00000 "
}

@test 'basicfuncs+: $(//) works, and returns a float' {
        send_log_to basicfuncs-plus.divx
        cmp_log_with_string basicfuncs-plus.divx "0.500000 0"
}

@test 'basicfuncs+: $(//) fails with not enough parameters' {
        send_log_to basicfuncs-plus.divx.not-enough-params
        cmp_log_with_string basicfuncs-plus.divx.not-enough-params "NaN NaN"
        find_in_internal_log basicfuncs-plus.divx.not-enough-params \
                             "^Template function requires two arguments.; function='//'$" \
                             2
}

@test 'basicfuncs+: $(//) fails when a parameter is NaN' {
        send_log_to basicfuncs-plus.divx.NaN
        cmp_log_with_string basicfuncs-plus.divx.NaN "NaN NaN NaN"
        find_in_internal_log basicfuncs-plus.divx.NaN \
                             "argument is not a number" \
                             3
}

@test 'basicfuncs+: $(state) works' {
        send_log_to basicfuncs-plus.state
        cmp_log_with_string basicfuncs-plus.state " 1234 1234"
}

@test 'bascifuncs+: $(state) fails with not 1 or 2 arguments' {
        send_log_to basicfuncs-plus.state.fail
        cmp_log_with_string basicfuncs-plus.state.fail ""
        find_in_internal_log basicfuncs-plus.state.fail \
                             'The \$(state) template function requires either one or two arguments.' \
                             2
}
