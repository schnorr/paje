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

/*Global agente, contem a JVMTI, monitores, ...*/
globalAgent *gagent;
/*Identifica as capacidades da JVM*/
jvmtiCapabilities capabilities;
/*Seta as funcoes para retorno dos eventos*/
jvmtiEventCallbacks callbacks;

/*Identificador(contador) das threads*/
long threadId = 1;
/*Identificador da thread main == Identificador da JVM*/
long jrst_mainThread;
/*Somador aleatorio, obtido pelo tempo*/
long adder;

/*Nome do arquivo com as opcoes dos eventos a serem selecionados*/
char eventsOptionName[MAX_NAME_OPTIONS];
/*Nome do arquivo com as opcoes das classes e metodos a serem selecionados*/
char methodsOptionName[MAX_NAME_OPTIONS];

/*Variavel para indicar se sera rastreados os eventos monitorados*/
bool traces       = true;
/*Variavel para setar se todos as classes e metodos serao rastreados*/
bool tracesAll    = false;
/*Variavel para indicar se os metodos serao rastreados*/
bool methodsTrace = false;
/*Variavel para indicar se a alocacao e liberacao de memoria sera rastreado*/
bool memoryTrace  = false;

/*Indica se ja ocorreu a inicializacao da JVM*/
bool initialized = false;

/*Hash com as classes a serem redefinidas*/
hash_t h_class;
/*Hash com as opcoes, classes e metodos*/
hash_t h_options;

/*Buffers*/
rst_buffer_t *ptr_loader    =  NULL;
rst_buffer_t *ptr_monitor   =  NULL;
rst_buffer_t *ptr_new_array =  NULL;


/*--------------------------------------------------
* void JNICALL jrst_event_VMStart(jvmtiEnv *jvmtiLocate, JNIEnv* jniEnv)
* {
* 	//jrst_enter_critical_section(GET_JVMTI());
* 
* 	//jrst_exit_critical_section(GET_JVMTI());
* }
*--------------------------------------------------*/

/*--------------------------------------------------
* //////////////////////////////////////////////////////////////////////////////
* / *const jniNativeInterface *original_jni_Functions;
* const jniNativeInterface *redirected_jni_Functions;
* int my_global_ref_count = 0;
* 
* jobject MyNewGlobalRef(JNIEnv *jniEnv, jobject obj)
* {
* 	++my_global_ref_count;
* 	printf("count=[%d] aqui...\n",my_global_ref_count);
* 	return original_jni_Functions->NewGlobalRef(jniEnv, obj);
* }
* 
* //////////////////////////////////////////////////////////////////////////////
* void jrst_JNI_function_interception(void)
* {
* 	jvmtiError err;
* 	printf("aqui...\n");
* 	err = (*GET_JVMTI())->GetJNIFunctionTable(GET_JVMTI(), &original_jni_Functions);
* 	if (err != JVMTI_ERROR_NONE) {
*         	 exit(1);
* 		 //die();
* 	}
* 	err = (*GET_JVMTI())->GetJNIFunctionTable(GET_JVMTI(), &redirected_jni_Functions);
* 	if (err != JVMTI_ERROR_NONE) {
*         	 exit(1);
* 		//die();
* 	}
* 	redirected_jni_Functions->NewGlobalRef = MyNewGlobalRef;
* 	err = (*GET_JVMTI())->SetJNIFunctionTable(GET_JVMTI(), redirected_jni_Functions);
* 	if (err != JVMTI_ERROR_NONE) {
*         	 exit(1);
* 		//die();
* 	}
* }
* * /
* 
* //////////////////////////////////////////////////////////////////////////////
*--------------------------------------------------*/
//unsigned class_number=0;
static int class_number = 0;


