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



#ifndef _JRASTRO_PAJE_H_
#define _JRASTRO_PAJE_H_

void paje_set_limits(FILE *file);
void paje_define_container_type(FILE *file);
void paje_define_event_type(FILE *file);
void paje_define_state_type(FILE *file);
void paje_define_variable_type(FILE *file);
void paje_define_link_type(FILE *file);
void paje_define_entity_value(FILE *file);
void paje_define_entity_value666(FILE *file);
void paje_create_container(FILE *file);
void paje_create_container777(FILE *file);
void paje_destroy_container(FILE *file);
void paje_new_event(FILE *file);
void paje_set_state(FILE *file);
void paje_push_state(FILE *file);
void paje_push_state111(FILE *file);
void paje_pop_state(FILE *file);
void paje_set_variable(FILE *file);
void paje_add_variable(FILE *file);
void paje_sub_variable(FILE *file);
void paje_start_link(FILE *file);
void paje_end_link(FILE *file);
void paje_start_link18(FILE *file);
void paje_end_link19(FILE *file);
void paje_new_event112(FILE *file);
void paje_new_event113(FILE *file);
void paje_new_event114(FILE *file);

void paje_header(FILE *file);


#endif	/*_JRASTRO_PAJE_H_*/
