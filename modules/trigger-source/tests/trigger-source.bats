#! /usr/bin/env bats
## -*- sh -*-

load "../../../tests/incubator"

@test 'trigger-source: default trigger() works' {
        sleep 15s
        cmp_log_with_string trigger-source.default \
                            "syslog-ng[$SNG_PID]: Trigger source is trigger happy."
}

@test 'trigger-source: trigger(trigger-freq()) works' {
        sleep 1s
        cmp_log_with_string trigger-source.trigger-freq \
                            "syslog-ng[$SNG_PID]: Trigger source is trigger happy."
}

@test 'trigger-source: trigger(trigger-message()) works' {
        sleep 1s
        cmp_log_with_string trigger-source.trigger-message \
                            "syslog-ng[$SNG_PID]: Testing!"
}
