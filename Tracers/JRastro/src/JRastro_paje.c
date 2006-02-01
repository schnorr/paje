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

void paje_set_limits(FILE *file)
{
	fprintf(file,"%%EventDef\tSetLimits\t0\n"
		     "%%\tStartTime\tdate\n"
		     "%%\tEndTime\tdate\n"
		     "%%EndEventDef\n");
}

void paje_define_container_type(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineContainerType 1\n"
		     "%%\tAlias\tstring\n"
		     "%%\tContainerType\tstring\n"
		     "%%\tName\tstring\n"
		     "%%EndEventDef\n");
}

void paje_define_event_type(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineEventType     2\n"
		     "%%\tAlias\tstring\n"
		     "%%\tContainerType\tstring\n"
		     "%%\tName\tstring\n"
		     "%%EndEventDef\n");
}

void paje_define_state_type(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineStateType     3\n"
		     "%%\tAlias\tstring\n"
		     "%%\tContainerType\tstring\n"
		     "%%\tName\tstring\n"
		     "%%EndEventDef\n");
}

void paje_define_variable_type(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineVariableType  4\n"
		     "%%\tAlias\tstring\n"
		     "%%\tContainerType\tstring\n"
		     "%%\tName\tstring\n"
		     "%%EndEventDef\n");
}

void paje_define_link_type(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineLinkType      5\n"
		     "%%\tAlias\tstring\n"
		     "%%\tContainerType\tstring\n"
		     "%%\tSourceContainerType\tstring\n"
		     "%%\tDestContainerType\tstring\n"
		     "%%\tName\tstring\n"
		     "%%EndEventDef\n");
}

void paje_define_entity_value(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineEntityValue   6\n"
		     "%%\tAlias\tstring\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tName\tstring\n"
		     //"%%\tColor\tcolor\n"
		     "%%EndEventDef\n");
}

void paje_define_entity_value666(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineEntityValue   666\n"
		     "%%\tAlias\tstring\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tName\tstring\n"
		     //"%%\tColor\tcolor\n"
		     "%%\tClass\tstring\n"
		     "%%EndEventDef\n");
}

void paje_define_entity_value6666(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDefineEntityValue   6666\n"
		     "%%\tAlias\tstring\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tName\tstring\n"
		     //"%%\tColor\tcolor\n"
		     "%%\tClass\tstring\n"
		     "%%\tFlags\tstring\n"
		     "%%EndEventDef\n");
}

void paje_create_container(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeCreateContainer     7\n"
		     "%%\tTime\tdate\n"
		     "%%\tAlias\tstring\n"
		     "%%\tType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tName\tstring\n"
		     "%%EndEventDef\n");
}

void paje_create_container777(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeCreateContainer     777\n"
		     "%%\tTime\tdate\n"
		     "%%\tAlias\tstring\n"
		     "%%\tType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tName\tstring\n"
		     "%%\tPriority\tstring\n"
		     "%%\tIsDaemon\tstring\n"
		     "%%\tThreadGroup\tstring\n"
		     "%%EndEventDef\n");
}

void paje_destroy_container(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeDestroyContainer    8\n"
		     "%%\tTime\tdate\n"
		     "%%\tContainer\tstring\n"
		     "%%\tType\tstring\n"
		     "%%EndEventDef\n");
}

void paje_new_event(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeNewEvent    9\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%EndEventDef\n");
}

void paje_new_event999(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeNewEvent    999\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tMonitor\tstring\n"
		     "%%EndEventDef\n");
}

void paje_new_event9999(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeNewEvent    9999\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tException\tstring\n"
		     "%%EndEventDef\n");
}

void paje_set_state(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeSetState    10\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%EndEventDef\n");
}

void paje_push_state(FILE *file)
{
	fprintf(file,"%%EventDef\tPajePushState   11\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%EndEventDef\n");
}

void paje_push_state111(FILE *file)
{
	fprintf(file,"%%EventDef\tPajePushState   111\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tObject\tstring\n"
		     "%%EndEventDef\n");
}

void paje_pop_state(FILE *file)
{
	fprintf(file,"%%EventDef\tPajePopState    12\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%EndEventDef\n");
}

void paje_set_variable(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeSetVariable 13\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tdouble\n"
		     "%%EndEventDef\n");
}

void paje_add_variable(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeAddVariable 14\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tdouble\n"
		     "%%EndEventDef\n");
}

void paje_sub_variable(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeSubVariable 15\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tdouble\n"
		     "%%EndEventDef\n");
}

void paje_start_link(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeStartLink   16\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tSourceContainer\tstring\n"
		     "%%\tKey\tstring\n"
		     "%%\tSize\tint\n"
		     "%%EndEventDef\n");
}

void paje_end_link(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeEndLink     17\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tDestContainer\tstring\n"
		     "%%\tKey\tstring\n"
		     "%%\tSize\tint\n"
		     "%%EndEventDef\n");
}

void paje_start_link18(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeStartLink   18\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tSourceContainer\tstring\n"
		     "%%\tKey\tstring\n"
		     "%%EndEventDef\n");
}

void paje_end_link19(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeEndLink     19\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tDestContainer\tstring\n"
		     "%%\tKey\tstring\n"
		     "%%EndEventDef\n");
}

void paje_new_event112(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeNewEvent   112\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tThreadName\tstring\n"
		     "%%\tThreadGroup\tstring\n"
		     "%%\tThreadParent\tstring\n"
		     "%%\tThreadId\tstring\n"
		     "%%EndEventDef\n");
}

void paje_new_event113(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeNewEvent   113\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tThreadName\tstring\n"
		     "%%\tThreadGroup\tstring\n"
		     "%%\tThreadId\tstring\n"
		     "%%EndEventDef\n");
}

void paje_new_event114(FILE *file)
{
	fprintf(file,"%%EventDef\tPajeNewEvent   114\n"
		     "%%\tTime\tdate\n"
		     "%%\tEntityType\tstring\n"
		     "%%\tContainer\tstring\n"
		     "%%\tValue\tstring\n"
		     "%%\tObject\tstring\n"
		     "%%EndEventDef\n");
}


void paje_header(FILE *file)
{
	/*paje_set_limits(file);*/
	paje_define_container_type(file);
	paje_define_event_type(file);
	paje_define_state_type(file);
	paje_define_variable_type(file);
	paje_define_link_type(file);
	paje_define_entity_value(file);
	paje_define_entity_value666(file);
	paje_define_entity_value6666(file);
	paje_create_container(file);
	paje_create_container777(file);
	paje_destroy_container(file);
	paje_new_event(file);
	paje_new_event999(file);
	paje_new_event9999(file);
	paje_set_state(file);
	paje_push_state(file);
	paje_push_state111(file);
	paje_pop_state(file);
	paje_set_variable(file);
	paje_add_variable(file);
	paje_sub_variable(file);
	paje_start_link(file);
	paje_end_link(file);
	paje_start_link18(file);
	paje_end_link19(file);
	paje_new_event112(file);
	paje_new_event113(file);
	paje_new_event114(file);
	

}
