dnl Process this file with autoconf to produce a configure script.
dnl

AC_PREREQ([2.68])

AC_INIT([syslog-ng-incubator], [0.3.3], [tusavik@gmail.com])
AM_INIT_AUTOMAKE([foreign subdir-objects dist-xz no-dist-gzip])

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([no])])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([config.h])

dnl ***************************************************************************
dnl definitions

moduledir='${exec_prefix}/lib/syslog-ng'

enable_value()
{
        if test "x$1" = "xyes" ; then
                echo 1
        else
                echo 0
        fi
}

dnl ***************************************************************************
dnl dependencies

GLIB_MIN_VERSION="2.14"
SYSLOG_NG_MIN_VERSION="3.5.5"
EVENTLOG_MIN_VERSION="0.2.10"
IVYKIS_MIN_VERSION="0.30.0"
LMC_MIN_VERSION="0.1.2"
LRC_MIN_VERSION="1.0.0"
LUA_MIN_VERSION="5.1.4"

dnl ***************************************************************************
dnl Initial setup

AC_ARG_ENABLE(debug,
   [  --enable-debug           Enable debugging code.],, enable_debug="no")

AC_ARG_WITH(module-dir,
   [  --with-module-dir=path   Use path as the list of directories looked up when searching for modules],
   moduledir=$with_module_dir,moduledir="auto")

AC_ARG_WITH(ivykis,
   [  --without-ivykis         Build without explicitly linking to ivykis])

AC_ARG_ENABLE(luajit,
   [  --enable-luajit          Use luajit instead of standard liblua for Lua support],
   enable_luajit="yes",)

AC_ARG_WITH(python,
   [  --with-python=VERSION    Build with a specific version of python],,with_python="auto")

AC_ARG_ENABLE(riemann,
   [  --disable-riemann	       Disable riemann destination],
   ,enable_riemann="auto")

AC_ARG_ENABLE(lua,
   [  --disable-lua	       Disable lua based modules (lua-dest, monitoring source)],
   ,enable_lua="auto")

AC_ARG_ENABLE(perl,	       
   [  --disable-perl	       Disable perl based modules (perl-dest)],
   ,enable_perl="auto")

AC_ARG_ENABLE(python,	       
   [  --disable-python	       Disable python based modules (python-dest)],
   ,enable_python="auto")

AC_ARG_ENABLE(logmongource,
   [  --disable-logmongource	      Disable logmongource tool],
   ,enable_logmongource="auto")


AC_ARG_ENABLE(kafka,
              [ --disable-kafka           Disable Kafka support (default: auto)]
              ,,enable_kafka="auto")

AC_ARG_WITH(librdkafka,
             AC_HELP_STRING([--with-librdkafka=DIR],
                            [use librdkafka library from (prefix) directory DIR]),,)


dnl ***************************************************************************
dnl Checks for programs.
AC_PROG_YACC
AC_PROG_CC
AC_PROG_CC_C_O
AC_PROG_CXX
AC_C_INLINE

LT_INIT([shared dlopen])

AC_PROG_MAKE_SET
PKG_PROG_PKG_CONFIG

dnl ***************************************************************************
dnl Miscellanneous headers
dnl ***************************************************************************

AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])
AC_CHECK_FUNCS([floor memrchr memset strdup strtoll])

dnl ***************************************************************************
dnl Header checks
dnl ***************************************************************************

dnl ***************************************************************************
dnl Checks for libraries
dnl ***************************************************************************
PKG_CHECK_MODULES(GLIB, glib-2.0 >= $GLIB_MIN_VERSION)

dnl ***************************************************************************
dnl syslog-ng headers/libraries
dnl ***************************************************************************

PKG_CHECK_MODULES(SYSLOG_NG, syslog-ng >= $SYSLOG_NG_MIN_VERSION)
PKG_CHECK_MODULES(EVENTLOG, eventlog >= $EVENTLOG_MIN_VERSION)

syslog_ng_ivykis=[`pkg-config syslog-ng --variable ivykis`]

