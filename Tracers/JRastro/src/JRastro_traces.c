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



#include"JRastro.h"

/*Identificador(contador) das threads, variavel declarada em JRastro.c*/
extern long threadId;
/*Identificador da thread main == Identificador da JVM, declarada em JRastro.c*/
extern long jrst_mainThread;
/*Somador aleatorio, obtido pelo tempo, declarada em JRastro.c*/
extern long adder;

//rst_buffer_t * get_buffer(jvmtiEnv *jvmtiLocate, jthread thread)
//{
//	rst_buffer_t *ptr;
//	jvmtiError error;
//	
//	error = (*jvmtiLocate)->GetThreadLocalStorage(jvmtiLocate, thread, (void**)&ptr);
//	if (ptr == NULL || error!= JVMTI_ERROR_NONE){
//		char name[MAX_NAME_THREAD];
//		jvmtiError err;
//		
//		jrst_get_thread_name(jvmtiLocate, thread, name, MAX_NAME_THREAD);
//		if(name == NULL){
//			(void)strcpy(name,"Unknown");
//		}
//		printf("getbuffer thread name=[%s]\n",name);
//		return NULL;
//		trace_initialize(jvmtiLocate, thread, name);
//		
//		err = (*jvmtiLocate)->GetThreadLocalStorage(jvmtiLocate, thread, (void**)&ptr);
//		jrst_check_error(jvmtiLocate, err, "Cannot Get Thread Local Storage");
//				
//	}
//	return ptr;
//
//}


void trace_initialize(jvmtiEnv *jvmtiLocate, jthread thread, char *name)
{

	if(traces){
		
		rst_buffer_t *ptr;
		jvmtiThreadInfo infoThread;
		jvmtiError error;
		
		ptr = (rst_buffer_t *) malloc(sizeof(rst_buffer_t));
		
		jrst_enter_critical_section(jvmtiLocate, gagent->monitor_thread);
		
		error=(*jvmtiLocate)->GetThreadInfo(jvmtiLocate, thread, &infoThread);
		jrst_check_error(jvmtiLocate, error, "Cannot get Thread Info");
		
		rst_init_ptr(ptr, (u_int64_t)jrst_mainThread, (u_int64_t)(threadId + adder));	
		rst_event_isiii_ptr(ptr, INITIALIZE, (int)threadId, name, (int)infoThread.priority, (int)infoThread.is_daemon, (int)infoThread.thread_group);

		threadId ++;
		
		error = (*jvmtiLocate)->SetThreadLocalStorage(jvmtiLocate, thread, (void*)ptr);
		jrst_check_error(jvmtiLocate, error, "Cannot Set Thread Local Storage");
		
		jrst_exit_critical_section(jvmtiLocate, gagent->monitor_thread);
		
		error=(*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)infoThread.name);
		jrst_check_error(jvmtiLocate, error,"Cannot deallocate memory");
	
	}
}

void trace_finalize(jvmtiEnv *jvmtiLocate, jthread thread)
{
	
	if(traces){
		rst_buffer_t *ptr;
		jvmtiError error;
	
		jrst_enter_critical_section(jvmtiLocate, gagent->monitor_thread);
		
		//ptr = get_buffer(jvmtiLocate, thread);
		error = (*jvmtiLocate)->GetThreadLocalStorage(jvmtiLocate, thread, (void**)&ptr);
		if (ptr == NULL){
			jrst_exit_critical_section(jvmtiLocate, gagent->monitor_thread);
			return;
		}
		
		rst_event_ptr(ptr, FINALIZE);
		rst_finalize_ptr(ptr);
	
		error = (*jvmtiLocate)->SetThreadLocalStorage(jvmtiLocate, thread, NULL);
		jrst_check_error(jvmtiLocate, error, "Cannot Set Thread Local Storage");
		
		jrst_exit_critical_section(jvmtiLocate, gagent->monitor_thread);
	}
}

static int tag = 0;