void JNICALL jrst_event_ClassFileLoadHook(jvmtiEnv *jvmtiLocate, JNIEnv *jniEnv, jclass class_being_redefined, jobject loader, const char* name, jobject protection_domain, jint class_data_len, const unsigned char* class_data, jint* new_class_data_len, unsigned char** new_class_data)
{
	jrst_enter_critical_section(jvmtiLocate, gagent->monitor);


	if(initialized == false){
		
		//if(jrst_trace_class((char *)name) == false || strcmp(name, "java/lang/ClassLoader") == 0 || strcmp(name, "java/util/Vector") == 0 || strcmp(name, "java/lang/CharacterDataLatin1") == 0 || strcmp(name, "java/lang/System") == 0 || strcmp(name, "java/lang/Character") == 0 || strcmp(name, "java/util/HashMap") == 0){
		if(jrst_trace_class((char *)name) == false){
			class_number++;
			jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
			return;		
		}
		
		jvmtiClassDefinition definition;
		definition.class_byte_count = class_data_len;
		definition.class_bytes = class_data;

		hash_insert(&h_class, (hash_key_t)name, (hash_data_t)&definition);
		
		jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
		return;
	}

	jvmtiError err;
	int system_class = 0;
	unsigned char *new_file_image = NULL;
	long new_file_len = 0;
	
	
	if(class_being_redefined == NULL){
		//if(jrst_trace_class((char *)name) == false || strcmp(name,"org/lsc/JRastro/Instru") == 0 || strcmp(name,"sun/misc/GC") == 0 || strcmp(name, "java/lang/Math") == 0){
		if(jrst_trace_class((char *)name) == false || strcmp(name,"org/lsc/JRastro/Instru") == 0){
			class_number++;
			jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
			return;
		}
	}else{
		system_class = 1;
	}

	//Registro do identificador e nome da classe
	trace_event_class_load(class_number, (char*)name);
	
//	printf("Classe name=[%s] class_number=[%d]\n",name,class_number);
	
//	if(!methodsTrace){
//		jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
//		return;		
//	}
	
	java_crw_demo(class_number,
				name,
				class_data,
				class_data_len,
				system_class,
				&new_file_image,
				&new_file_len,
				&jrst_trace_methods
	);

	if(new_file_len > 0){
		unsigned char *jvmti_space;
		err = (*jvmtiLocate)->Allocate(jvmtiLocate,(jlong)new_file_len, &jvmti_space); 
		jrst_check_error(jvmtiLocate, err, "Cannot Allocate memory");

		(void)memcpy((void*)jvmti_space, (void *)new_file_image, (int)new_file_len);
		*new_class_data_len = (jint)new_file_len;
		*new_class_data = jvmti_space;

	}
	class_number++;

	jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
}


//////////////////////////////////////////////////////////////////////////////
/*Evento de inicializacao da JVM*/
void JNICALL jrst_event_VMInit(jvmtiEnv *jvmtiLocate, JNIEnv *jniEnv, jthread thread)
{
	jrst_enter_critical_section(jvmtiLocate, gagent->monitor);
	
	char name[MAX_NAME_THREAD];
		
	/*------------------------------------------------*/
	/*Obtencao do numero aleatorio para somar com os threadId*/
	struct timeval rt;
	gettimeofday(&rt,NULL);
	adder = (long)rt.tv_usec;
	/*------------------------------------------------*/
	jrst_mainThread = threadId + adder;
	/*--------------------------------------------------
	* if(name != NULL){
	* 	printf("VMInit thread name=[%s]\n",name);
	* }
	*--------------------------------------------------*/
	
	/*Funcao que abilita as opcoes dos eventos*/
	jrst_read_events_enable(jvmtiLocate);
	
	jvmtiError error;
	jint class_count_ptr;
	jclass *classes_ptr;
	jvmtiClassDefinition definitions[300];
	hash_data_t *class = NULL;
	int count=0;
	int i;
	
	error = (*jvmtiLocate)->GetLoadedClasses(jvmtiLocate, &class_count_ptr, &classes_ptr);
	jrst_check_error(jvmtiLocate, error, "Cannot Get Loaded Classes");
	
	for(i=0; i < class_count_ptr; i++){
		
		char *signature_ptr;
		char *generic_ptr;
		int size = 0;
		char *tmp;
		
		error = (*jvmtiLocate)->GetClassSignature(jvmtiLocate, classes_ptr[i], &signature_ptr, &generic_ptr);
		jrst_check_error(jvmtiLocate, error, "Cannot Get Class Signature");

		/*Tirar da signature o caracter 'L'*/
		tmp = (char *)signature_ptr + 1;
		/* -1 Pois comeca em 0 o vetor*/
		size = strlen(tmp) - 1;
		/*Tira da signature o caracter ';'*/
		tmp[size] = '\0';

		class = hash_locate(&h_class, (hash_key_t)tmp);

		if(class != NULL){
			definitions[count] = **(jvmtiClassDefinition **)class;
			definitions[count].klass = classes_ptr[i];
			count++;
			
		}
		
		error=(*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char*)signature_ptr);
		jrst_check_error(jvmtiLocate, error, "Cannot deallocate memory");
		error=(*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char*)generic_ptr);
		jrst_check_error(jvmtiLocate, error, "Cannot deallocate memory");
	}
	
	initialized = true;

	error=(*jvmtiLocate)->RedefineClasses(jvmtiLocate, count, definitions);
	jrst_check_error(jvmtiLocate, error, "Redefine Classes");
	
	error=(*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char*)classes_ptr);
	jrst_check_error(jvmtiLocate, error, "Cannot deallocate memory");
	
	jrst_get_thread_name(jvmtiLocate, thread, name, MAX_NAME_THREAD);	
	
	trace_initialize(jvmtiLocate, thread, name);
	
	if(traces){
		jrst_threads(jvmtiLocate);
	}
	
	jrst_exit_critical_section(jvmtiLocate, gagent->monitor);
}


