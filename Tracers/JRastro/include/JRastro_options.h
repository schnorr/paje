/*
    Copyright (c) 1998--2006 Benhur Stein
    
    This file is part of Pajé.

    Pajé is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Pajé is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Pajé; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/


//////////////////////////////////////////////////
/*      Author: Geovani Ricardo Wiedenhoft      */
/*      Email: grw@inf.ufsm.br                  */
//////////////////////////////////////////////////



#ifndef _JRASTRO_OPTIONS_H_
#define _JRASTRO_OPTIONS_H_

#define MAX_NAME_OPTIONS 50
#define MAX_LINE_EVENTS 80
#define MAX_LINE 120

extern char eventsOptionName[MAX_NAME_OPTIONS];
extern char methodsOptionName[MAX_NAME_OPTIONS];

//extern bool teste;

void jrst_enable_all(jvmtiEnv *jvmtiLocate);
void jrst_threads(jvmtiEnv *jvmtiLocate);
void jrst_read_events_enable(jvmtiEnv *jvmtiLocate);
void jrst_read_class_methods_enable();
void jrst_read_names_options(char *options);

#endif		/*_JRASTRO_OPTIONS_H_*/
