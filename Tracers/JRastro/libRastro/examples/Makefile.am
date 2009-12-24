INCLUDES=-I$(top_srcdir)/src/
AM_FLAGS=-g

noinst_PROGRAMS=read write

read_SOURCES=rastro_read_example.c
read_LDADD=$(top_builddir)/src/librastro.la

write_SOURCES=rastro_write_example.c saida.c
write_LDADD=$(top_builddir)/src/librastro.la
