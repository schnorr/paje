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
#################################################################
#################################################################
#//////////////////////////////////////////////////
#/*      Author: Geovani Ricardo Wiedenhoft      */
#/*      Email: grw@inf.ufsm.br                  */
#//////////////////////////////////////////////////
#################################################################
#################################################################
#Alterar essa variavel, indicar qual o caminho da home do Java
JDK_HOME=/usr/local/java/jdk1.5.0

#Diretorio da biblioteca JRastro
export JRASTRO_DIR=/usr/local/JRastro

#Diretorio dos binarios
export JRASTRO_DIR_BIN=$(JRASTRO_DIR)/bin

#################################################################
#Diretorio que ficara a biblioteca
export JRASTRO_DIR_LIB=$(JRASTRO_DIR)/lib

#Diretorio que ficara os codigos fontes
export JRASTRO_DIR_SRC=$(JRASTRO_DIR)/src

#Diretorio que ficara os objetos
export JRASTRO_DIR_OBJ=$(JRASTRO_DIR)/objects

#Diretorio que ficara os include
export JRASTRO_DIR_INCLUDE=$(JRASTRO_DIR)/include

#Diretorio que ficara os manuais
export JRASTRO_DIR_HELP=$(JRASTRO_DIR)/help
#################################################################
RASTRO_LIB=-L./libRastro/lib/ -lrastro
RASTRO_INCLUDE=-I./libRastro/include/
INCLUDE=-I./include/ -I$(JDK_HOME)/include/ -I$(JDK_HOME)/include/linux $(RASTRO_INCLUDE)
CC=gcc
CFLAGS=-g -Wall -fPIC
PERMDIR=0755
#################################################################

hist: librastro.a ./org/lsc/JRastro/Instru.class ./lib/libJRastro.so ./bin/JRastro_read ./bin/JRastro_readObj ./bin/JRastro_readObjClass


./bin/JRastro_read: ./include/JRastro.h ./libRastro/lib/librastro.a ./src/JRastro_read.c ./src/JRastro_paje.c ./include/JRastro_paje.h ./objects/hash.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o
	$(CC) $(CFLAGS) -o ./bin/JRastro_read ./src/JRastro_read.c ./src/JRastro_paje.c ./objects/hash.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o $(INCLUDE) $(RASTRO_LIB)

./bin/JRastro_readObj: ./include/JRastro.h ./libRastro/lib/librastro.a ./src/JRastro_read_objects.c ./src/JRastro_paje.c ./include/JRastro_paje.h ./objects/hash.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o
	$(CC) $(CFLAGS) -o ./bin/JRastro_readObj ./src/JRastro_read_objects.c ./src/JRastro_paje.c ./objects/hash.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o $(INCLUDE) $(RASTRO_LIB)

./bin/JRastro_readObjClass: ./include/JRastro.h ./libRastro/lib/librastro.a ./src/JRastro_read_objects_class.c ./src/JRastro_paje.c ./include/JRastro_paje.h ./objects/hash.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o
	$(CC) $(CFLAGS) -o ./bin/JRastro_readObjClass ./src/JRastro_read_objects_class.c ./src/JRastro_paje.c ./objects/hash.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o $(INCLUDE) $(RASTRO_LIB)

./lib/libJRastro.so: ./libRastro/lib/librastro.a ./objects/JRastro_rastros.o ./objects/JRastro_traces.o ./objects/JRastro_basic.o ./objects/hash.o ./objects/JRastro_options.o ./objects/JRastro_events.o ./objects/JRastro_thread.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o ./objects/JRastro.o ./objects/JRastro_java_crw_demo.o ./objects/JRastro_func.o
	ld -shared -o ./lib/libJRastro.so ./objects/JRastro_rastros.o ./objects/JRastro_traces.o ./objects/hash.o ./objects/JRastro_basic.o ./objects/JRastro_options.o ./objects/JRastro_events.o ./objects/JRastro_thread.o ./objects/JRastro_hash_func.o ./objects/JRastro_list_func.o ./objects/JRastro.o ./libRastro/lib/librastro.a ./objects/JRastro_java_crw_demo.o ./objects/JRastro_func.o

./org/lsc/JRastro/Instru.class: ./org/lsc/JRastro/Instru.java
	javac org/lsc/JRastro/Instru.java

librastro.a:
	(cd ./libRastro/ && make)


./objects/JRastro.o: ./include/JRastro.h ./src/JRastro.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro.o ./src/JRastro.c $(INCLUDE)
./objects/JRastro_hash_func.o: ./include/JRastro_hash_func.h ./src/JRastro_hash_func.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_hash_func.o ./src/JRastro_hash_func.c $(INCLUDE)
./objects/JRastro_list_func.o: ./include/JRastro_list_func.h ./src/JRastro_list_func.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_list_func.o ./src/JRastro_list_func.c $(INCLUDE)
./objects/JRastro_java_crw_demo.o: ./include/JRastro.h ./include/JRastro_classfile_constants.h ./include/JRastro_java_crw_demo.h ./src/JRastro_java_crw_demo.c
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_java_crw_demo.o ./src/JRastro_java_crw_demo.c $(INCLUDE)
./objects/JRastro_thread.o: ./include/JRastro.h ./include/JRastro_thread.h ./src/JRastro_thread.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_thread.o ./src/JRastro_thread.c $(INCLUDE)
./objects/JRastro_events.o: ./include/JRastro.h ./include/JRastro_events.h ./src/JRastro_events.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_events.o ./src/JRastro_events.c $(INCLUDE)
./objects/JRastro_options.o: ./include/JRastro.h ./include/JRastro_options.h ./src/JRastro_options.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_options.o ./src/JRastro_options.c $(INCLUDE)
./objects/hash.o: ./include/hash.h ./src/hash.c 
	$(CC) $(CFLAGS) -c -o ./objects/hash.o ./src/hash.c $(INCLUDE)
