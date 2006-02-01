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


void jrst_enable_all(jvmtiEnv *jvmtiLocate)
{
	jvmtiError error;

	/*Method && Exception*/
	methodsTrace = true;

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_EXCEPTION, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_EXCEPTION>");

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_FRAME_POP, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_FRAME_POP>");


	/*MemoryAllocation*/
	memoryTrace  = true;

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_OBJECT_FREE, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_OBJECT_FREE>");

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_GARBAGE_COLLECTION_START, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_GARBAGE_COLLECTION_START>");

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_GARBAGE_COLLECTION_FINISH, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_GARBAGE_COLLECTION_FINISH>");

	/*Monitor*/
	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_CONTENDED_ENTER, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_CONTENDED_ENTER>");

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_CONTENDED_ENTERED, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_CONTENDED_ENTERED>");

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_WAIT, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_WAIT>");

	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_WAITED, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_WAITED>");
	
}

void jrst_threads(jvmtiEnv *jvmtiLocate)
{
	jvmtiError error;
	
	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_THREAD_START, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_THREAD_START>");
	
	error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_THREAD_END, (jthread)NULL);
	jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_THREAD_END>");

}

void jrst_read_events_enable(jvmtiEnv *jvmtiLocate)
{
	FILE *file;
	jvmtiError error;
	char line[MAX_LINE_EVENTS];
	char buffer[MAX_LINE_EVENTS];
	int i, j;

	if(eventsOptionName[0] == '\0'){
		return;
	}
	file=fopen(eventsOptionName, "r");
	if(file == NULL){
		printf("\nCannot open the file\n");
		exit(2);
	}

	bzero(buffer, MAX_LINE_EVENTS);
	bzero(line, MAX_LINE_EVENTS);
	fgets(line, MAX_LINE_EVENTS, file);
	while(!feof(file)){
		line[strlen(line) - 1]='\0';
	
		for(i=0; line[i] == ' ' || line[i] == '\t'; i++);
		if(line[i] != '\0' && line[i] != '#'){
			for(j=0 ; line[i] != '\0' && line[i] != ' ' && line[i] != '\t'; i++, j++){
				buffer[j]=line[i];
			}
			buffer[j]='\0';
				
			if(!strcmp(buffer,"all")){
				printf("[JRastro] Enable All Traces\n");
				jrst_enable_all(jvmtiLocate);
				fclose(file);
				return;
				
			}else if(!strcmp(buffer,"NoTraces")){
				printf("[JRastro] No Enable Traces\n");
				traces=false;
				fclose(file);
				return;
				
			}else if(!strcmp(buffer,"Method")){
				methodsTrace = true;
			/*Comentei para ficar apenas o Method*/	
			//}else if(!strcmp(buffer,"Exception")){
			//	methodsTrace = true;
				
				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_EXCEPTION, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_EXCEPTION>");

//				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_EXCEPTION_CATCH, (jthread)NULL);
//				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_EXCEPTION_CATCH>");

				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_FRAME_POP, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_FRAME_POP>");
			
			}else if(!strcmp(buffer,"MemoryAllocation")){
				memoryTrace  = true;

				/*error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_VM_OBJECT_ALLOC, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_VM_OBJECT_ALLOC>");*/

				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_OBJECT_FREE, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_OBJECT_FREE>");
				
				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_GARBAGE_COLLECTION_START, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_GARBAGE_COLLECTION_START>");
				
				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_GARBAGE_COLLECTION_FINISH, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_GARBAGE_COLLECTION_FINISH>");
				
			}else if(!strcmp(buffer,"Monitor")){
				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_CONTENDED_ENTER, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_CONTENDED_ENTER>");
					
				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_CONTENDED_ENTERED, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_CONTENDED_ENTERED>");
		
				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_WAIT, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_WAIT>");

				error=(*jvmtiLocate)->SetEventNotificationMode(jvmtiLocate, JVMTI_ENABLE, JVMTI_EVENT_MONITOR_WAITED, (jthread)NULL);
				jrst_check_error(jvmtiLocate, error, "Cannot set event notification <JVMTI_EVENT_MONITOR_WAITED>");
				
			}
		
		}
	
		bzero(line, MAX_LINE_EVENTS);
		bzero(buffer, MAX_LINE_EVENTS);
		fgets(line, MAX_LINE_EVENTS, file);

	}
	fclose(file);
}

