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
rst_file_t data;
rst_event_t ev;
static bool read=false;
timestamp_t first;
hash_t h_class;
hash_t h_method;
hash_t h_mem;
hash_data_t *class_name;
hash_data_t *class_number;
hash_data_t *data_mem;
list_t monitores;	
int count = 0;


void jrst_constant(FILE *file)
{
	fprintf(file,"1\tPJ\t0\t\"Program Java\"\n");
	fprintf(file,"1\tJVM\tPJ\t\"Java Virtual Machine\"\n");
	fprintf(file,"1\tT\tJVM\t\"Thread\"\n");
	fprintf(file,"1\tM\tJVM\t\"Monitor\"\n");
	
	fprintf(file,"2\tE\tT\t\"MonitorE\"\n");
	fprintf(file,"2\tEX\tT\t\"ExceptionE\"\n");
	
	fprintf(file,"3\tJS\tJVM\t\"JVM State\"\n");
	fprintf(file,"3\tS\tT\t\"Metodo\"\n");
	fprintf(file,"3\tMS\tM\t\"Monitor State\"\n");
	
	fprintf(file,"4\tMEM\tJVM\t\"Memory Allocation\"\n");
	
	fprintf(file,"5\tLTM\tJVM\tT\tM\t\"Thread blocked\"\n");
	fprintf(file,"5\tLMT\tJVM\tM\tT\t\"Thread unblocked\"\n");
	
	fprintf(file,"6\texe\tJS\t\"Executing\"\n");
	fprintf(file,"6\tgc\tJS\t\"Garbage Collection\"\n");
	fprintf(file,"6\tlock\tS\t\"Thread locked\"\n");
	fprintf(file,"6\tlock\tMS\t\"Monitor locked\"\n");
	fprintf(file,"6\tfree\tMS\t\"Monitor free\"\n");
	fprintf(file,"6\tme\tE\t\"Monitor enter\"\n");
	fprintf(file,"6\tmed\tE\t\"Monitor entered\"\n");
	fprintf(file,"6\tmw\tE\t\"Monitor wait\"\n");
	fprintf(file,"6\tmwd\tE\t\"Monitor waited\"\n");
	fprintf(file,"6\tlb\tLTM\t\"Thread blocked\"\n");
	fprintf(file,"6\tlub\tLMT\t\"Thread unblocked\"\n");
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
	fprintf(file,"777\t%.6f\tt-%lld\tT\tj-%lld\t\"%s-%d\"\t%x\t%x\t%x\n",(((double)(ev.timestamp - first))/ 1000000.0),ev.id2,ev.id1,ev.v_string[0], count, ev.v_uint32[1], ev.v_uint32[2],ev.v_uint32[3]);
	count++;
}			

void jrst_finalize()
{
	fprintf(file,"8\t%.6f\tt-%lld\tT\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2);
}		

void jrst_event_class()
{
	hash_insert(&h_class, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1), (hash_data_t)ev.v_string[0]);
}

void jrst_event_method()
{
	class_name = hash_locate(&h_class, (hash_key_t)(ev.v_uint32[1]+(int)ev.id1));
	if(class_name == NULL){
		printf("ERROR: Cannot load Method\n");
		exit(1);
	}
	if(ev.v_uint32[2] == 0){
		fprintf(file,"666\te-%lld.%x\tS\t\"%s.%s\"\t%lld.%x\n", ev.id1, ev.v_uint32[0], *(char **)class_name, ev.v_string[0], ev.id1, ev.v_uint32[1]);
	}else{
		fprintf(file,"6666\te-%lld.%x\tS\t\"%s.%s\"\t%lld.%x\t\"F=", ev.id1, ev.v_uint32[0], *(char **)class_name, ev.v_string[0], ev.id1, ev.v_uint32[1]);
		jrst_access_flags(file, ev.v_uint32[2]);
		fprintf(file,"\"\n");
	}
	
	hash_insert(&h_method, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1), (hash_data_t)(ev.v_uint32[1]+(int)ev.id1));
}			

