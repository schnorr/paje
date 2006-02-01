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



#ifndef _JRASTRO_EVENTS_H_
#define _JRASTRO_EVENTS_H_

void JNICALL jrst_monitor_contended_enter(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object);

void JNICALL jrst_monitor_contended_entered(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object);

void JNICALL jrst_monitor_wait(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object, jlong timeout);

void JNICALL jrst_monitor_waited(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object, jboolean timed_out);		

void JNICALL jrst_event_VMObject_alloc(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jobject object, jclass object_klass, jlong size);

void JNICALL jrst_event_object_free(jvmtiEnv *jvmtiLocate, jlong tag);

void JNICALL jrst_event_garbage_collection_start(jvmtiEnv *jvmtiLocate);

void JNICALL jrst_event_garbage_collection_finish(jvmtiEnv *jvmtiLocate);	  

void JNICALL jrst_class_load(jvmtiEnv *jvmti_env, JNIEnv* jni_env, jthread thread, jclass klass);

void JNICALL jrst_event_exception(jvmtiEnv *jvmtiEnv, JNIEnv* jniEnv, jthread thread, jmethodID method, jlocation location, jobject exception, jmethodID catch_method, jlocation catch_location);

void JNICALL jrst_event_exception_catch(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method, jlocation location, jobject exception);

void JNICALL jrst_event_frame_pop(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv, jthread thread, jmethodID method, jboolean was_popped_by_exception);

void JNICALL jrst_event_method_load(jvmtiEnv *jvmtiLocate, jmethodID method, jint code_size, const void* code_addr, jint map_length, const jvmtiAddrLocationMap* map, const void* compile_info);

void JNICALL jrst_event_method_entry(jvmtiEnv *jvmtiEnv, JNIEnv* jniEnv, jthread thread, jmethodID method);

void JNICALL jrst_event_method_exit(jvmtiEnv *jvmtiEnv, JNIEnv* jniEnv, jthread thread, jmethodID method, jboolean was_popped_by_exception, jvalue return_value);


#endif		/*_JRASTRO_EVENTS_H_*/
