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


CC=gcc
CFLAGS=-Wall -g -lpthread
#CFLAGS=-Wall -g -DTHREADED -lpthread
RASTRO_INCLUDE=-I. -I./../include/
RASTRO_LIB=-L./../lib/ -lrastro
RASTRO_FLAGS=$(RASTRO_INCLUDE) $(RASTRO_LIB)
COMPILE=$(CC) $(CFLAGS) -c
PREPROCESS=gcc -E
AR=ar -rc


hist: ./../lib/librastro.a write read
	
read: ./../lib/librastro.a rastro_read_example.c
	$(CC) $(CFLAGS) -o read rastro_read_example.c $(RASTRO_FLAGS)



write: ./../lib/librastro.a rastro_write_example.c saida.c saida.h
	$(CC) $(CFLAGS) -o write rastro_write_example.c saida.c $(RASTRO_FLAGS)

clean:
	rm -f *.o write read 

