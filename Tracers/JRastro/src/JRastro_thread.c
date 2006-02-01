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



#include "JRastro.h"


/*Inicio de Thread*/
void JNICALL jrst_event_thread_start(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread)
{
	
	char name[MAX_NAME_THREAD];

	jrst_get_thread_name(jvmtiLocate, thread, name, MAX_NAME_THREAD);

	if(strcmp("main", name) ){
		trace_initialize(jvmtiLocate, thread, name);
	}
	
}

/*Fim de Thread*/
void JNICALL jrst_event_thread_end(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread)
{ 

	trace_finalize(jvmtiLocate, thread);
	
}
