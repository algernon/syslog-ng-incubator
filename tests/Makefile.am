TESTS_ENVIRONMENT		 			 = \
	top_builddir="$(shell pwd)"			   \
	top_srcdir="$(shell cd ${top_srcdir}; pwd)"	   \
	moduledir="${moduledir}"			   \
	SNG_PREFIX=$(shell pkg-config --variable prefix syslog-ng)
TESTCASES			 			 =
EXTRA_DIST						+= \
	tests/incubator.bash				   \
	${top_srcdir}/tests/bats

check: all
	${AM_V_GEN} ${TESTS_ENVIRONMENT} \
		prove -e "${top_srcdir}/tests/bats/libexec/bats --tap" -f \
		      -o ${PROVE_OPTIONS} \
		      $(addprefix ${top_srcdir}/,${TESTCASES})
