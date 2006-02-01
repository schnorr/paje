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


#ifndef _HASH_H_
#define _HASH_H_

#define MAX_HASH 100

typedef void* hash_data_t;

typedef void* hash_key_t;

typedef struct hash_element_t_{
	hash_key_t key;
	hash_data_t data;
	struct hash_element_t_ *next;
}hash_element_t;	

typedef int(*hash_func_t)(hash_key_t);
typedef void(*hash_func_copy_t)(hash_element_t*, hash_key_t, hash_data_t);
typedef bool(*hash_func_compare_t)(hash_key_t, hash_key_t);
typedef void(*hash_func_destroy_t)(hash_element_t*);

typedef struct {
	hash_element_t hash[MAX_HASH];
	hash_func_t hash_func;
	hash_func_copy_t hash_copy;
	hash_func_compare_t hash_compare;
	hash_func_destroy_t hash_destroy;
}hash_t;

int hash_value(hash_key_t key);
int hash_value_string(hash_key_t key);
int hash_value_int(hash_key_t key);
void hash_null(void *p);
void hash_initialize(hash_t *h, hash_func_t func, hash_func_copy_t copy, hash_func_compare_t compare, hash_func_destroy_t destroy);
void hash_finalize(hash_t *h);
void hash_destroy(hash_element_t *element);
void hash_destroy_string(hash_element_t *element);
void hash_destroy_int(hash_element_t *element);
bool hash_key_cmp(hash_key_t key, hash_key_t key2);
bool hash_key_cmp_string(hash_key_t key, hash_key_t key2);
bool hash_key_cmp_int(hash_key_t key, hash_key_t key2);
void hash_copy (hash_element_t *element, hash_key_t key, hash_data_t data);
void hash_copy_string (hash_element_t *element, hash_key_t key, hash_data_t data);
void hash_copy_int (hash_element_t *element, hash_key_t key, hash_data_t data);
hash_data_t *hash_locate(hash_t *h, hash_key_t key);
bool hash_find(hash_t *h, hash_key_t key);
void hash_insert(hash_t *h, hash_key_t key, hash_data_t data);
void hash_remove(hash_t *h, hash_key_t key);


#endif		/*_HASH_H_*/