//////////////////////////////////////////////////////////////////////////////
/*--------------------------------------------------
* void JNICALL jrst_event_VMDeath(jvmtiEnv *jvmtiLocate, JNIEnv *jniEnv)
* {
* 	jrst_enter_critical_section(jvmtiLocate);
* 
* 	printf("VM Death event\n");
* 	
* 	jrst_exit_critical_section(jvmtiLocate);
* }
*--------------------------------------------------*/

//////////////////////////////////////////////////////////////////////////////
void jrst_set_capabilities()
{
	jvmtiError error;
	
	(void)memset(&capabilities, 0, sizeof(capabilities));
	
	/*Abilitar as abilidades que se deseja monitorar*/
	error = (*GET_JVMTI())->GetPotentialCapabilities(GET_JVMTI(), &capabilities);
	jrst_check_error(GET_JVMTI(), error, "Cannot Get Potential Capabilities");

	/*Verificacao de capacidades*/
	if(capabilities.can_signal_thread != 1 || 
	     capabilities.can_get_owned_monitor_info != 1 || 
	     capabilities.can_generate_exception_events != 1 ||
	     capabilities.can_generate_frame_pop_events != 1 ||
	     capabilities.can_generate_method_entry_events != 1 ||
	     capabilities.can_generate_method_exit_events != 1 ||
	     capabilities.can_generate_vm_object_alloc_events != 1 ||
	     capabilities.can_generate_object_free_events != 1 ||
	     capabilities.can_get_current_thread_cpu_time != 1 ||
	     capabilities.can_get_thread_cpu_time != 1 ||
	     capabilities.can_access_local_variables != 1 ||
	     capabilities.can_generate_compiled_method_load_events != 1 ||
	     capabilities.can_maintain_original_method_order != 1 ||
	     capabilities.can_generate_monitor_events != 1 ||
	     capabilities.can_generate_garbage_collection_events != 1 ||
	     capabilities.can_generate_all_class_hook_events != 1){

		printf("JVMTI_ERROR: Cannot get capabilities\n");
		exit(1);
	}
	
	error=(*GET_JVMTI())->AddCapabilities(GET_JVMTI(), &capabilities);
	jrst_check_error(GET_JVMTI(), error, "Cannot Enable JVMTI capabilities");

}

void jrst_set_funcs()
{
	jvmtiError error;
	
	(void)memset(&callbacks, 0, sizeof(callbacks));
	
	/*Abilitar as funcoes que serao chamadas*/
	callbacks.VMInit = &jrst_event_VMInit;
	callbacks.ClassFileLoadHook = &jrst_event_ClassFileLoadHook;
	callbacks.ThreadStart = &jrst_event_thread_start;
	callbacks.ThreadEnd = &jrst_event_thread_end;
	/*callbacks.VMObjectAlloc = &jrst_event_VMObject_alloc;*/
	callbacks.ObjectFree = &jrst_event_object_free;
	callbacks.GarbageCollectionStart = &jrst_event_garbage_collection_start;
	callbacks.GarbageCollectionFinish = &jrst_event_garbage_collection_finish;
	callbacks.Exception = &jrst_event_exception;
	/*callbacks.ExceptionCatch = &jrst_event_exception_catch;*/
	callbacks.FramePop = &jrst_event_frame_pop;
	callbacks.MonitorContendedEnter = &jrst_monitor_contended_enter;
	callbacks.MonitorContendedEntered = &jrst_monitor_contended_entered;
	callbacks.MonitorWait = &jrst_monitor_wait;
	callbacks.MonitorWaited = &jrst_monitor_waited;
	/*callbacks.VMStart = &jrst_event_VMStart;*/
	/*callbacks.VMDeath = &jrst_event_VMDeath;*/
	

	error=(*GET_JVMTI())->SetEventCallbacks(GET_JVMTI(), &callbacks,(jint)sizeof(callbacks));
	jrst_check_error(GET_JVMTI(), error, "Cannot set JVMTI callbacks");
}

