#! /usr/bin/env bats
## -*- sh -*-

load "../../../tests/incubator"

@test 'getent: $(getent) fails with an unknown service' {
        send_log_to getent.error.none
        cmp_log_with_string getent.error.none ""
        find_in_internal_log getent.error.none \
                             "^Unsupported \\\$(getent) NSS service; service='whatever'" \
                             1
}

@test 'getent: $(getent) fails when argument numbers mismatch' {
        send_log_to getent.error.arg-mismatch
        cmp_log_with_string getent.error.arg-mismatch " "
        find_in_internal_log getent.error.arg-mismatch \
                             "^\\\$(getent) takes either two or three arguments" \
                             2
}

@test 'getent: $(getent services) works' {
        send_log_to getent.services
        cmp_log_with_string getent.services "http 80"
}

@test 'getent: $(getent services) fails properly with an unknown service' {
        send_log_to getent.services.fail
        cmp_log_with_string getent.services.fail ""
}

@test 'getent: $(getent passwd) works' {
        send_log_to getent.passwd
        cmp_log_with_string getent.passwd "root 0 0"
}

@test 'getent: $(getent passwd) fails when lookup fails' {
        send_log_to getent.passwd.lookup-fail
        cmp_log_with_string getent.passwd.lookup-fail " "
}

@test 'getent: $(getent passwd) fails when requesting an invalid member' {
        send_log_to getent.passwd.invalid-member
        cmp_log_with_string getent.passwd.invalid-member ""
        find_in_internal_log getent.passwd.invalid-member \
                             "^\\\$(getent passwd): unknown member.*whatever" \
                             1
}

@test 'getent: $(getent group) works' {
        send_log_to getent.group
        cmp_log_with_string getent.group "root 0 0"
}

@test 'getent: $(getent group) fails when lookup fails' {
        send_log_to getent.group.lookup-fail
        cmp_log_with_string getent.group.lookup-fail " "
}

@test 'getent: $(getent group) fails when requesting an invalid member' {
        send_log_to getent.group.invalid-member
        cmp_log_with_string getent.group.invalid-member ""
        find_in_internal_log getent.group.invalid-member \
                             "^\\\$(getent group): unknown member.*whatever" \
                             1
}
