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



#ifndef _JRASTRO_TRACES_H_
#define _JRASTRO_TRACES_H_

/*Defines*/
//#define METHOD_EXIT 66
#define METHOD_LOAD 555
#define CLASS_LOAD 554
#define INITIALIZE 999
#define FINALIZE 998
#define METHOD_ENTRY 997
#define METHOD_EXIT_EXCEPTION 996
#define MONITOR_ENTER 995
#define MONITOR_ENTERED 994
#define METHOD_EXCEPTION 993
#define EVENT_METHOD_ENTRY_ALLOC 992
#define MONITOR_WAIT 991
#define MONITOR_WAITED 990



void trace_initialize(jvmtiEnv *jvmtiLocate, jthread thread, char *name);
void trace_finalize(jvmtiEnv *jvmtiLocate, jthread thread);
//void trace_event_object_alloc(jvmtiEnv *jvmtiLocate, jthread thread, jobject object);
void trace_event_object_alloc(jthread thread, jobject object, char *nameClass);
void trace_event_object_alloc_new_array(jthread thread, jobject object, char *nameClass);
void trace_event_object_free(jlong tag);
void trace_event_gc_start();
void trace_event_gc_finish();
void trace_event_method_entry_obj_init(jthread thread, jobject object, int method, char *nameClass);
void trace_event_method_entry_obj(jthread thread, int object, int method);
void trace_event_method_entry(jthread thread, int method);
void trace_event_method_exit(jthread thread);
void trace_event_exception(jthread thread, int exception);
void trace_event_method_exit_exception(jthread thread);
void trace_event_method_load(int method, char *name, unsigned access_flags, int klass);
void trace_event_class_load(int klass, char *name);

void trace_event_monitor_contended_enter(jvmtiEnv *jvmtiLocate, jthread thread, int object);
void trace_event_monitor_contended_entered(jvmtiEnv *jvmtiLocate, jthread thread, int object);

void trace_event_monitor_wait(jvmtiEnv *jvmtiLocate, jthread thread, int object);
void trace_event_monitor_waited(jvmtiEnv *jvmtiLocate, jthread thread, int object);


#endif		/*_JRASTRO_TRACES_H_*/