void jrst_init()
{
	jvmtiError error;
	
	/*Abilita as funcoes JVMTI_EVENT_CLASS_FILE_LOAD_HOOK e JVMTI_EVENT_VM_INIT*/
	
	error=(*GET_JVMTI())->SetEventNotificationMode(GET_JVMTI(), JVMTI_ENABLE, JVMTI_EVENT_CLASS_FILE_LOAD_HOOK, (jthread)NULL);
	jrst_check_error(GET_JVMTI(), error, "Cannot set event notification <JVMTI_EVENT_CLASS_FILE_LOAD_HOOK>");
	
	error=(*GET_JVMTI())->SetEventNotificationMode(GET_JVMTI(), JVMTI_ENABLE, JVMTI_EVENT_VM_INIT, (jthread)NULL);
	jrst_check_error(GET_JVMTI(), error, "Cannot set event notification <JVMTI_EVENT_VM_INIT>");

/*	error=(*GET_JVMTI())->SetEventNotificationMode(GET_JVMTI(), JVMTI_ENABLE, JVMTI_EVENT_VM_DEATH, (jthread)NULL);
	jrst_check_error(GET_JVMTI(), error, "Cannot set event notification <JVMTI_EVENT_VM_DEATH>");
	
	error=(*GET_JVMTI())->SetEventNotificationMode(GET_JVMTI(), JVMTI_ENABLE, JVMTI_EVENT_VM_START, (jthread)NULL);
	jrst_check_error(GET_JVMTI(), error, "Cannot set event notification <JVMTI_EVENT_VM_START>");
*/

}

void jrst_create_monitor()
{
	jvmtiError error;

	/*Criacao dos monitores*/
	error=(*GET_JVMTI())->CreateRawMonitor(GET_JVMTI(), "agent", &(gagent->monitor));
	jrst_check_error(GET_JVMTI(), error, "Cannot create raw monitor");
	
	error=(*GET_JVMTI())->CreateRawMonitor(GET_JVMTI(), "thread", &(gagent->monitor_thread));
	jrst_check_error(GET_JVMTI(), error, "Cannot create raw monitor");
	
	error=(*GET_JVMTI())->CreateRawMonitor(GET_JVMTI(), "buffer", &(gagent->monitor_buffer));
	jrst_check_error(GET_JVMTI(), error, "Cannot create raw monitor");
	
	error=(*GET_JVMTI())->CreateRawMonitor(GET_JVMTI(), "newArray", &(gagent->monitor_new_array));
	jrst_check_error(GET_JVMTI(), error, "Cannot create raw monitor");
	
	error=(*GET_JVMTI())->CreateRawMonitor(GET_JVMTI(), "tag", &(gagent->monitor_tag));
	jrst_check_error(GET_JVMTI(), error, "Cannot create raw monitor");

}

JNIEXPORT jint JNICALL Agent_OnLoad(JavaVM *jvm, char *options, void *reserved)
{
	jint ret;
	
	printf("[JRastro] Loading Agent_Onload...\n");
	
	hash_initialize(&h_options, hash_value_string, hash_copy_string, hash_key_cmp_string, hash_destroy_string_list);
	hash_initialize(&h_class, hash_value_string, hash_copy_string_data, hash_key_cmp_string, hash_destroy_string_data);
	
	gagent = (globalAgent *) malloc(sizeof(globalAgent));

	ret=(*jvm)->GetEnv(jvm, (void **)&gagent->jvmti, JVMTI_VERSION_1_0);
	if(ret != JNI_OK || gagent->jvmti == NULL){
		printf("ERROR: Unable to access JVMTI Version 1 (0x%x),"
	                " is your J2SE a 1.5 or newer version?"
	                " JNIEnv's GetEnv() returned %d\n",
               JVMTI_VERSION_1, ret);
		exit(1);
	}
	
	
	/*Le nomes dos arquivos "opcoes"*/
	jrst_read_names_options(options);
	
	/*Funcao que abilita os methodos a serem rastreados*/
	jrst_read_class_methods_enable();

	jrst_set_capabilities();
	
	jrst_set_funcs();

	jrst_init();
	
	jrst_create_monitor();

	return JNI_OK;

}


//////////////////////////////////////////////////////////////////////////////
JNIEXPORT void JNICALL Agent_OnUnload(JavaVM *vm)
{
	//printf("Loading Agent_OnUnload ........");
	//extern int count;
	hash_finalize(&h_options);
	hash_finalize(&h_class);

	if(traces){
		rst_flush_all();
	}
	printf("[JRastro] ................OK\n");
}
	
