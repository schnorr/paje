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



#include "org_lsc_JRastro_Instru.h"

#include"JRastro.h"

int i=0;

void func_init(jobject obj, jobject th)
{
	i++;	
}

void func_newArray(jobject obj, jobject th)
{
	i++;
}

void func(jobject obj, jobject thread, int mnum)
{
	i++;
}

void func_entry(jobject thread, int mnum)
{
	i++;
}

void func_exit(jobject thread)
{
	i++;
}

JNIEXPORT void JNICALL Java_org_lsc_JRastro_Instru_func_1init (JNIEnv *env, jclass klass, jobject obj, jobject thread)
{

	jclass klassObject;
	jvmtiError error;
	char *signature_ptr;
	char *generic_ptr;
	char *tmp;
	int size = 0;

	klassObject = (*env)->GetObjectClass(env, obj);

	error = (*GET_JVMTI())->GetClassSignature(GET_JVMTI(), klassObject, &signature_ptr, &generic_ptr);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Class Signature");

	/*Tirar da signature o caracter 'L'*/
	tmp = (char *)signature_ptr + 1;
	/* -1 Pois comeca em 0 o vetor*/
	size = strlen(tmp) - 1;
	/*Tira da signature o caracter ';'*/
	tmp[size] = '\0';

//	printf("signature=[%s]\n", tmp);
	
	trace_event_object_alloc((jthread) thread, obj, tmp);
	 
	error=(*GET_JVMTI())->Deallocate(GET_JVMTI(), (unsigned char*)signature_ptr);
	jrst_check_error(GET_JVMTI(), error, "Cannot deallocate memory");

			
}

JNIEXPORT void JNICALL Java_org_lsc_JRastro_Instru_func_1newArray (JNIEnv *env, jclass klass, jobject obj, jobject thread)
{
	jclass klassObject;
	jvmtiError error;
	char *signature_ptr;
	char *generic_ptr;
	char *tmp;
	int size = 0;

	klassObject = (*env)->GetObjectClass(env, obj);

	error = (*GET_JVMTI())->GetClassSignature(GET_JVMTI(), klassObject, &signature_ptr, &generic_ptr);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Class Signature");

	/*Tirar da signature o caracter 'L'*/
	tmp = (char *)signature_ptr + 1;
	/* -1 Pois comeca em 0 o vetor*/
	size = strlen(tmp) - 1;
	/*Tira da signature o caracter ';'*/
	tmp[size] = '\0';

	//printf("signature=[%s]\n", tmp);
	
//	trace_event_object_alloc((jthread) thread, obj, tmp);

	trace_event_object_alloc_new_array((jthread) thread, obj, tmp);
	
	error=(*GET_JVMTI())->Deallocate(GET_JVMTI(), (unsigned char*)signature_ptr);
	jrst_check_error(GET_JVMTI(), error, "Cannot deallocate memory");

}

JNIEXPORT void JNICALL Java_org_lsc_JRastro_Instru_func (JNIEnv *env, jclass klass, jobject obj, jobject thread, jint mnum)
{
	
	if(obj != NULL){
		jvmtiError error;
		jlong id = 0;

		error = (*GET_JVMTI())->GetTag( GET_JVMTI(), obj, &id);

		if(error != JVMTI_ERROR_NONE){
				return;
		}
		//jrst_check_error(GET_JVMTI(), error, "Cannot Get Tag");

		if(id == 0){
			jclass klassObject;
			char *signature_ptr;
			char *generic_ptr;
			char *tmp;
			int s = 0;

			klassObject = (*env)->GetObjectClass(env, obj);

			error = (*GET_JVMTI())->GetClassSignature(GET_JVMTI(), klassObject, &signature_ptr, &generic_ptr);
			jrst_check_error(GET_JVMTI(), error, "Cannot Get Class Signature");
			/*Tirar da signature o caracter 'L'*/
			tmp = (char *)signature_ptr + 1;
			/* -1 Pois comeca em 0 o vetor*/
			s = strlen(tmp) - 1;
			/*Tira da signature o caracter ';'*/
			tmp[s] = '\0';

			//printf("className=[%s]\n", tmp );
						
			trace_event_method_entry_obj_init((jthread) thread, obj, mnum, tmp);


			error=(*GET_JVMTI())->Deallocate(GET_JVMTI(), (unsigned char*)signature_ptr);
			jrst_check_error(GET_JVMTI(), error, "Cannot deallocate memory");
				
				
		}else{
			trace_event_method_entry_obj((jthread) thread, (int)id, mnum);
		}
		return;
	}	
	trace_event_method_entry((jthread) thread, mnum);
	
	//func(obj, thread, mnum);
}

JNIEXPORT void JNICALL Java_org_lsc_JRastro_Instru_func_1entry (JNIEnv *env, jclass klass, jobject thread, jint mnum)
{
	trace_event_method_entry((jthread) thread, mnum);
}

JNIEXPORT void JNICALL Java_org_lsc_JRastro_Instru_func_1exit (JNIEnv *env, jclass klass, jobject thread)
{
//	jrst_enter_critical_section(jvmti);
	trace_event_method_exit((jthread) thread);
//	jrst_exit_critical_section(jvmti);
	//func_exit(thread, mnum);
}

