## -*- sh -*-

start_sng () {
        config=${1:-$(basename $(cd ${BATS_TEST_DIRNAME}/..; pwd)).conf}
        syslog-ng --module-path="${SNG_MODULE_PATH}" \
                  --verbose \
                  -f ${BATS_TEST_DIRNAME}/${config} \
                  --no-caps --process-mode=background \
                  -R ${SNG_TMPDIR}/syslog-ng.persist \
                  -c ${SNG_TMPDIR}/syslog-ng.ctl \
                  -p ${SNG_TMPDIR}/syslog-ng.pid
        SNG_PID=$(cat $SNG_TMPDIR/syslog-ng.pid)
        export SNG_PID
        syslog-ng-ctl debug -c ${SNG_TMPDIR}/syslog-ng.ctl -s on || true
}

stop_sng () {
        kill $(cat ${SNG_TMPDIR}/syslog-ng.pid)
}

send_log_to () {
        target=$1
        amount=${2:-1}

        loggen -QxS ${SNG_TMPDIR}/${target}.sock -n ${amount} >/dev/null 2>/dev/null
}

cmp_log_with_string () {
        logfile=${SNG_TMPDIR}/$1.log
        actual=${2}
        filter=${3:-cat}
        expected=$(grep -v '^#' ${logfile} | eval ${filter} || true)
        if test "${expected}" = "${actual}"; then
                return 0
        else
                echo "'${actual}' != '${expected}' (expected)"
                return 1
        fi
}

find_in_internal_log () {
        logfile=${SNG_TMPDIR}/$1.internal.log
        actual=$2
        count=$3

        found=$(grep -c "${actual}" ${logfile} || true)
        if test $found != $count; then
                echo "Found '${actual}' ${found} times, expected ${count}."
                return 1
        else
                return 0
        fi
}

setup () {
        cd ${top_srcdir}/scl
        scldir=$(pwd)
        cd -
        export scldir
        PATH=${SNG_PREFIX}/sbin:${SNG_PREFIX}/bin:${PATH}
        export PATH
        SNG_TMPDIR=${BATS_TMPDIR}/sng
        export SNG_TMPDIR

        SNG_BUILT_MODULES=$(cd ${top_srcdir}; find modules -maxdepth 1 \
                                 -type d -and -not -name 'modules' \
                                 -printf "${top_builddir}/%p:${top_builddir}/%p/.libs:")

        SNG_MODULE_PATH=${moduledir}:${SNG_BUILT_MODULES}
        export SNG_MODULE_PATH
        rm -rf "${SNG_TMPDIR}"
        install -d ${SNG_TMPDIR}

        start_sng
}

teardown () {
        stop_sng
        sleep 1s
}
