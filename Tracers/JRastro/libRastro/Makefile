#/*
#    Copyright (c) 1998--2006 Benhur Stein
#    
#    This file is part of Pajé.
#
#    Pajé is free software; you can redistribute it and/or modify it under
#    the terms of the GNU Lesser General Public License as published by the
#    Free Software Foundation; either version 2 of the License, or (at your
#    option) any later version.
#
#    Pajé is distributed in the hope that it will be useful, but WITHOUT ANY
#    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
#    for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with Pajé; if not, write to the Free Software Foundation, Inc.,
#	51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
#*/
#
#
#//////////////////////////////////////////////////
#/*      Author: Geovani Ricardo Wiedenhoft      */
#/*      Email: grw@inf.ufsm.br                  */
#//////////////////////////////////////////////////


#make install -> instala a biblioteca no Diretorio RASTRO_DIR=""
#make uninstall -> desinstala a biblioteca do Diretorio RASTRO_DIR=""
#make clean -> limpa todo o diretorio.


#Diretorio que ficara a biblioteca inteira
RASTRO_DIR=$(JRASTRO_DIR)/libRastro

#Diretorio que ficara a biblioteca .a
RASTRO_DIR_LIB=$(RASTRO_DIR)/lib

#Voce deve setar o PATH desse diretorio (binarios)
RASTRO_DIR_BIN=$(RASTRO_DIR)/bin

#Diretorio que ficara os codigos fontes
RASTRO_DIR_SRC=$(RASTRO_DIR)/src

#Diretorio que ficara os objetos
RASTRO_DIR_OBJ=$(RASTRO_DIR)/objects

#Diretorio que ficara os include
RASTRO_DIR_INCLUDE=$(RASTRO_DIR)/include

#Diretorio que ficara os exemplos
RASTRO_DIR_EXAMPLES=$(RASTRO_DIR)/examples

PERMDIR=0755
CC=gcc
CFLAGS=-Wall -g
#CFLAGS=-Wall -g -DTHREADED
LDFLAGS=-lpthread
RASTRO_INCLUDE=-I./include/
RASTRO_LIB=-L./lib/ -lrastro
RASTRO_FLAGS=$(RASTRO_INCLUDE) $(RASTRO_LIB)
COMPILE=$(CC) $(CFLAGS) -c
PREPROCESS=gcc -E
AR=ar -rc

.SUFFIXES: .o .c
.c.o:
	$(COMPILE) $< $(RASTRO_INCLUDE)

hist: ./lib/librastro.a ./bin/rastro_generate ./bin/rastro_timesync
	
./bin/rastro_timesync: ./src/rastro_timesync.c ./lib/librastro.a ./include/rastro_timesync_f.h
	$(CC) $(CFLAGS) -o ./bin/rastro_timesync ./src/rastro_timesync.c ./src/rastro_timesync_f.c $(RASTRO_FLAGS)

./include/rastro_timesync_f.h: ./bin/rastro_generate ./src/rastro_timesync.c
	./bin/rastro_get_names.sh ./src/rastro_timesync.c rastro_timesync_f
	mv -f rastro_timesync_f.h ./include/
	mv -f rastro_timesync_f.c ./src/

./lib/librastro.a: ./objects/rastro_read.o ./objects/rastro_write.o ./objects/rastro_write_functions.o ./objects/list.o
	$(AR) ./lib/librastro.a ./objects/rastro_read.o ./objects/rastro_write.o ./objects/rastro_write_functions.o ./objects/list.o

./objects/rastro_write_functions.o:
	$(CC) $(CFLAGS) -c -o ./objects/rastro_write_functions.o ./src/rastro_write_functions.c $(RASTRO_INCLUDE)

./objects/rastro_write.o: ./src/rastro_write.c ./include/rastro_write_functions.h ./include/rastro_private.h ./objects/list.o
	$(CC) $(CFLAGS) -c -o ./objects/rastro_write.o ./src/rastro_write.c $(RASTRO_INCLUDE)

./include/rastro_write_functions.h: ./bin/rastro_generate
	./bin/rastro_get_names.sh ./src/rastro_write.c rastro_write_functions
	mv -f rastro_write_functions.h ./include/
	mv -f rastro_write_functions.c ./src/

