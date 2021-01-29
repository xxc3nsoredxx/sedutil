#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([sedutil-xxc], [1.15.1], [https://github.com/xxc3nsoredxx/sedutil/issues])
AC_CONFIG_SRCDIR([Common/sedutil.cpp])
AC_CONFIG_HEADERS([config.h])

# Configure args
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug=[LEVEL]],
                    [debug level: ERROR, WARN, INFO, DEBUG, DEBUG1, DEBUG2, DEBUG3, DEBUG4 (default is INFO)])],
    [debug_level=$enableval],
    [debug_level="INFO"])
AS_IF([test "x$debug_level" = "xERROR"],  [AC_DEFINE([DEBUG_LEVEL_INT], [0], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xWARN"],   [AC_DEFINE([DEBUG_LEVEL_INT], [1], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xINFO"],   [AC_DEFINE([DEBUG_LEVEL_INT], [2], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xDEBUG"],  [AC_DEFINE([DEBUG_LEVEL_INT], [3], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xDEBUG1"], [AC_DEFINE([DEBUG_LEVEL_INT], [4], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xDEBUG2"], [AC_DEFINE([DEBUG_LEVEL_INT], [5], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xDEBUG3"], [AC_DEFINE([DEBUG_LEVEL_INT], [6], [Debug level: 0-7 (default 2)])],
      [test "x$debug_level" = "xDEBUG4"], [AC_DEFINE([DEBUG_LEVEL_INT], [7], [Debug level: 0-7 (default 2)])],
                                          [AC_DEFINE([DEBUG_LEVEL_INT], [2], [Debug level: 0-7 (default 2)])])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([arpa/inet.h fcntl.h malloc.h stdint.h stdlib.h string.h sys/ioctl.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_CHECK_HEADER_STDBOOL
AC_TYPE_INT32_T
AC_TYPE_SIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT8_T

# Checks for library functions.
AC_CHECK_FUNCS([memset])

# use automake
AM_INIT_AUTOMAKE([dist-xz no-dist-gzip -Wall])
AC_CONFIG_FILES([Makefile])

# Output info
AS_CASE(["x$debug_level"],
        ['xERROR'|'xWARN'|'xINFO'|'xDEBUG'|'xDEBUG1'|'xDEBUG2'|'xDEBUG3'|'xDEBUG4'], [AS_ECHO(["using debug level: $debug_level"])],
        [AC_MSG_WARN([invalid debug level given: $debug_level])
         AS_ECHO(['using debug level: INFO'])])

AC_OUTPUT