void jrst_event_method_entry_alloc()
{
	fprintf(file,"111\t%.6f\tS\tt-%lld\te-%lld.%x\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000),ev.id2, ev.id1, ev.v_uint32[1], ev.id1, ev.v_uint32[0]);
	fprintf(file,"14\t%.6f\tMEM\tj-%lld\t%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, ev.v_uint64[0]);
	hash_insert(&h_mem, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1), (hash_data_t)((long)ev.v_uint64[0]));
}			

void jrst_jvmti_event_method_entry()
{
	fprintf(file,"111\t%.6f\tS\tt-%lld\te-%lld.%x\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000),ev.id2, ev.id1, ev.v_uint32[1], ev.id1, ev.v_uint32[0]);
}

void jrst_method_entry()
{
	class_number = hash_locate(&h_method, (hash_key_t)(ev.v_uint32[0]+(int)ev.id1));
	if(class_number == NULL){
		printf("metodo nao achado seila=[%d]\n",ev.v_uint32[0]);
		printf("ERROR: Cannot Method Class\n");
		exit(2);
	}
	fprintf(file,"111\t%.6f\tS\tt-%lld\te-%lld.%x\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000),ev.id2, ev.id1, ev.v_uint32[0], ev.id1, (*((int*)class_number)-(int)ev.id1));
}

void jrst_jvmti_event_method_exit()
{
	fprintf(file,"12\t%.6f\tS\tt-%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id2);
}

void jrst_method_exception()
{
	fprintf(file,"9999\t%.6f\tEX\tt-%lld\tex\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2, ev.id1, ev.v_uint32[0]);
}		

void jrst_method_exit_exception()
{
	fprintf(file,"12\t%.6f\tS\tt-%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id2);
	fprintf(file,"9\t%.6f\tEX\tt-%lld\texpop\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2);
}		

void jrst_jvmti_event_vm_object_alloc()
{
	fprintf(file,"14\t%.6f\tMEM\tj-%lld\t%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, ev.v_uint64[0]);
	hash_insert(&h_mem, (hash_key_t)(ev.v_uint32[0] + (int)ev.id1), (hash_data_t)((long)ev.v_uint64[0]));
}

void jrst_jvmti_event_object_free()
{
	data_mem = hash_locate(&h_mem, (hash_key_t)(ev.v_uint32[0] + (int)ev.id1));
	if(data_mem == NULL){
		printf("ERROR: Cannot JVMTI_EVENT_OBJECT_FREE \n");
		printf("\tObjeto=[%x] nao achado para liberar\n",ev.v_uint32[0]);
		return;
		//continue;
		//exit(2);
	}
	fprintf(file,"15\t%.6f\tMEM\tj-%lld\t%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1, (long long)*(long*)data_mem);
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
	list_object_t obj;
	obj.jvm = ev.id1;
	obj.idObject = ev.v_uint32[0];
	if(!list_find(&monitores, (void *)&obj)){
		list_insert_after(&monitores, NULL, (void *)&obj);
		fprintf(file,"7\t%.6f\to-%lld.%x\tM\tj-%lld\t\"Monitor-%lld.%x\"\n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, ev.id1, ev.v_uint32[0]);
		
	}
	//fprintf(file,"9\t%.6f\tE\tt-%lld\tme\n",(((double)(ev.timestamp - first)) / 1000000), ev.v_uint64[0]);
	fprintf(file,"999\t%.6f\tE\tt-%lld\tme\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2, ev.id1, ev.v_uint32[0]);
	fprintf(file,"11\t%.6f\tS\tt-%lld\tlock\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2);
	fprintf(file,"11\t%.6f\tMS\to-%lld.%x\tlock\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
	
	fprintf(file,"18\t%.6f\tLTM\tj-%lld\tlb\tt-%lld\tl-%lld-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id2, ev.id2, ev.id1, ev.v_uint32[0]);
	fprintf(file,"19\t%.6f\tLTM\tj-%lld\tlb\to-%lld.%x\tl-%lld-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id1, ev.v_uint32[0], ev.id2, ev.id1, ev.v_uint32[0]);
}		

void jrst_event_monitor_entered()
{
	fprintf(file,"999\t%.6f\tE\tt-%lld\tmed\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2, ev.id1, ev.v_uint32[0]);
	fprintf(file,"12\t%.6f\tS\tt-%lld\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2);
	fprintf(file,"12\t%.6f\tMS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
	
	fprintf(file,"18\t%.6f\tLMT\tj-%lld\tlub\to-%lld.%x\tlu-%lld.%x-%lld\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id1, ev.v_uint32[0], ev.id1, ev.v_uint32[0], ev.id2);
	fprintf(file,"19\t%.6f\tLMT\tj-%lld\tlub\tt-%lld\tlu-%lld.%x-%lld\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id2, ev.id1, ev.v_uint32[0], ev.id2);
}	

void jrst_event_monitor_wait()
{
	//if(!list_find(&monitores, (void *)&ev.v_uint32[0])){
	//	list_insert_after(&monitores, NULL, (void *)&ev.v_uint32[0]);
	//	fprintf(file,"7\t%.6f\to-%lld.%x\tM\tj-%lld\t\"Monitor-%lld.%x\"\n",(((double)(ev.timestamp - first))/ 1000000.0), ev.id1, ev.v_uint32[0], ev.id1, ev.id1, ev.v_uint32[0]);
	//}
	//fprintf(file,"9\t%.6f\tE\tt-%lld\tme\n",(((double)(ev.timestamp - first)) / 1000000), ev.v_uint64[0]);
	fprintf(file,"999\t%.6f\tE\tt-%lld\tmw\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2, ev.id1, ev.v_uint32[0]);
	fprintf(file,"11\t%.6f\tS\tt-%lld\tlock\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2);
	//fprintf(file,"11\t%.6f\tMS\to-%lld.%x\tlock\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
	
	//fprintf(file,"18\t%.6f\tLTM\tj-%lld\tlb\tt-%lld\tl-%lld-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id2, ev.id2, ev.id1, ev.v_uint32[0]);
	//fprintf(file,"19\t%.6f\tLTM\tj-%lld\tlb\to-%lld.%x\tl-%lld-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id1, ev.v_uint32[0], ev.id2, ev.id1, ev.v_uint32[0]);
}

void jrst_event_monitor_waited()
{
	fprintf(file,"999\t%.6f\tE\tt-%lld\tmwd\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2, ev.id1, ev.v_uint32[0]);
	fprintf(file,"12\t%.6f\tS\tt-%lld\n",(((double)(ev.timestamp - first)) / 1000000), ev.id2);
	//fprintf(file,"12\t%.6f\tMS\to-%lld.%x\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.v_uint32[0]);
	
	//fprintf(file,"18\t%.6f\tLMT\tj-%lld\tlub\to-%lld.%x\tlu-%lld.%x-%lld\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id1, ev.v_uint32[0], ev.id1, ev.v_uint32[0], ev.id2);
	//fprintf(file,"19\t%.6f\tLMT\tj-%lld\tlub\tt-%lld\tlu-%lld.%x-%lld\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1, ev.id2, ev.id1, ev.v_uint32[0], ev.id2);
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
		
	}else if(ev.type == METHOD_ENTRY){
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
	file=fopen("rastros.trace","w");
	
	paje_header(file);

	jrst_constant(file);

	list_initialize(&monitores, list_copy_object, list_cmp_object, list_destroy_int);

	hash_initialize(&h_class, hash_value, hash_copy, hash_key_cmp, hash_destroy);
	hash_initialize(&h_method, hash_value, hash_copy_new, hash_key_cmp, hash_destroy_new);
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
	for(pos = list_inicio(&monitores); pos != NULL ; pos = list_inicio(&monitores)){
		list_object_t *obj;
		
		obj = (list_object_t *) pos->data;
		
		fprintf(file,"8\t%.6f\to-%lld.%x\tM\n",(((double)(ev.timestamp - first)) / 1000000), (long long)obj->jvm, obj->idObject);
		list_rem_position (&monitores, pos);		
	}
	list_finalize(&monitores);
	
	fprintf(file,"12\t%.6f\tJS\tj-%lld\n",(((double)(ev.timestamp - first)) / 1000000),ev.id1);
	fprintf(file,"8\t%.6f\tj-%lld\tJVM\n",(((double)(ev.timestamp - first)) / 1000000), ev.id1);
	fprintf(file,"8\t%.6f\tpj\tPJ\n",(((double)(ev.timestamp - first)) / 1000000));
	
	hash_finalize(&h_class);
	hash_finalize(&h_method);
	hash_finalize(&h_mem);
	fclose(file);
	return 0;
}