void trace_event_object_alloc(jthread thread, jobject object, char *nameClass)
{

	if(traces){
		rst_buffer_t *ptr;
		jvmtiError error;
		jlong size;
		int id = 0;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL){
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		error = (*GET_JVMTI())->GetObjectSize(GET_JVMTI(), object, &size);
		jrst_check_error(GET_JVMTI(), error, "Cannot Set Thread Local Storage");

		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_tag);
		
		tag++;
		id = tag;

//		printf("alloc=[%x] thread=[%s] size=[%ld]\n", id, name, (long)size);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_tag);
		
		
		rst_event_lis_ptr(ptr, JVMTI_EVENT_VM_OBJECT_ALLOC, size, id, nameClass);
		error = (*GET_JVMTI())->SetTag(GET_JVMTI(), object, (jlong)id);
		jrst_check_error(GET_JVMTI(), error, "Cannot Set Tag");
		
		/*if(tag == 500){
			error = (*GET_JVMTI())->ForceGarbageCollection(GET_JVMTI());
			jrst_check_error(GET_JVMTI(), error, "Cannot Force Garbage Collection");						  
		}*/
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}


void trace_event_object_alloc_new_array(jthread thread, jobject object, char *nameClass)
{

	if(traces){
		jvmtiError error;
		jlong size;
		int id = 0;

//		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_new_array);

		if(ptr_new_array == NULL){
			ptr_new_array = (rst_buffer_t *)malloc(sizeof(rst_buffer_t));
			rst_init_ptr(ptr_new_array, (u_int64_t)jrst_mainThread, (u_int64_t)THREAD_NEW_ARRAY);
		}

		error = (*GET_JVMTI())->GetObjectSize(GET_JVMTI(), object, &size);
		jrst_check_error(GET_JVMTI(), error, "Cannot Set Thread Local Storage");
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_tag);
		
		tag++;
		id = tag;
//		printf("new array=[%x]\n", id);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_tag);
		
		rst_event_lis_ptr(ptr_new_array, JVMTI_EVENT_VM_OBJECT_ALLOC, size, id, nameClass);
		
		error = (*GET_JVMTI())->SetTag(GET_JVMTI(), object, (jlong)id);
		jrst_check_error(GET_JVMTI(), error, "Cannot Set Tag");
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_new_array);
//		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);

	}
}

void trace_event_object_free(jlong tag)
{

	if(traces){
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_buffer);
		
		if(ptr_monitor == NULL){
			ptr_monitor = (rst_buffer_t *)malloc(sizeof(rst_buffer_t));
			rst_init_ptr(ptr_monitor, (u_int64_t)jrst_mainThread, (u_int64_t)THREAD_MONITOR);
		}

//		printf("free=[%x]\n", (int)tag);
		rst_event_i_ptr(ptr_monitor, JVMTI_EVENT_OBJECT_FREE, (int)tag);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_buffer);
	}
}

void trace_event_gc_start()
{
	if(traces){
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_buffer);
		
		if(ptr_monitor == NULL){
			ptr_monitor = (rst_buffer_t *)malloc(sizeof(rst_buffer_t));
			rst_init_ptr(ptr_monitor, (u_int64_t)jrst_mainThread, (u_int64_t)THREAD_MONITOR);
		}
		rst_event_ptr(ptr_monitor, JVMTI_EVENT_GARBAGE_COLLECTION_START);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_buffer);
	}
}

void trace_event_gc_finish()
{
	if(traces){
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_buffer);
		
		rst_event_ptr(ptr_monitor, JVMTI_EVENT_GARBAGE_COLLECTION_FINISH);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_buffer);
	}
}

