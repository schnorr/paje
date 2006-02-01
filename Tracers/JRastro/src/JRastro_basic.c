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

/*Funcao que descreve nome do erro*/
void jrst_describe_error(jvmtiEnv *jvmtiLocate, jvmtiError error)
{
	char *describe;
	jvmtiError err;
	
	describe=NULL;
	err=(*jvmtiLocate)->GetErrorName(jvmtiLocate, error, &describe);
	if(err != JVMTI_ERROR_NONE){
		printf("\n[JRastro ERROR]: Cannot Get Error:(%d) Name\n",error);
		return;
	}	
	
	printf("\n[JRastro ERROR](%d): <%s>\n",error,(describe==NULL?"Unknown":describe));
	err=(*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)describe);
	if(err != JVMTI_ERROR_NONE){
		printf("\n[JRastro ERROR]: Cannot Deallocate\n");
		return;
	}
}

/*Funcao que verifica se exite erro no retorno da JVMTI*/
void jrst_check_error(jvmtiEnv *jvmtiLocate, jvmtiError error, const char *frase)
{
	if (error!= JVMTI_ERROR_NONE){
		jrst_describe_error(jvmtiLocate,error);
		if(frase != NULL){
			printf("\t%s\n",frase);
		}
		exit(1);
	}
}

/*Entra na regiao critica*/
void jrst_enter_critical_section(jvmtiEnv *jvmtiLocate, jrawMonitorID monitor)
{
	jvmtiError error;
	error=(*jvmtiLocate)->RawMonitorEnter(jvmtiLocate, monitor);
	jrst_check_error(jvmtiLocate, error, "Cannot enter with raw monitor");
}

/*Sai da regiao critica*/
void jrst_exit_critical_section(jvmtiEnv *jvmtiLocate, jrawMonitorID monitor)
{
	jvmtiError error;
	error=(*jvmtiLocate)->RawMonitorExit(jvmtiLocate, monitor);
	jrst_check_error(jvmtiLocate, error, "Cannot exit with raw monitor");
}

/*Devolve o nome da Thread desejada*/
void jrst_get_thread_name(jvmtiEnv *jvmtiLocate, jthread thread, char *name, int numMax)
{
	jvmtiThreadInfo infoThread;
	jvmtiError error;

	(void)memset(&infoThread, 0, sizeof(infoThread));
	error=(*jvmtiLocate)->GetThreadInfo(jvmtiLocate, thread, &infoThread);
	jrst_check_error(jvmtiLocate, error, "Cannot get Thread Info");
	if(infoThread.name != NULL){
		int len;
		len = (int)strlen(infoThread.name);
		if(len < numMax){
			(void)strcpy(name, infoThread.name);
		}else {
			(void)strcpy(name,"Unknown");

		}
		error=(*jvmtiLocate)->Deallocate(jvmtiLocate, (unsigned char *)infoThread.name);
		jrst_check_error(jvmtiLocate, error,"Cannot deallocate memory");
		return;
	}
	(void)strcpy(name,"Unknown");
}

bool jrst_trace_class(char *className)
{
	if(tracesAll || hash_find(&h_options, "*") || hash_find(&h_options, className)){
		return true;
	}
	return false;
}

bool jrst_trace_methods()
{
	if(tracesAll){
		return true;
	}
	return false;
}

/*
bool jrst_trace(void *key)
{
	  printf("jrst_trace\n");
	if(hash_find(&h, key)){
		return true;
	}
	return false;
}
*/

