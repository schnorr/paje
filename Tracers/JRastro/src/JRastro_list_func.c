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

void list_copy_object(list_element_t *element, list_data_t data)
{
    list_null(element);
    list_null(data);
     
    element->data = (void *)malloc(sizeof(list_object_t));
	((list_object_t*)element->data)->jvm = ((list_object_t*)data)->jvm;
	((list_object_t*)element->data)->idObject = ((list_object_t*)data)->idObject;
	//element->data = memcpy(element->data, data, sizeof(list_object_t));
}   

void list_copy_string_class(list_element_t *element, list_data_t data)
{
    list_null(element);
    list_null(data);

    element->data = (void *)malloc(sizeof(list_class_t));

	((list_class_t*)element->data)->className = (void *)malloc((sizeof(char) * strlen((char *)((list_class_t*)data)->className)) + 1);
	
	((list_class_t*)element->data)->jvm = ((list_class_t*)data)->jvm;

	((list_class_t*)element->data)->className = strcpy(((list_class_t*)element->data)->className, ((list_class_t*)data)->className);
	
}   
    
bool list_cmp_object(list_data_t data, list_data_t data2)
{
    list_null(data);
    list_null(data2);
    
    list_object_t *obj = (list_object_t*) data;
    list_object_t *obj2 = (list_object_t*) data2;


    if(obj->jvm == obj2->jvm && obj->idObject == obj2->idObject){
        return true;
    }
    return false;

}

bool list_cmp_string_class(list_data_t data, list_data_t data2)
{
    list_null(data);
    list_null(data2);
    
    list_class_t *obj = (list_class_t*) data;
    list_class_t *obj2 = (list_class_t*) data2;


    if(obj->jvm == obj2->jvm && strcmp(obj->className, obj2->className) == 0){
        return true;
    }
    return false;

}

void list_destroy_string_class(position_t pos)
{
    list_null(pos);
    
	list_class_t *obj = (list_class_t*) pos->data;
	
	free(obj->className);

    free(pos->data);
    pos->data=NULL;
    pos->next=NULL;
    pos->prev=NULL;
}

