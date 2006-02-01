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

	
FILE *file;
list_t list;
list_t l_class;
hash_t h_class;
hash_t h_method;
hash_t h_thread;
hash_t h_mem;	
hash_data_t *class_name;
hash_data_t *class_number;
hash_data_t *data_list;
hash_data_t *data_mem;
rst_file_t data;
rst_event_t ev;
static bool read=false;
timestamp_t first;


void jrst_constant(FILE *file)
{
	fprintf(file,"1\tPJ\t0\t\"Program Java\"\n");
	fprintf(file,"1\tJVM\tPJ\t\"Java Virtual Machine\"\n");
	fprintf(file,"1\tC\tJVM\t\"Class\"\n");
	fprintf(file,"1\tO\tC\t\"Object\"\n");
	
	fprintf(file,"2\tEX\tO\t\"ExceptionE\"\n");
	
	fprintf(file,"3\tJS\tJVM\t\"JVM State\"\n");
	fprintf(file,"3\tS\tO\t\"Metodo\"\n");
	fprintf(file,"3\tMS\tO\t\"Monitor State\"\n");
	
	fprintf(file,"4\tMEM\tJVM\t\"Memory Allocation\"\n");
	
	fprintf(file,"6\texe\tJS\t\"Executing\"\n");
	fprintf(file,"6\tgc\tJS\t\"Garbage Collection\"\n");
	fprintf(file,"6\tlock\tMS\t\"Monitor locked\"\n");
	fprintf(file,"6\tex\tEX\t\"Start Exception\"\n");
	fprintf(file,"6\texpop\tEX\t\"Frame pop by Exception\"\n");
	
	fprintf(file,"7\t0.0\tpj\tPJ\t0\t\"Programa Java\"\n");
}

void jrst_access_flags(FILE *file, unsigned int flags)
{
    if(flags & JVM_ACC_PUBLIC){
        fprintf(file," PUBLIC");
    }
    if(flags & JVM_ACC_PRIVATE){
        fprintf(file," PRIVATE");
    }
    if(flags & JVM_ACC_PROTECTED){
        fprintf(file," PROTECTED");
    }
    if(flags & JVM_ACC_STATIC){
        fprintf(file," STATIC");
    }
    if(flags & JVM_ACC_FINAL){
        fprintf(file," FINAL");
    }
    if(flags & JVM_ACC_SYNCHRONIZED){
        fprintf(file," SYNCHRONIZED");
    }
    if(flags & JVM_ACC_NATIVE){
        fprintf(file," NATIVE");
    }
    if(flags & JVM_ACC_INTERFACE){
        fprintf(file," INTERFACE");
    }
    if(flags & JVM_ACC_ABSTRACT){
        fprintf(file," ABSTRACT");
    }
    if(flags & JVM_ACC_STRICT){
        fprintf(file," STRICT");
    }
}

