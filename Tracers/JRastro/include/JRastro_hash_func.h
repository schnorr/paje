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



#ifndef _JRASTRO_HASH_FUNC_H_
#define _JRASTRO_HASH_FUNC_H_


void hash_copy_string_data (hash_element_t *element, hash_key_t key, hash_data_t data);
void hash_destroy_string_data(hash_element_t *element);
void hash_destroy_string_list(hash_element_t *element);
void hash_destroy_new(hash_element_t *element);
void hash_copy_new(hash_element_t *element, hash_key_t key, hash_data_t data);
void hash_destroy_new_thread(hash_element_t *element);

#endif	/*_JRASTRO_HASH_FUNC_H_*/
