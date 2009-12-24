AM_CPPFLAGS = $(all_includes)

#LIBRARY_VERSION= 0:0:0
#                 | | |
#          +------+ | +---+
#          |        |     |
#       current:revision:age
#          |        |     |
#          |        |     +- Increment if interfaces have been added
#          |        |        Set to zero if interfaces have been removed or
#          |        |        changed
#          |        +- Increment if source code has changed
#          |           Set to zero if current is incremented
#          +- Increment if interfaces have been added, removed or changed
LIBRARY_VERSION= 0:0:0
RASTRO_TIMESYNC_SRC = rastro_timesync.c rastro_timesync_f.c
RASTRO_GENERATE_SRC = rastro_generate.c
LIB_RASTRO_SRC = list.c rastro_read.c rastro_write.c rastro_write_functions.c

include_HEADERS = rastro_public.h rastro_private.h
lib_LTLIBRARIES=librastro.la
bin_PROGRAMS=rastro_timesync rastro_generate

librastro_la_SOURCES = $(LIB_RASTRO_SRC)
librastro_la_LDFLAGS = -no-undefined -version-info $(LIBRARY_VERSION)

rastro_timesync_SOURCES = $(RASTRO_TIMESYNC_SRC)
rastro_timesync_LDADD = librastro.la

rastro_generate_SOURCES = $(RASTRO_GENERATE_SRC)
rastro_generate_LDADD = librastro.la


# what flags you want to pass to the C compiler & linker
#CFLAGS = --pedantic -Wall -std=c99 -O2
#LDFLAGS =
#
## this lists the binaries to produce, the (non-PHONY, binary) targets in
## the previous manual Makefile
#bin_PROGRAMS = targetbinary1 targetbinary2 [...] targetbinaryN
#targetbinary1_SOURCES = targetbinary1.c myheader.h [...]
#targetbinary2_SOURCES = targetbinary2.c
#targetbinaryN_SOURCES = targetbinaryN.c
#
