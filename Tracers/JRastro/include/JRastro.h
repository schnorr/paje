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


#ifndef _JRASTRO_H_
#define _JRASTRO_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jvmti.h>
#include <jni.h>
#include <stdbool.h>

#include "hash.h"
#include "list.h"
#include "JRastro_rastros.h"
#include "JRastro_basic.h"
#include "JRastro_traces.h"
#include "JRastro_events.h"
#include "JRastro_thread.h"
#include "JRastro_hash_func.h"
#include "JRastro_list_func.h"
#include "JRastro_options.h"
#include "JRastro_paje.h"
#include "JRastro_java_crw_demo.h"
#include "JRastro_classfile_constants.h"


#define CLASS_NAME "org/lsc/JRastro/Instru"
#define CLASS_SIG "Lorg/lsc/JRastro/Instru;"
//#define CLASS_NAME "sun/tools/hprof/Tracker"
//#define CLASS_SIG "Lsun/tools/hprof/Tracker;"

#define CALL_NAME "CallSite"
#define CALL_SIG "(Ljava/lang/Object;I)V"

#define CALL_STATIC_NAME "CallStaticSite"
#define CALL_STATIC_SIG "(I)V"

#define RETURN_NAME "ReturnSite"
#define RETURN_SIG "()V"
//#define RETURN_SIG "(I)V"

#define RETURN_MAIN_NAME "ReturnSite"
//#define RETURN_MAIN_NAME "ReturnMain"
#define RETURN_MAIN_SIG "()V"
//#define RETURN_MAIN_SIG "(I)V"

/*Caso necessite rastrear OBJECT_INIT comente o NULL, e *
*          coloque as outras linhas                     */
//#define OBJECT_INIT_NAME NULL
//#define OBJECT_INIT_SIG NULL
#define OBJECT_INIT_NAME "ObjectInit"
#define OBJECT_INIT_SIG "(Ljava/lang/Object;)V"

/*Caso necessite rastrear NEWARRAY comente o NULL, e *
*          coloque as outras linhas                     */
//#define NEWARRAY_NAME NULL
//#define NEWARRAY_SIG NULL
#define NEWARRAY_NAME "NewArray"
#define NEWARRAY_SIG "(Ljava/lang/Object;)V"

#endif	/*_JRASTRO_H_*/