void trace_event_method_entry_obj_init(jthread thread, jobject object, int method, char *nameClass)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		jlong id = 0;
		jlong size = 0;

		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
		//ptr = get_buffer(GET_JVMTI(), thread);
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL || error!= JVMTI_ERROR_NONE){
//			printf("trace_event_method_entry_objc thread method=[%x]\n",method);
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
				
		error = (*GET_JVMTI())->GetObjectSize(GET_JVMTI(), object, &size);
		jrst_check_error(GET_JVMTI(), error, "Cannot Set Thread Local Storage");
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_tag);
		
		tag++;
		id = (jlong)tag;
		//printf("enter =[%d]\n", (int)id);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_tag);

		rst_event_liis_ptr(ptr, EVENT_METHOD_ENTRY_ALLOC, size, (int)id, method, nameClass);
		
		error = (*GET_JVMTI())->SetTag(GET_JVMTI(), object, id);
		jrst_check_error(GET_JVMTI(), error, "Cannot Set Tag");
				
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_method_entry_obj(jthread thread, int object, int method)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;

		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
		//ptr = get_buffer(GET_JVMTI(), thread);
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL || error!= JVMTI_ERROR_NONE){
//			printf("trace_event_method_entry_objc thread method=[%x]\n",method);
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		rst_event_ii_ptr(ptr, JVMTI_EVENT_METHOD_ENTRY, object, method);
	
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}

}

void trace_event_method_entry(jthread thread, int method)
{
	
	if(traces){
		rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
		//ptr = get_buffer(GET_JVMTI(), thread);
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL || error!= JVMTI_ERROR_NONE){		
//			printf("trace_event_method_entry thread method=[%d]\n",method);
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
				
		rst_event_i_ptr(ptr, METHOD_ENTRY, method);
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_method_exit(jthread thread)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
	//	ptr = get_buffer(GET_JVMTI(), thread);
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL || error!= JVMTI_ERROR_NONE){
//			printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		rst_event_ptr(ptr, JVMTI_EVENT_METHOD_EXIT);
	
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_exception(jthread thread, int exception)
{
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
	//	ptr = get_buffer(GET_JVMTI(), thread);
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL || error!= JVMTI_ERROR_NONE){
//			printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}

		rst_event_i_ptr(ptr, METHOD_EXCEPTION, exception);
		
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
	}
}

void trace_event_method_exit_exception(jthread thread)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
	//	ptr = get_buffer(GET_JVMTI(), thread);
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL || error!= JVMTI_ERROR_NONE){
//			printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		rst_event_ptr(ptr, METHOD_EXIT_EXCEPTION);
	
		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_method_load(int method, char *name, unsigned access_flags, int klass)
{
	
	if(traces){
		rst_event_isii_ptr(ptr_loader, METHOD_LOAD, method, name, klass, access_flags);
	}
}

void trace_event_class_load(int klass, char *name)
{
	
	if(traces){
		if(ptr_loader == NULL){
			ptr_loader = (rst_buffer_t *)malloc(sizeof(rst_buffer_t));
			rst_init_ptr(ptr_loader, (u_int64_t)jrst_mainThread, (u_int64_t)THREAD_LOADER);
		}
		rst_event_is_ptr(ptr_loader, CLASS_LOAD, klass, name);
	}
}

void trace_event_monitor_contended_enter(jvmtiEnv *jvmtiLocate, jthread thread, int object)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL){
			//printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		rst_event_i_ptr(ptr, MONITOR_ENTER, object);

		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_monitor_contended_entered(jvmtiEnv *jvmtiLocate, jthread thread, int object)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);

		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL){
//			printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		rst_event_i_ptr(ptr, MONITOR_ENTERED, object);

		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_monitor_wait(jvmtiEnv *jvmtiLocate, jthread thread, int object)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);
		
		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL){
			//printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		rst_event_i_ptr(ptr, MONITOR_WAIT, object);

		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}

void trace_event_monitor_waited(jvmtiEnv *jvmtiLocate, jthread thread, int object)
{
	
	if(traces){
      	rst_buffer_t *ptr;
		jvmtiError error;
		
		jrst_enter_critical_section(GET_JVMTI(), gagent->monitor_thread);

		error = (*GET_JVMTI())->GetThreadLocalStorage(GET_JVMTI(), thread, (void**)&ptr);
		if (ptr == NULL){
//			printf("trace_event_method_saida thread \n");
			jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
			return;
		}
		
		rst_event_i_ptr(ptr, MONITOR_WAITED, object);

		jrst_exit_critical_section(GET_JVMTI(), gagent->monitor_thread);
	}
}
