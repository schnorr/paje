/*
    Copyright (c) 1998--2005 Benhur Stein
    
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
#ifndef _Encapsulate_h_
#define _Encapsulate_h_

//

#include "AnchorFilter.h"
#include "../General/Protocols.h"
#include "../General/ChunkArray.h"

@interface Encapsulate : AnchorFilter <PajeStorageController>
{
    BOOL                 traceChanged;
    BOOL                 timerActive;

    NSDate              *startTimeInMemory;
    NSDate              *endTimeInMemory;

    NSMutableDictionary *entityLists;   // dictionary (by entity type) of
                                        // dictionaries (by container) of
                                        // ChunkArrays
}

- (id)initWithController:(PajeTraceController *)c;

- (void)addChunk:(EntityChunk *)entity;

- (void)removeObjectsBeforeTime:(NSDate *)time;
- (void)removeObjectsAfterTime:(NSDate *)time;
- (NSDate *)startTimeInMemory;

@end

#endif
