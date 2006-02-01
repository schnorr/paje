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



#ifndef _JRASTRO_BASIC_H_
#define _JRASTRO_BASIC_H_

#define THREAD_LOADER 1234
#define THREAD_MONITOR 4321
#define THREAD_NEW_ARRAY 5678

#define MAX_NAME_THREAD 70

//#define OBJECT_ID(object) (*(int *)object)
#define GET_JVMTI() (gagent->jvmti)

typedef struct {
	jvmtiEnv *jvmti;
	jrawMonitorID monitor;
	jrawMonitorID monitor_thread;
	jrawMonitorID monitor_buffer;
	jrawMonitorID monitor_new_array;
	jrawMonitorID monitor_tag;
}globalAgent;

extern globalAgent *gagent;
extern jvmtiCapabilities capabilities;
extern jvmtiEventCallbacks callbacks;

extern hash_t h_options;
//extern hash_t h;

extern bool traces;
extern bool tracesAll;
extern bool methodsTrace;
extern bool memoryTrace;

extern bool initialized;

extern rst_buffer_t *ptr_loader;
extern rst_buffer_t *ptr_monitor;
extern rst_buffer_t *ptr_new_array;


void jrst_describe_error(jvmtiEnv *jvmtiEnv, jvmtiError error);
void jrst_check_error(jvmtiEnv *jvmtiEnv, jvmtiError error, const char *frase);
void jrst_enter_critical_section(jvmtiEnv *jvmtiEnv, jrawMonitorID monitor);
void jrst_exit_critical_section(jvmtiEnv *jvmtiEnv, jrawMonitorID monitor);
void jrst_get_thread_name(jvmtiEnv *jvmtiLocate, jthread thread, char *name, int numMax);
bool jrst_trace_class(char *className);
bool jrst_trace_methods();
//bool jrst_trace(void *key);


#endif		/*_JRASTRO_BASIC_H_*/
