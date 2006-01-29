/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
// EventNames.h
//
// declaration of event names.
// include this file with the following symbol #defined:
//     nothing - declaration of variables as extern
//     DEFINE_STRINGS - declaration of variables not extern
//     INIT_STRINGS - initialization of variables


#if defined(INIT_STRINGS)
#  define CONSTANT_STRING(str, init) str##EventName = (NSString*)[UniqueString stringWithString:init]
#else
#  if defined(DEFINE_STRINGS)
#    define CONSTANT_STRING(str, init) NSString *str##EventName
#  else // declare strings
#    define CONSTANT_STRING(str, init) extern NSString *str##EventName
#  endif
#endif

CONSTANT_STRING(PajeStartTrace,             @"PajeStartTrace");
CONSTANT_STRING(PajeDefineContainerType,    @"PajeDefineContainerType");
CONSTANT_STRING(PajeDefineEventType,        @"PajeDefineEventType");
CONSTANT_STRING(PajeDefineStateType,        @"PajeDefineStateType");
CONSTANT_STRING(PajeDefineVariableType,     @"PajeDefineVariableType");
CONSTANT_STRING(PajeDefineLinkType,         @"PajeDefineLinkType");
CONSTANT_STRING(PajeDefineEntityValue,      @"PajeDefineEntityValue");
CONSTANT_STRING(PajeCreateContainer,        @"PajeCreateContainer");
CONSTANT_STRING(PajeDestroyContainer,       @"PajeDestroyContainer");
CONSTANT_STRING(PajeNewEvent,               @"PajeNewEvent");
CONSTANT_STRING(PajeSetState,               @"PajeSetState");
CONSTANT_STRING(PajePushState,              @"PajePushState");
CONSTANT_STRING(PajePopState,               @"PajePopState");
CONSTANT_STRING(PajeSetVariable,            @"PajeSetVariable");
CONSTANT_STRING(PajeAddVariable,            @"PajeAddVariable");
CONSTANT_STRING(PajeSubVariable,            @"PajeSubVariable");
CONSTANT_STRING(PajeStartLink,              @"PajeStartLink");
CONSTANT_STRING(PajeEndLink,                @"PajeEndLink");
#undef CONSTANT_STRING
