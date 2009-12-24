AC_PREREQ([2.59])
AC_INIT([libRastro], [0.1], [benhur@inf.ufsm.br])
AM_INIT_AUTOMAKE
AC_PROG_LIBTOOL
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([src/config.h])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_PROG_INSTALL

# Checks for libraries.
AC_CHECK_LIB([pthread], [pthread_key_create])

# Checks for header files.
AC_CHECK_HEADERS([arpa/inet.h fcntl.h inttypes.h netdb.h netinet/in.h stdlib.h string.h sys/file.h sys/param.h sys/socket.h sys/time.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_INLINE
AC_TYPE_SIZE_T

# Checks for library functions.
AC_FUNC_FORK
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_CHECK_FUNCS([bzero gethostbyname gethostname gettimeofday memmove socket strchr strdup strerror strspn])

AC_CONFIG_FILES([Makefile src/Makefile scripts/Makefile examples/Makefile])
AC_OUTPUT