if test "x$with_ivykis" != "xno" && test "x$syslog_ng_ivykis" != "xinternal"; then
   PKG_CHECK_MODULES(IVYKIS, ivykis >= $IVYKIS_MIN_VERSION,,true)
fi

syslog_ng_tools=[`pkg-config syslog-ng --variable toolsdir`]
if test "x$moduledir" = "xauto"; then
   moduledir=[`pkg-config syslog-ng --variable moduledir`]
fi

dnl ***************************************************************************
dnl libmongo-client headers/libraries
dnl ***************************************************************************
INCUBATOR_CHECK_DEP(logmongource,[PKG_CHECK_MODULES(LIBMONGO, libmongo-client >= $LMC_MIN_VERSION,,logmongource_found="no")])

dnl ***************************************************************************
dnl riemann-client headers/libraries
dnl ***************************************************************************
INCUBATOR_CHECK_DEP(riemann,[PKG_CHECK_MODULES(RIEMANN_CLIENT, riemann-client >= $LRC_MIN_VERSION,,riemann_found="no")])

dnl ***************************************************************************
dnl lua headers/libraries
dnl ***************************************************************************
dnl if test "x$enable_lua" != "xno"; then
INCUBATOR_CHECK_DEP(lua,[
  if test "x$enable_luajit" == "xyes"; then
   PKG_CHECK_EXISTS(luajit, [lua_mod="luajit"; LUA_MIN_VERSION="2.0"])
  fi
  if test "x$lua_mod" != "xluajit"; then
   PKG_CHECK_EXISTS(lua, lua_mod="lua",
    PKG_CHECK_EXISTS(lua5.2, lua_mod="lua5.2",
     PKG_CHECK_EXISTS(lua-5.2, lua_mod="lua-5.2",
      PKG_CHECK_EXISTS(lua5.1, lua_mod="lua5.1",
       PKG_CHECK_EXISTS(lua-5.1, lua_mod="lua-5.1")))))
  fi
  PKG_CHECK_MODULES(LUA, $lua_mod >= $LUA_MIN_VERSION,,lua_found="no")])

dnl ***************************************************************************
dnl Perl checks
dnl ***************************************************************************
INCUBATOR_CHECK_DEP(perl,[
  AC_CHECK_PROG(PERL, perl, perl)

  if test "x$PERL" != "x"; then
    AC_MSG_CHECKING(for perl module ExtUtils::Embed)
    $PERL -e "use ExtUtils::Embed; exit" >/dev/null 2>&1
    if test $? -ne 0; then
      AC_MSG_RESULT(no)
      perl_found="no"
    else
      AC_MSG_RESULT(ok)
    fi
  else
    perl_found="no"
  fi

  if test "x$perl_found" != "xno"; then
     LDFLAGS_SAVE="$LDFLAGS"
     LDFLAGS="$LDFLAGS `$PERL -MExtUtils::Embed -e ldopts`"
     AC_CHECK_LIB(perl, perl_construct, [true], perl_found="no")
     LDFLAGS="$LDFLAGS_SAVE"
  fi])

dnl ***************************************************************************
dnl python checks
dnl ***************************************************************************
if test "x$with_python" != "xno" ; then
  if test "x$with_python" = "xauto"  -o "x$with_python" = "xforce" ; then
    python_versions="python python3 python-3.4 python-3.3 python-3.2 python-3.0 python2 python-2.7 python-2.6"
    python_version=""
    for version in $python_versions; do
        PKG_CHECK_EXISTS($version, python_version=$version, python_version="")
        if test "x$python_version" != "x" ; then
           break
        fi
    done
    if test "x$with_python" = "xforce" -a  "x$python_version" = "x" ; then
       AC_MSG_ERROR([Python is forced to be required, but no suitable python version found!])
    fi
  else
    python_version=$with_python
  fi
  PKG_CHECK_MODULES(PYTHON, $python_version >= 2.6, enable_python="yes", [if test "x$with_python" != "xauto"  -a "x$with_python" != "xforce";then
       AC_MSG_ERROR([Python is forced to be required with version $python_version, but this version is not found!])
     else
       enable_python="no"
     fi])
