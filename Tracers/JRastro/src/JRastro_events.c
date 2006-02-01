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


void JNICALL jrst_monitor_contended_enter(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object)
{
	
	jvmtiError error;
	jlong tag;
	
	error = (*GET_JVMTI())->GetTag( GET_JVMTI(), object, &tag);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Tag");
	
	trace_event_monitor_contended_enter(jvmtiLocate, thread, (int)tag);
	
}

void JNICALL jrst_monitor_contended_entered(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object)
{
	
	jvmtiError error;
	jlong tag;
	
	error = (*GET_JVMTI())->GetTag( GET_JVMTI(), object, &tag);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Tag");
	
	trace_event_monitor_contended_entered(jvmtiLocate, thread, (int)tag);
	
}

void JNICALL jrst_monitor_wait(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object, jlong timeout)
{
	
	jvmtiError error;
	jlong tag;
	
	error = (*GET_JVMTI())->GetTag( GET_JVMTI(), object, &tag);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Tag");
	
	trace_event_monitor_wait(jvmtiLocate, thread, (int)tag);
	
	
}

void JNICALL jrst_monitor_waited(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object, jboolean timed_out)
{
	
	jvmtiError error;
	jlong tag;
	
	error = (*GET_JVMTI())->GetTag( GET_JVMTI(), object, &tag);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Tag");
	
	trace_event_monitor_waited(jvmtiLocate, thread, (int)tag);
	
		
}

/*void JNICALL jrst_event_VMObject_alloc(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object, jclass object_klass, jlong size){}*/


void JNICALL jrst_event_object_free(jvmtiEnv *jvmtiLocate, jlong tag)
{

	trace_event_object_free(tag);

}

void JNICALL jrst_event_garbage_collection_start(jvmtiEnv *jvmtiLocate)
{

	trace_event_gc_start();

}

void JNICALL jrst_event_garbage_collection_finish(jvmtiEnv *jvmtiLocate)
{

	trace_event_gc_finish();

}


bool jrst_find_method_all_class(char *methodName)
{
	hash_data_t *data_list;
	list_t *allMethods;
	
	data_list = hash_locate(&h_options, (hash_key_t)"*");

	if(data_list != NULL){
		allMethods = *(list_t **)data_list;
		if(list_find(allMethods, (void *)methodName)){
			return true;
		}				
	}
	return false;
}

void jrst_deallocate_class(jvmtiEnv *jvmtiLocate, char *classSignature, char *classGeneric)
{
	jvmtiError error;

	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)classSignature);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)classGeneric);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
}

bool jrst_find_method(jvmtiEnv *jvmtiLocate, jmethodID method, char *methodName)
{
	jvmtiError error;
	jclass klass;
	char *className;
	char *classSignature;
	char *classGeneric;
	int size = 0;
	hash_data_t *data_list;
	list_t *methods;

	error = (*jvmtiLocate)->GetMethodDeclaringClass(jvmtiLocate, method, &klass);
	jrst_check_error(jvmtiLocate,error, "Cannot Get Method Declaring Class");

	error = (*jvmtiLocate)->GetClassSignature(jvmtiLocate, klass, &classSignature, &classGeneric);
	jrst_check_error(jvmtiLocate,error, "Cannot Get Class Signature");

	/*Tirar da signature o caracter 'L'*/
	className = (char *)classSignature + 1;
	/* -1 Pois comeca em 0 o vetor*/
	size = strlen(className) - 1;
	/*Tira da signature o caracter ';'*/
	className[size] = '\0';
	
	data_list = hash_locate(&h_options, (hash_key_t)className);

	if(data_list != NULL){
		methods = *(list_t **)data_list;
		if(list_find(methods, (void *)"*") || list_find(methods, (void *)methodName)){
			jrst_deallocate_class(jvmtiLocate, classSignature, classGeneric);
			return true;		
		}
	}

	jrst_deallocate_class(jvmtiLocate, classSignature, classGeneric);
	return false;
}

void JNICALL jrst_event_exception(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method, jlocation location, jobject exception, jmethodID catch_method, jlocation catch_location)
{
	
	jvmtiError error;
	jlong tag;
	char *methodName;
	char *methodSignature;
	char *methodGsignature;
	
	error = (*GET_JVMTI())->GetTag( GET_JVMTI(), exception, &tag);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Tag");
	

	(*jvmtiLocate)->NotifyFramePop(jvmtiLocate, thread, 0);
	(*jvmtiLocate)->NotifyFramePop(jvmtiLocate, thread, 1);
		
	error = (*jvmtiLocate)->GetMethodName(jvmtiLocate, method, &methodName, &methodSignature, &methodGsignature);
	jrst_check_error(jvmtiLocate,error, "Cannot read Method Name");

	if(methodName == NULL){
		return;		
	}
		
	jrst_enter_critical_section(jvmtiLocate, gagent->monitor);

	if(jrst_trace_methods() || jrst_find_method_all_class(methodName) || jrst_find_method(jvmtiLocate, method, methodName)){
		trace_event_exception(thread, (int)tag);
	}
	
	jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
	
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)methodName);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)methodSignature);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)methodGsignature);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
	
}


void JNICALL jrst_event_frame_pop(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method, jboolean was_popped_by_exception)
{
	
	if(!was_popped_by_exception){
		return;
	}
	
	jvmtiError error;
	char *methodName;
	char *methodSignature;
	char *methodGsignature;
		
	error = (*jvmtiLocate)->GetMethodName(jvmtiLocate, method, &methodName, &methodSignature, &methodGsignature);
	jrst_check_error(jvmtiLocate,error, "Cannot read Method Name");

	if(methodName == NULL){
		return;		
	}
	
	error = (*jvmtiLocate)->NotifyFramePop(jvmtiLocate, thread, 1);

//	if(strcmp(methodName, "findClass") != 0){
//	}
		
	jrst_enter_critical_section(jvmtiLocate, gagent->monitor);

	if(jrst_trace_methods() || jrst_find_method_all_class(methodName) || jrst_find_method(jvmtiLocate, method, methodName)){
		trace_event_method_exit_exception(thread);
	}
	
	jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
	
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)methodName);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)methodSignature);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");
	error = (*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)methodGsignature);
	jrst_check_error(jvmtiLocate,error, "Cannot deallocate memory");

}

/*void JNICALL jrst_event_exception_catch(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method, jlocation location, jobject exception){}*/

/*void JNICALL jrst_event_method_load(jvmtiEnv *jvmtiLocate, jmethodID method, jint code_size, const void* code_addr, jint map_length, const jvmtiAddrLocationMap* map, const void* compile_info){}*/

/*void JNICALL jrst_event_method_entry(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method){}*/

/*void JNICALL jrst_event_method_exit(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method, jboolean was_popped_by_exception, jvalue return_value){}*/
