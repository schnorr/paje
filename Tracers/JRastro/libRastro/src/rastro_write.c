/*
    Copyright (c) 1998--2006 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/



//#include "rastro_public.h"
//#include "rastro_private.h"
#include "rastro_write_functions.h"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/time.h>
#include <errno.h>
#include <sys/param.h>  /* for MAXHOSTNAMELEN */
#include "list.h"

list_t list;
bool list_init=false;

#ifndef THREADED
rst_buffer_t *rst_global_buffer;
#else
int rst_key_initialized = 0;
pthread_key_t rst_key;
#endif

int rst_debug_mask = 0;
char rst_dirname[FILENAME_MAX];

void rst_destroy_buffer(void *p)
{
    rst_buffer_t *ptr = (rst_buffer_t *) p;
    
    if (ptr != NULL) {
    	int fd;
        rst_event_ptr(ptr, RST_EVENT_STOP);
        rst_flush(ptr);
        free(ptr->rst_buffer);
	fd = RST_FD(ptr);
        close(fd);
        //free(ptr);
    }
}


// Extrai argumentos para a biblioteca
void extract_arguments(int *argcp, char ***argvp)
{
    char **argv;
    int argc;
    int arg, used, unused;
    char **p1, **p2, **plast;
    char *cepar;

    argv = *argvp;
    argc = *argcp;
    
    arg = used = unused = 1;
    bzero(rst_dirname, sizeof rst_dirname);
    while (arg < argc) {
        if ( strncmp(argv[arg], "-rst-", 5) == 0 ) {
            cepar = argv[arg] + 5;
            if ( !strcmp(cepar, "dir") ) {
                strcpy(rst_dirname, argv[++arg]);
                if (opendir(rst_dirname) == NULL ) {
                    printf("Diretorio invalido\n");
                    exit(0);
                }
                if ( (rst_dirname[strlen(rst_dirname) - 1] != '/') )
                    rst_dirname[strlen(rst_dirname)] = '/';
            }
            if ( !strcmp(cepar, "dm") ) {
                rst_debug_mask = atoi(argv[++arg]);
            }
            unused = ++arg;
        }
        else {
            if (unused > used ) {
                p1 = argv + used;
                p2 = argv + unused;
                plast = argv + argc;
                argc -= (unused - used);
                while ( p2 < plast )
                    *p1++ = *p2++;
                unused = used;
            }
            arg = ++used;
        }
    }
    if ( unused > used)
        argc = used;
    *argcp = argc;
    argv[argc] = NULL;
}

// Inicializa biblioteca em um nodo
void rst_initialize(u_int64_t id1, u_int64_t id2, int *argc, char ***argv)
{
    if ( argv != NULL ) 
        extract_arguments(argc, argv); 
    
    rst_init(id1, id2);
}

// Inicializa a biblioteca em uma thread
void rst_init(u_int64_t id1, u_int64_t id2)
{
    rst_buffer_t *ptr;
    ptr = (rst_buffer_t *) malloc(sizeof(rst_buffer_t));
    
    rst_init_ptr(ptr, id1, id2);
}


// Inicializacao com buffer pre-alocado
void rst_init_ptr(rst_buffer_t *ptr, u_int64_t id1, u_int64_t id2)
{
    int fd;
    char fname[30];
    char hostname[MAXHOSTNAMELEN+1];
       
    if ( ptr == NULL ) {
        fprintf(stderr, "[rastro] error inicializing - invalid pointer\n");
        return;
    }
    
#ifdef THREADED
    if (!rst_key_initialized) {
        pthread_key_create(&rst_key, rst_destroy_buffer);
        rst_key_initialized = 1;
    }
#endif
    
    if(!list_init){
    	list_initialize(&list, list_copy, list_cmp, list_destroy);
	list_init=true;
    }
    
    RST_SET_PTR(ptr);
    ptr->rst_buffer_size = 100000;
    ptr->rst_buffer = malloc(ptr->rst_buffer_size);
    RST_RESET(ptr);
    
    sprintf(fname, "rastro-%"PRIu64"-%"PRIu64".rst",/* dirname,*/ id1, id2);
    fd = open(fname, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (fd == -1) {
        fprintf(stderr, "[rastro] cannot open file %s: %s\n", 
                        fname, strerror(errno));
        return;
    }
    
    list_insert_after(&list, NULL, (void *)ptr );
    
    RST_SET_FD(ptr, fd);
    
    // this will force first event to register sync time
    RST_SET_T0(ptr, 0);

    gethostname(hostname, sizeof(hostname));
    
    XCAT(rst_event_,LETRA_UINT64,LETRA_STRING,_ptr)(ptr, RST_EVENT_INIT, id1, id2, hostname);
}

// Grava buffer no arquivo de traco
void rst_flush(rst_buffer_t * ptr)
{
    size_t nbytes;
    size_t n;

    nbytes = RST_BUF_COUNT(ptr);
    n = write(RST_FD(ptr), RST_BUF_DATA(ptr), nbytes);
    if (n != nbytes) {
        fprintf(stderr, "[rastro] error writing rastro file\n");
    }
    RST_RESET(ptr);
}

// Termina biblioteca em nodo ou thread
void rst_finalize(void)
{
    rst_buffer_t *ptr = RST_PTR;

    list_remove(&list, (void *)ptr);

    rst_destroy_buffer(ptr);
    free(ptr);
}

// Termina biblioteca em nodo ou thread com ptr
void rst_finalize_ptr(rst_buffer_t *ptr)
{
    list_remove(&list, (void *)ptr);
    rst_destroy_buffer(ptr);
}

void rst_flush_all(void)
{
    position_t pos;
    rst_buffer_t *ptr;
    for(pos=list.sent->next; pos != list.sent; pos=pos->next ){
        
	ptr= (rst_buffer_t *)pos->data;
    	
	rst_flush(ptr);
    }
    //list_finalize(&list);
}

// Registra evento somente com tipo
void rst_event(u_int16_t type)
{
    rst_buffer_t *ptr = RST_PTR;

/*...2 para finalizar esse rastro que so tem o tipo...*/
    rst_startevent(ptr, type << 18 | 0x20000);
    rst_endevent(ptr);
}

// Registra evento somente com tipo com ptr
void rst_event_ptr(rst_buffer_t *ptr, u_int16_t type)
{
    if ( ptr == NULL ) {
       printf("[rastro] ptr invalido\n");
       return;
    }
/*...2 para finalizar esse rastro que so tem o tipo...*/
    rst_startevent(ptr, type << 18 | 0x20000);
    rst_endevent(ptr);
}