void jrst_read_class_methods_enable()
{
	FILE *file;
	char line[MAX_LINE];
	char class[MAX_LINE];
	char method[MAX_LINE];
	char type;
	int i = 0, j = 0;
	list_t *new_list = NULL;
	bool all = true;
	
	if(methodsOptionName[0] == '\0'){
		return;
	}
	
	file=fopen(methodsOptionName, "r");
	if(file == NULL){
		printf("\nCannot open the file\n");
		exit(2);
	}
	strcpy(class, "*");
	strcpy(method, "*");
	bzero(line, MAX_LINE);
	fgets(line, MAX_LINE, file);
	while(!feof(file)){
		line[strlen(line) - 1]='\0';
		
		for(i=0; line[i] == ' ' || line[i] == '\t'; i++);
		while(line[i] != '\0' && line[i] != '#'){
			type = line[i];
			i++;
			if(type == 'C' || type == 'c'){
				if(new_list != NULL){
					hash_insert(&h_options, (hash_key_t)class, (hash_data_t)new_list);
				}
				all = false;
				new_list = NULL;
				new_list = (list_t *) malloc(sizeof(list_t));
				if(new_list == NULL){
					printf("[JRastro ERROR]: Cannot malloc list\n");
					exit(3);
				}
				list_initialize(new_list, list_copy_string, list_cmp_string, list_destroy_string);
				bzero(class, MAX_LINE);
				for(; line[i] == ' ' || line[i] == '\t'; i++);
				for(j=0 ; line[i] != '\0' && line[i] != ' ' && line[i] != '\t'; i++, j++){
					class[j]=line[i];
				}
				class[j]='\0';
				if(strcmp(class, "*") == 0){
					all = true;
				}
				for(; line[i] == ' ' || line[i] == '\t'; i++);
			}else if(type == 'M' || type == 'm'){
				bzero(method, MAX_LINE);
				for(; line[i] == ' ' || line[i] == '\t'; i++);
				for(j=0 ; line[i] != '\0' && line[i] != ' ' && line[i] != '\t'; i++, j++){
					method[j]=line[i];
				}
				method[j]='\0';
				if(all){
					if(strcmp(method, "*") == 0){
						printf("[JRastro] Enable All Classes and Methods\n");
						tracesAll=true;
						fclose(file);
						return;
					}
				}
				if(new_list == NULL){
					new_list = (list_t *) malloc(sizeof(list_t));
					if(new_list == NULL){
						printf("[JRastro ERROR]: Cannot malloc list\n");
						exit(3);
					}
					list_initialize(new_list, list_copy_string, list_cmp_string, list_destroy_string);
				}
				list_insert_after(new_list, NULL, (list_data_t)method);
				for(; line[i] == ' ' || line[i] == '\t'; i++);
			}else{
				printf("\n[JRastro ERROR]:Type desconhecido\n");
				exit(2);	  
			
			}
		}
		bzero(line, MAX_LINE);
		fgets(line, MAX_LINE, file);
	}
	if(new_list != NULL){
		hash_insert(&h_options, (hash_key_t)class, (hash_data_t)new_list);
	}
	
	fclose(file);
}

/*funcao que le as opcoes recebidas pela funcao "Agent_OnLoad"*/
void jrst_read_names_options(char *options)
{
	int count=0, count2=0;
	
	if(options == NULL){
		eventsOptionName[0] = '\0';
		methodsOptionName[0] = '\0';
		return;
	}
	
	bzero(eventsOptionName, MAX_NAME_OPTIONS);
	bzero(methodsOptionName, MAX_NAME_OPTIONS);
	for(count=0;options[count] != ',' && options[count] != '\0';count++){
		eventsOptionName[count]=options[count];
	}
	eventsOptionName[count]='\0';
	
	if(options[count] != '\0'){
		count++;
		for(count2 = 0; options[count] != '\0';count++,count2++){
			methodsOptionName[count2]=options[count];
		}
		methodsOptionName[count2]='\0';
	}else{
		methodsOptionName[0]='\0';
	}
}