./objects/list.o: ./src/list.c ./include/list.h
	$(CC) $(CFLAGS) -c -o ./objects/list.o ./src/list.c $(RASTRO_INCLUDE)

./objects/rastro_read.o: ./src/rastro_read.c ./include/rastro_public.h ./include/rastro_private.h
	$(CC) $(CFLAGS) -c -o ./objects/rastro_read.o ./src/rastro_read.c $(RASTRO_INCLUDE)

./bin/rastro_generate: ./src/rastro_generate.c ./include/rastro_public.h ./include/rastro_private.h
	$(CC) $(CFLAGS) -o ./bin/rastro_generate ./src/rastro_generate.c $(RASTRO_INCLUDE)

install:
	install -m $(PERMDIR) -d $(RASTRO_DIR)
	install -m $(PERMDIR) -d $(RASTRO_DIR_LIB)
	install -m $(PERMDIR) -d $(RASTRO_DIR_BIN)
	install -m $(PERMDIR) -d $(RASTRO_DIR_SRC)
	install -m $(PERMDIR) -d $(RASTRO_DIR_OBJ)
	install -m $(PERMDIR) -d $(RASTRO_DIR_INCLUDE)
	install -m $(PERMDIR) -d $(RASTRO_DIR_EXAMPLES)
	install -m 0744 Makefile $(RASTRO_DIR)/Makefile
	install -m 0444 INSTALL $(RASTRO_DIR)/INSTALL
	install -m 0444 README $(RASTRO_DIR)/README
	install -m 0644 ./lib/librastro.a $(RASTRO_DIR_LIB)
	cp ./bin/rastro_get_names.sh ./bin/tmp.sh
	cp ./bin/rastro_function.sh ./bin/tmp2.sh
	cat ./bin/rastro_get_names.sh | sed 's/\(.*\)\-I\.\/include\/\(.*\)/\1\2/' > ./bin/.tmp.sh
	cat ./bin/.tmp.sh | sed 's/\(.*\)\.\/bin\/\(.*\)/\1\2/' > ./bin/.tmp2.sh
	rm -f ./bin/.tmp.sh
	mv -f ./bin/.tmp2.sh ./bin/rastro_get_names.sh
	cat ./bin/rastro_function.sh | sed 's/\(.*\)\.\/bin\/\(.*\)/\1\2/' > ./bin/.tmp.sh
	mv -f ./bin/.tmp.sh ./bin/rastro_function.sh
	install -m 0755 ./bin/rastro* $(RASTRO_DIR_BIN)
	install -m 0755 ./bin/rastro* $(JRASTRO_DIR_BIN)
	mv -f ./bin/tmp.sh ./bin/rastro_get_names.sh
	chmod 0755 ./bin/rastro_get_names.sh
	mv -f ./bin/tmp2.sh ./bin/rastro_function.sh
	chmod 0755 ./bin/rastro_function.sh
	install -m 0644 ./src/rastro* $(RASTRO_DIR_SRC)
	install -m 0644 ./src/list* $(RASTRO_DIR_SRC)
	install -m 0755 ./objects/rastro* $(RASTRO_DIR_OBJ)
	install -m 0755 ./objects/list* $(RASTRO_DIR_OBJ)
	install -m 0644 ./include/rastro* $(RASTRO_DIR_INCLUDE)
	install -m 0644 ./include/list* $(RASTRO_DIR_INCLUDE)
	install -m 0644 ./examples/rastro* $(RASTRO_DIR_EXAMPLES)
	install -m 0755 ./examples/Makefile $(RASTRO_DIR_EXAMPLES)

uninstall:
	rm -rf $(RASTRO_DIR_INCLUDE)/rastro* $(RASTRO_DIR_INCLUDE)/list* $(RASTRO_DIR_SRC)/rastro* $(RASTRO_DIR_SRC)/list* $(RASTRO_DIR_OBJ)/rastro* $(RASTRO_DIR_OBJ)/list* $(RASTRO_DIR_BIN)/rastro* $(RASTRO_DIR_LIB)/rastro* $(RASTRO_DIR_EXAMPLES)/rastro* $(RASTRO_DIR_EXAMPLES)/Makefile $(RASTRO_DIR)

clean:
	rm -f ./objects/*.o ./lib/librastro.a ./bin/rastro_generate ./bin/rastro_timesync

