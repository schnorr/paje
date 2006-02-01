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



#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>

#include "hash.h"


/*Funcao que encontra o valor hash*/
int hash_value(hash_key_t key)
{
	return (((int)key / 24 ) % MAX_HASH);
}

/*Funcao que encontra o valor hash*/
int hash_value_string(hash_key_t key)
{
	int value = 0;
	char *tmp = (char *) key;
	while(*tmp){
		value += *tmp++;
	}
	return (value % MAX_HASH);
}

/*Funcao que encontra o valor hash*/
int hash_value_int(hash_key_t key)
{
	int *value;
	value = (int *) key;
	return ((*value / 24 ) % MAX_HASH);
}

/*Verifica se Ponteiro eh NULL*/
void hash_null (void *p)
{
	if(p == NULL){
		printf("HASH_ERROR: Pointer is NULL\n");
		exit(1);
	}
}	


void hash_initialize(hash_t *h, hash_func_t func, hash_func_copy_t copy, hash_func_compare_t compare, hash_func_destroy_t destroy)
{
	int i;

	hash_null(h);

	memset((void *)h, 0, sizeof(hash_t));
	h->hash_func=func;
	h->hash_copy=copy;
	h->hash_compare=compare;
	h->hash_destroy=destroy;

	for(i=0; i < MAX_HASH; i++){
		h->hash[i].key=NULL;
		h->hash[i].data=NULL;
		h->hash[i].next=NULL;
	}
}

void hash_finalize(hash_t *h)
{
	int i;

	hash_null(h);

	for(i=0; i < MAX_HASH; i++){
		if(h->hash[i].key != NULL){
			while(h->hash[i].next != NULL){
				hash_remove(h, h->hash[i].next->key);
			}
			hash_remove(h, h->hash[i].key);
		}
	}
}

void hash_destroy(hash_element_t *element)
{
	hash_null(element);
	
	element->key=NULL;
	
	free(element->data);
	element->data=NULL;
}

void hash_destroy_string(hash_element_t *element)
{
	hash_null(element);
	
	free(element->key);
	element->key=NULL;
	
	element->data=NULL;
}

void hash_destroy_int(hash_element_t *element)
{
	hash_null(element);
	
	free(element->key);
	element->key=NULL;
	
	free(element->data);
	element->data=NULL;
}

bool hash_key_cmp(hash_key_t key, hash_key_t key2)
{
	hash_null(key);
	hash_null(key2);
	
	if(key == key2){
		return true;
	}
	return false;
}

bool hash_key_cmp_string(hash_key_t key, hash_key_t key2)
{
	hash_null(key);
	hash_null(key2);
	
	if(!strcmp((char *)key, (char *)key2)){
		return true;
	}
	return false;
}

bool hash_key_cmp_int(hash_key_t key, hash_key_t key2)
{
	hash_null(key);
	hash_null(key2);
	
	if(!memcmp(key, key2, sizeof(int))){
		return true;
	}
	return false;
}

void hash_copy(hash_element_t *element, hash_key_t key, hash_data_t data)
{
	hash_null(element);
	hash_null(key);
	hash_null(data);
	
	element->key = (void *)key;
	
	element->data = (void *) malloc(sizeof(char) * (strlen((char *)data) + 1));
	element->data = memcpy(element->data, data, sizeof(char) * (strlen((char *)data) + 1));
}

void hash_copy_string (hash_element_t *element, hash_key_t key, hash_data_t data)
{
	hash_null(element);
	hash_null(key);
	hash_null(data);
	
	element->key = (void *) malloc(sizeof(char) * (strlen((char *)key) + 1));
	element->key = memcpy(element->key, key, sizeof(char) * (strlen((char *)key) + 1));

	element->data = (void *)data;
}

void hash_copy_int (hash_element_t *element, hash_key_t key, hash_data_t data)
{
	hash_null(element);
	hash_null(key);
	hash_null(data);
	
	element->key = (void *)malloc(sizeof(int));
	element->key = memcpy(element->key, key, sizeof(int));
	
	element->data = (void *) malloc(sizeof(char) * (strlen((char *)data) + 1));
	element->data = memcpy(element->data, data, sizeof(char) * (strlen((char *)data) + 1));
}

hash_data_t *hash_locate(hash_t *h, hash_key_t key)
{
	int locate;
	
	hash_null(h);
	hash_null(key);

	locate = h->hash_func(key); 
	
	if(h->hash[locate].key != NULL){
		if(h->hash_compare(h->hash[locate].key, key)){
			return &h->hash[locate].data;
		}else{
		
			hash_element_t *element;
			for(element = h->hash[locate].next; element != NULL; element = element->next){

				if(h->hash_compare(element->key, key)){
					return &element->data;
				}
			}
		}
	}
	return NULL;
}


bool hash_find(hash_t *h, hash_key_t key)
{
	hash_data_t *data;
	
	hash_null(h);
	hash_null(key);

	data = hash_locate(h, key);
	if(data != NULL){
		return true;
	}
	return false;
}


void hash_insert(hash_t *h, hash_key_t key, hash_data_t data)
{
	int locate;
	hash_element_t *new_element;
	
	hash_null(h);
	hash_null(key);
	hash_null(data);
	
	if(hash_find(h, key)){
		return;
	}
	
	locate = h->hash_func(key);
	
	if(h->hash[locate].key == NULL){
		h->hash_copy(&(h->hash[locate]), key, data);
		return;
	}else{
		new_element=(hash_element_t *)malloc(sizeof(hash_element_t));
		new_element->next=NULL;
		h->hash_copy(new_element, key, data);
		if(h->hash[locate].next == NULL){
			h->hash[locate].next = new_element;
			return;
		}
		hash_element_t *element;
		for(element = h->hash[locate].next; element->next != NULL; element=element->next);
		element->next = new_element;
		return;
	}
}		

	
void hash_remove(hash_t *h, hash_key_t key)
{
	int locate;
	hash_element_t *element;

	hash_null(h);
	hash_null(key);
	
	if(!hash_find(h, key)){
		printf("HASH_ERROR: Cannot remove Hash element\n");
		exit(1);
	}

	locate = h->hash_func(key);
	
	if(h->hash_compare(h->hash[locate].key, key)){
		h->hash_destroy(&h->hash[locate]);
		if(h->hash[locate].next == NULL){
			return;
		}
		for(element=h->hash[locate].next; element->next != NULL; element=element->next){
			if(element->next->next == NULL){
				h->hash_copy(&(h->hash[locate]), element->next->key, element->next->data);
				h->hash_destroy(element->next);
				
				free(element->next);
				element->next=NULL;
				return;
			}
		}
		h->hash_copy(&(h->hash[locate]), element->key, element->data);
		h->hash_destroy(element);
		free(element);
		element=NULL;
		h->hash[locate].next=NULL;
		return;
		
	}else{
		element=h->hash[locate].next;
		if(h->hash_compare(element->key, key)){
			h->hash[locate].next=element->next;
			h->hash_destroy(element);
			free(element);
			element=NULL;
			return;
		}	
		for(;element->next != NULL && (!h->hash_compare(element->next->key, key)); element = element->next);
		if(element->next == NULL){
			printf("HASH_ERROR: Cannot remove Hash element\n");
			exit(1);
		}
		hash_element_t *element2;
		element2 = element->next;
		element->next = element2->next;
		h->hash_destroy(element2);
		free(element2);
		element2=NULL;
		return;
	}
}