fi

dnl ***************************************************************************
dnl librdkafka headers/libraries
dnl ***************************************************************************
if test "x$enable_kafka" != "xno" && test "x$with_kafka" != "xno"; then
       rdkafka="yes"
       if test "x$with_librdkafka" != "xno"; then
               CFLAGS_SAVE="$CFLAGS"
               LDFLAGS_SAVE="$LDFLAGS"
               CFLAGS="$CFLAGS -I$with_librdkafka/include"
               LDFLAGS="$LDFLAGS -L$with_librdkafka/lib"
               AC_CHECK_HEADER(librdkafka/rdkafka.h, [RDKAFKA_CFLAGS="-I$with_librdkafka/include"
                                                      RDKAFKA_LIBS="-L$with_librdkafka/lib -lrdkafka"], [rdkafka=no])
               CFLAGS="$CFLAGS_SAVE"
               LDFLAGS="$LDFLAGS_SAVE"
       else
               rdkafka="no"	
       fi

       if test "x$enable_kafka" = "xyes" && test "x$rdkafka" = "xno"; then
               AC_MSG_ERROR(librdkafka not found)
       fi

       AC_CHECK_LIB(rdkafka, rd_kafka_conf_set_log_cb, [with_librdkafka_log_cb="yes"], [with_librdkafka_log_cb="no"])
       AC_CHECK_LIB(rdkafka, rd_kafka_set_logger, [with_librdkafka_logger="yes"], [with_librdkafka_logger="no"])
       if test "x$with_librdkafka_log_cb" = "xyes"; then
         AC_DEFINE(HAVE_LIBRDKAFKA_LOG_CB, 1, [Define if librdkafka log_cb facility is present and usable.])
       fi
       if test "x$with_librdkafka_logger" = "xyes"; then
         AC_DEFINE(HAVE_LIBRDKAFKA_LOGGER, 1, [Define if librdkafka logger facility is present and usable.])
       fi

       enable_kafka=$rdkafka
fi

dnl ***************************************************************************
dnl misc features to be enabled
dnl ***************************************************************************

AC_SUBST(syslog_ng_tools)
AC_SUBST(moduledir)

AC_SUBST(RDKAFKA_CFLAGS)
AC_SUBST(RDKAFKA_LIBS)

AC_DEFINE_UNQUOTED(ENABLE_DEBUG, `enable_value $enable_debug`, [Enable debugging])

AM_CONDITIONAL(ENABLE_LOGMONGOURCE, [test "$enable_logmongource" != "no"])
AM_CONDITIONAL(ENABLE_RIEMANN, [test "$enable_riemann" != "no"])
AM_CONDITIONAL(ENABLE_LUA, [test "$enable_lua" != "no"])
AM_CONDITIONAL(ENABLE_PERL, [test "$enable_perl" != "no"])
AM_CONDITIONAL(ENABLE_PYTHON, [test "$enable_python" != "no"])
AM_CONDITIONAL(ENABLE_KAFKA, [test "x$enable_kafka" = "xyes"])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

echo
echo "syslog-ng Incubator $VERSION configured"
echo "syslog-ng Incubator $VERSION configured" | sed -e "s/./-/g"
echo " Debugging:            ${enable_debug:=no}"
echo " Modules:"
echo "  basicfuncs-plus      yes"
echo "  graphite             yes"
echo "  kafka                ${enable_kafka:=no}"
echo "  logmongource:        ${enable_logmongource:-yes}"
echo "  lua:                 ${enable_lua:-yes} ${lua_mod:+($lua_mod)}"
echo "  monitor-source:      ${enable_lua:-yes} ${lua_mod:+($lua_mod)}"
echo "  perl:                ${enable_perl:-yes}"
echo "  python:              ${enable_python:-yes} (${python_version})"
echo "  riemann:             ${enable_riemann:-yes}"
echo "  rss                  yes"
echo "  trigger-source       yes"
echo "  tfgetent             yes"
echo