void jrst_initialize()
{
	if(!read){
		first=ev.timestamp;
		read=true;
	}
	
	if(ev.id1 == ev.id2){
		fprintf(file,"7\t%.6f\tj-%lld\tJVM\tpj\t\"JVM-%lld\"\n",(((double)(ev.timestamp - first))/ 1000000.0),ev.id1,ev.id1);
		fprintf(file,"11\t%.6f\tJS\tj-%lld\texe\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1);
		fprintf(file,"13\t%.6f\tMEM\tj-%lld\t0.0\n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1);
	}
	list_t *new_list;

	new_list = (list_t *) malloc(sizeof(list_t));
	if(new_list == NULL){
		printf("ERROR: Cannot malloc list\n");
		exit(3);
	}

	list_initialize(new_list, list_copy, list_cmp, list_destroy);
	hash_insert(&h_thread, (hash_key_t)(long)ev.id2, (hash_data_t)new_list);
}

void jrst_finalize()
{
	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	position_t pos;
	for(pos = list_inicio(tmp); pos != NULL ; pos = list_inicio(tmp)){
		fprintf(file,"12\t%.6f\tS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, (int)pos->data);
		//fprintf(file,"8\t%.6f\to-%x\tO\n",(((double)(ev.timestamp - first)) / 1000000), (int)pos->data);
		
		list_rem_position (tmp, pos);
	}
	list_finalize(tmp);
	//hash_remove(&h_thread, (hash_key_t)(long)ev.id2);
}			

void jrst_event_class()
{
	hash_insert(&h_class, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1), (hash_data_t)ev.v_string[0]);
}

void jrst_event_method()
{
	class_name = hash_locate(&h_class, (hash_key_t)(ev.v_uint32[1]+(int)ev.id1));
	if(class_name == NULL){
		printf("ERROR: Cannot Method load\n");
		exit(1);
	}
	if(ev.v_uint32[2] == 0){
		fprintf(file,"666\te-%lld.%x\tS\t\"%s.%s\"\t%lld.%x\n", ev.id1, ev.v_uint32[0], *(char **)class_name, ev.v_string[0], ev.id1, ev.v_uint32[1]);
	}else{
		fprintf(file,"6666\te-%lld.%x\tS\t\"%s.%s\"\t%lld.%x\t\"F=", ev.id1, ev.v_uint32[0], *(char **)class_name, ev.v_string[0], ev.id1, ev.v_uint32[1]);
		jrst_access_flags(file, ev.v_uint32[2]);
		fprintf(file,"\"\n");
	}

	hash_insert(&h_method, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1), (hash_data_t) (ev.v_uint32[1]+(int)ev.id1));
}

void jrst_event_method_entry_alloc()
{
	if(strcmp(ev.v_string[0], "") != 0){
		//Coloquei essa parte para inicializar os objetos
		list_class_t classID;
		classID.jvm = ev.id1;
		classID.className = ev.v_string[0];
		
		if(!list_find(&l_class, (void *)&classID)){
			// printf("init alloc=[%s]\n", ev.v_string[0]);
			fprintf(file,"7\t%.6f\tc-%lld.%s\tC\tj-%lld\t\"c-%lld.%s\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_string[0], ev.id1, ev.id1, ev.v_string[0]);
			list_insert_after(&l_class, NULL, (void *)&classID);
		}
		list_object_t obj;
		obj.jvm = ev.id1;
		obj.idObject = ev.v_uint32[0];
		
		if(!list_find(&list, (void *)&obj)){
			fprintf(file,"7\t%.6f\to-%lld.%x\tO\tc-%lld.%s\t\"o-%lld.%s.%x\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, ev.v_string[0], ev.id1, ev.v_string[0], ev.v_uint32[0]);
			
			list_insert_after(&list, NULL, (void *)&obj);
		}
	}else{
		int n_class = 0;
			
		class_number = hash_locate(&h_method, (hash_key_t)(ev.v_uint32[1]+(int)ev.id1));
		if(class_number == NULL){
			printf("ERROR: Cannot Method Class\n");
        	exit(2);
        }
		n_class = *((int*)class_number) - (int)ev.id1;
		class_name = hash_locate(&h_class, (hash_key_t)(n_class+(int)ev.id1));
		if(class_name == NULL){
        	printf("ERROR: Cannot Method load\n");
        	exit(1);
		}
		list_class_t classID;
		classID.jvm = ev.id1;
		classID.className = *(char **)class_name;
					
		if(!list_find(&l_class, (void *) &classID)){
			// printf("init alloc=[%s]\n", ev.v_string[0]);
			fprintf(file,"7\t%.6f\tc-%lld.%s\tC\tj-%lld\t\"c-%lld.%s\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, *(char **)class_name, ev.id1, ev.id1, *(char **)class_name);
			list_insert_after(&l_class, NULL, (void *) &classID);
		}
		list_object_t obj;
		obj.jvm = ev.id1;
		obj.idObject = ev.v_uint32[0];
		
		if(!list_find(&list, (void *)&obj)){
			fprintf(file,"7\t%.6f\to-%lld.%x\tO\tc-%lld.%s\t\"o-%lld.%s.%x\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, *(char **)class_name, ev.id1, *(char **)class_name, ev.v_uint32[0]);
			
			list_insert_after(&list, NULL, (void *)&obj);
		}
		
	}
	//////////////////////////////////////////////////////
	  fprintf(file,"14\t%.6f\tMEM\tj-%lld\t%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, ev.v_uint64[0]);
	  hash_insert(&h_mem, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1), (hash_data_t)((long)ev.v_uint64[0]));
	
	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	list_insert_after(tmp, NULL, (list_data_t)ev.v_uint32[0]);
	//printf("obj=[%x] method=[%x] class=[] name=[]\n",ev.v_uint32[0], ev.v_uint32[1]);
	
	fprintf(file,"11\t%.6f\tS\to-%lld.%x\te-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0], ev.id1, ev.v_uint32[1]);
}

void jrst_jvmti_event_method_entry()
{
	int n_class = 0;
			
	class_number = hash_locate(&h_method, (hash_key_t)(ev.v_uint32[1]+(int)ev.id1));
	if(class_number == NULL){
		printf("ERROR: Cannot Method Class\n");
       	exit(2);
    }
	n_class = *((int*)class_number) - (int)ev.id1;
	class_name = hash_locate(&h_class, (hash_key_t)(n_class+(int)ev.id1));
	if(class_name == NULL){
       	printf("ERROR: Cannot Method load\n");
       	exit(1);
	}
	list_class_t classID;
	classID.jvm = ev.id1;
	classID.className = *(char **)class_name;
		
	if(!list_find(&l_class, (void *) &classID)){
		// printf("init alloc=[%s]\n", ev.v_string[0]);
		fprintf(file,"7\t%.6f\tc-%lld.%s\tC\tj-%lld\t\"c-%lld.%s\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, *(char **)class_name, ev.id1, ev.id1, *(char **)class_name);
		list_insert_after(&l_class, NULL, (void *) &classID);
	}
	list_object_t obj;
	obj.jvm = ev.id1;
	obj.idObject = ev.v_uint32[0];
	
	if(!list_find(&list, (void *)&obj)){
		fprintf(file,"7\t%.6f\to-%lld.%x\tO\tc-%lld.%s\t\"o-%lld.%s.%x\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, *(char **)class_name, ev.id1, *(char **)class_name, ev.v_uint32[0]);
	
		list_insert_after(&list, NULL, (void *)&obj);
	}
		
	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	list_insert_after(tmp, NULL, (list_data_t)ev.v_uint32[0]);
	//printf("obj=[%x] method=[%x] class=[] name=[]\n",ev.v_uint32[0], ev.v_uint32[1]);
	
	fprintf(file,"11\t%.6f\tS\to-%lld.%x\te-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0], ev.id1, ev.v_uint32[1]);
}			

void jrst_method_entry()
{
	int n_class = 0;
			
	class_number = hash_locate(&h_method, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1));
	if(class_number == NULL){
		printf("ERROR: Cannot Method Class\n");
       	exit(2);
    }
	n_class = *((int*)class_number) - (int)ev.id1;
	class_name = hash_locate(&h_class, (hash_key_t)(n_class+(int)ev.id1));
	if(class_name == NULL){
       	printf("ERROR: Cannot Method load\n");
       	exit(1);
	}
	list_class_t classID;
	classID.jvm = ev.id1;
	classID.className = *(char **)class_name;
		
	if(!list_find(&l_class, (void *) &classID)){
		// printf("init alloc=[%s]\n", ev.v_string[0]);
		fprintf(file,"7\t%.6f\tc-%lld.%s\tC\tj-%lld\t\"c-%lld.%s\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, *(char **)class_name, ev.id1, ev.id1, *(char **)class_name);
		list_insert_after(&l_class, NULL, (void *) &classID);
	}
	list_object_t obj;
	obj.jvm = ev.id1;
	obj.idObject = n_class;
	
	if(!list_find(&list, (void *)&obj)){
		fprintf(file,"7\t%.6f\to-%lld.%x\tO\tc-%lld.%s\t\"o-%lld.%s.%x\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, n_class, ev.id1, *(char **)class_name, ev.id1, *(char **)class_name, n_class);
	
		list_insert_after(&list, NULL, (void *)&obj);
	}

	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	list_insert_after(tmp, NULL, (list_data_t)n_class);
	
	fprintf(file,"11\t%.6f\tS\to-%lld.%x\te-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, n_class, ev.id1, ev.v_uint32[0]);
}				

void jrst_jvmti_event_method_exit()
{
	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	position_t pos;
	pos = list_inicio(tmp);
	if(pos == NULL){
		printf("ERROR: Cannot get data list\n");
		exit(2);
	}
	fprintf(file,"12\t%.6f\tS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, (int)pos->data);
	list_rem_position (tmp, NULL);
}		

void jrst_method_exception()
{
	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	position_t pos;
	pos = list_inicio(tmp);
	if(pos == NULL){
		printf("ERROR: Cannot get data list\n");
		exit(2);
	}
	fprintf(file,"9999\t%.6f\tEX\to-%lld.%x\tex\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, (int)pos->data, ev.id1, ev.v_uint32[0]);
}						

void jrst_method_exit_exception()
{
	data_list = hash_locate(&h_thread, (hash_key_t)(long)ev.id2);
	if(data_list == NULL){
                printf("ERROR: Cannot load list\n");
                exit(1);
          }
	list_t *tmp = *(list_t **)data_list;
	position_t pos;
	pos = list_inicio(tmp);
	if(pos == NULL){
		printf("ERROR: Cannot get data list\n");
		exit(2);
	}
	fprintf(file,"12\t%.6f\tS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, (int)pos->data);
	fprintf(file,"9\t%.6f\tEX\to-%lld.%x\texpop\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, (int)pos->data);
	list_rem_position (tmp, NULL);
}						

void jrst_jvmti_event_vm_object_alloc()
{
	//Coloquei essa parte para inicializar os objetos
	list_class_t classID;
	classID.jvm = ev.id1;
	classID.className = ev.v_string[0];
	
	if(!list_find(&l_class, (void *) &classID)){
		 // printf("init alloc=[%s]\n", ev.v_string[0]);
		if(strcmp(ev.v_string[0], "") == 0){
			fprintf(file,"7\t%.6f\tc-%lld.Unknown\tC\tj-%lld\t\"c-%lld.Unknown\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.id1, ev.id1);
		}else{
			fprintf(file,"7\t%.6f\tc-%lld.%s\tC\tj-%lld\t\"c-%lld.%s\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_string[0], ev.id1, ev.id1, ev.v_string[0]);
		}
		list_insert_after(&l_class, NULL, (void *) &classID);

	}
	list_object_t obj;
	obj.jvm = ev.id1;
	obj.idObject = ev.v_uint32[0];

	if(!list_find(&list, (void *)&obj)){
		 // printf("init alloc=[%s]\n", ev.v_string[0]);
		if(strcmp(ev.v_string[0], "") == 0){
			fprintf(file,"7\t%.6f\to-%lld.%x\tO\tc-%lld.Unknown\t\"o-%lld.%x\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, ev.id1, ev.v_uint32[0]);
		}else{
			fprintf(file,"7\t%.6f\to-%lld.%x\tO\tc-%lld.%s\t\"o-%lld.%s.%x\" \n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, ev.v_string[0], ev.id1, ev.v_string[0], ev.v_uint32[0]);
		}
		list_insert_after(&list, NULL, (void *)&obj);
	}
	//////////////////////////////////////////////////////
	  fprintf(file,"14\t%.6f\tMEM\tj-%lld\t%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, ev.v_uint64[0]);
	  hash_insert(&h_mem, (hash_key_t)(ev.v_uint32[0] + (int)ev.id1), (hash_data_t)((long)ev.v_uint64[0]));
}

void jrst_jvmti_event_object_free()
{
	data_mem = hash_locate(&h_mem, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1));
	if(data_mem == NULL){
		printf("ERROR: Cannot JVMTI_EVENT_OBJECT_FREE \n");
		printf("\tObjeto=[%x] nao achado para liberar\n",ev.v_uint32[0]); 
		return;
		//continue;
		//exit(2);
	}
	fprintf(file,"15\t%.6f\tMEM\tj-%lld\t%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, (long long)*(long*)data_mem);
	
	list_object_t obj;
	obj.jvm = ev.id1;
	obj.idObject = ev.v_uint32[0];
	
	if(list_find(&list, (void *)&obj)){
		fprintf(file,"8\t%.6f\to-%lld.%x\tO\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
	}
}

void jrst_jvmti_event_garbage_collection_start()
{
	fprintf(file,"11\t%.6f\tJS\tj-%lld\tgc\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1);
}

void jrst_jvmti_event_garbage_collection_finish()
{
	fprintf(file,"12\t%.6f\tJS\tj-%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1);
}

void jrst_event_monitor_enter()
{
	fprintf(file,"11\t%.6f\tMS\to-%lld.%x\tlock\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
}

void jrst_event_monitor_entered()
{
	fprintf(file,"12\t%.6f\tMS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
}		

void jrst_event_monitor_wait()
{
	fprintf(file,"11\t%.6f\tMS\to-%lld.%x\tlock\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
}

void jrst_event_monitor_waited()
{
	fprintf(file,"12\t%.6f\tMS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
}

void jrst_event_select()
{
	
	if(ev.type == INITIALIZE){
		jrst_initialize();
		
	}else if(ev.type == FINALIZE){
		jrst_finalize();
		
	}else if(ev.type == CLASS_LOAD){
		jrst_event_class();
		
	}else if(ev.type == METHOD_LOAD){
		jrst_event_method();
		
	}else if(ev.type == EVENT_METHOD_ENTRY_ALLOC){
		jrst_event_method_entry_alloc();
		
	}else if(ev.type == JVMTI_EVENT_METHOD_ENTRY){
		jrst_jvmti_event_method_entry();
		
	}else if(ev.type == METHOD_ENTRY){ //Sem o objeto
		jrst_method_entry();
		
	}else if(ev.type == JVMTI_EVENT_METHOD_EXIT){
		jrst_jvmti_event_method_exit();
		
	}else if(ev.type == METHOD_EXCEPTION){
		jrst_method_exception();
		
	}else if(ev.type == METHOD_EXIT_EXCEPTION){
		jrst_method_exit_exception();
		
	}else if(ev.type == JVMTI_EVENT_VM_OBJECT_ALLOC){
		jrst_jvmti_event_vm_object_alloc();
		
	}else if(ev.type == JVMTI_EVENT_OBJECT_FREE){
		jrst_jvmti_event_object_free();
		
	}else if(ev.type == JVMTI_EVENT_GARBAGE_COLLECTION_START){
		jrst_jvmti_event_garbage_collection_start();
		
	}else if(ev.type == JVMTI_EVENT_GARBAGE_COLLECTION_FINISH){
		jrst_jvmti_event_garbage_collection_finish();		
		
	}else if(ev.type == MONITOR_ENTER){
		jrst_event_monitor_enter();
		
	}else if(ev.type == MONITOR_ENTERED){
		jrst_event_monitor_entered();
		
	}else if(ev.type == MONITOR_WAIT){
		jrst_event_monitor_wait();
		
	}else if(ev.type == MONITOR_WAITED){
		jrst_event_monitor_waited();
		
	}
}


int main(int argc, char *argv[])
{

	int i;
	
	if(argc < 3){
		printf("ERROR: Cannot read args\n");
		printf("\t%s <TimeSync File> <Trace Files>\n",argv[0]);
		exit(1);
	}
	
	file=fopen("rastrosObjClass.trace","w");
	
	paje_header(file);

	jrst_constant(file);
	
	list_initialize(&list, list_copy_object, list_cmp_object, list_destroy_int);
	
	list_initialize(&l_class, list_copy_string_class, list_cmp_string_class, list_destroy_string_class);

	hash_initialize(&h_class, hash_value, hash_copy, hash_key_cmp, hash_destroy);
	hash_initialize(&h_method, hash_value, hash_copy_new, hash_key_cmp, hash_destroy_new);
	hash_initialize(&h_thread, hash_value, hash_copy_new, hash_key_cmp, hash_destroy_new_thread);
	hash_initialize(&h_mem, hash_value, hash_copy_new, hash_key_cmp, hash_destroy_new);
      
	for (i=2; i<argc; i++) {
		if (rst_open_file(argv[i], &data, argv[1], 100000) == -1) {
			fprintf(stderr, "could not open rastro file %s\n", argv[i]);
			continue;
		}
	}
	while (rst_decode_event(&data, &ev)){
		
		jrst_event_select();

	}
	position_t pos;

	for(pos = list_inicio(&list); pos != NULL ; pos = list_inicio(&list)){
		list_object_t *obj;
		obj = (list_object_t *) pos->data;
		
		fprintf(file,"8\t%.6f\to-%lld.%x\tO\n",(((double)(ev.timestamp - first)) / 1000000), (long long)obj->jvm, obj->idObject);
		list_rem_position (&list, pos);
	}
	
	for(pos = list_inicio(&l_class); pos != NULL ; pos = list_inicio(&l_class)){
		list_class_t *classID;
		classID = (list_class_t *) pos->data;
		
		if(strcmp((char *)classID->className, "") != 0){
			fprintf(file,"8\t%.6f\tc-%lld.%s\tC\n",(((double)(ev.timestamp - first)) / 1000000), (long long)classID->jvm, (char *)classID->className);
		}else{
			fprintf(file,"8\t%.6f\tc-%lld.Unknown\tC\n",(((double)(ev.timestamp - first)) / 1000000), (long long)classID->jvm);
		}
		list_rem_position (&l_class, pos);
	}
			
	fprintf(file,"12\t%.6f\tJS\tj-%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1);
	fprintf(file,"8\t%.6f\tj-%lld\tJVM\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1);
	fprintf(file,"8\t%.6f\tpj\tPJ\n",(((double)(ev.timestamp - first)) / 1000000));

	list_finalize(&list);
	list_finalize(&l_class);
	hash_finalize(&h_class);
	hash_finalize(&h_method);
	hash_finalize(&h_thread);
	hash_finalize(&h_mem);

	fclose(file);
	return 0;
}