./objects/JRastro_basic.o: ./include/JRastro.h ./include/JRastro_basic.h ./src/JRastro_basic.c
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_basic.o ./src/JRastro_basic.c $(INCLUDE)
./objects/JRastro_traces.o: ./include/JRastro.h ./include/JRastro_traces.h ./src/JRastro_traces.c ./libRastro/lib/librastro.a ./objects/JRastro_rastros.o ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_traces.o ./src/JRastro_traces.c $(INCLUDE)
./objects/JRastro_rastros.o: ./libRastro/lib/librastro.a ./include/JRastro_rastros.h ./src/JRastro_rastros.c
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_rastros.o ./src/JRastro_rastros.c $(INCLUDE)
./objects/JRastro_func.o: ./include/JRastro.h ./include/org_lsc_JRastro_Instru.h ./src/JRastro_func.c ./objects/JRastro_basic.o
	$(CC) $(CFLAGS) -c -o ./objects/JRastro_func.o ./src/JRastro_func.c $(INCLUDE)

clean:
	(cd ./libRastro/ && make clean)
	rm -f ./objects/JRastro*.o ./objects/hash.o ./lib/libJRastro.so ./bin/JRastro_read ./bin/JRastro_readObj ./bin/JRastro_readObjClass ./org/lsc/JRastro/Instru.class

install:
	cp -f lib/libJRastro.so $(JDK_HOME)/jre/lib/i386/
	cp -rf org/ $(JDK_HOME)/jre/lib/
	(cd $(JDK_HOME)/jre/lib && cp -f rt.jar rt.jar.BACK && jar -uf rt.jar org/lsc/JRastro/Instru.class)
	install -m $(PERMDIR) -d $(JRASTRO_DIR)
	install -m $(PERMDIR) -d $(JRASTRO_DIR_LIB)
	install -m $(PERMDIR) -d $(JRASTRO_DIR_BIN) 
	install -m $(PERMDIR) -d $(JRASTRO_DIR_SRC) 
	install -m $(PERMDIR) -d $(JRASTRO_DIR_OBJ) 
	install -m $(PERMDIR) -d $(JRASTRO_DIR_INCLUDE)
	install -m $(PERMDIR) -d $(JRASTRO_DIR_HELP)
	install -m 0744 Makefile $(JRASTRO_DIR)/Makefile
	install -m 0444 README $(JRASTRO_DIR)/README
	install -m 0644 ./lib/libJRastro.so $(JRASTRO_DIR_LIB)
	install -m 0755 ./bin/JRastro* $(JRASTRO_DIR_BIN)
	install -m 0644 ./src/JRastro* $(JRASTRO_DIR_SRC)
	install -m 0644 ./src/hash.c $(JRASTRO_DIR_SRC)
	install -m 0755 ./objects/JRastro* $(JRASTRO_DIR_OBJ)
	install -m 0755 ./objects/hash.o $(JRASTRO_DIR_OBJ)
	install -m 0644 ./include/JRastro* $(JRASTRO_DIR_INCLUDE)
	install -m 0644 ./include/hash.h $(JRASTRO_DIR_INCLUDE)
	install -m 0644 ./include/org_lsc_JRastro_Instru.h $(JRASTRO_DIR_INCLUDE)
	install -m 0644 ./help/JRastro* $(JRASTRO_DIR_HELP)
	cp -rf org/ $(JRASTRO_DIR)/
	(cd libRastro && make install)
	
uninstall:
	rm -f $(JDK_HOME)/jre/lib/i386/libJRastro.so
	rm -f $(JRASTRO_DIR)/Makefile $(JRASTRO_DIR)/README $(JRASTRO_DIR_LIB)/libJRastro.so $(JRASTRO_DIR_BIN)/JRastro* $(JRASTRO_DIR_BIN)/rastro_* $(JRASTRO_DIR_SRC)/JRastro* $(JRASTRO_DIR_SRC)/hash.c $(JRASTRO_DIR_OBJ)/JRastro* $(JRASTRO_DIR_OBJ)/hash.o $(JRASTRO_DIR_INCLUDE)/JRastro* $(JRASTRO_DIR_INCLUDE)/hash.h $(JRASTRO_DIR_INCLUDE)/org_lsc_JRastro_Instru.h $(JRASTRO_DIR_HELP)/JRastro*
	rm -rf $(JRASTRO_DIR)/org/
	(cd $(JDK_HOME)/jre/lib && mv -f rt.jar.BACK rt.jar)
	(cd libRastro && make uninstall)
	
