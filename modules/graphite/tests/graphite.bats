#! /usr/bin/env bats
## -*- sh -*-

load "../../../tests/incubator"

@test 'graphite: $(graphite-output) works' {
        send_log_to graphite.graphite-output
        cmp_log_with_string graphite.graphite-output \
                            "PID 1234
PROGRAM prg00000" \
                            "cut -d ' ' -f1-2"
}
