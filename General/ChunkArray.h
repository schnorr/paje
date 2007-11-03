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
#ifndef _ChunkArray_h_
#define _ChunkArray_h_

//
// ChunkArray
//
// contains an array of EntityChunks, sorted by time
// can enumerate entities that lay in a time interval
//
// Author: Edmar Pessoa Araújo Neto
//


#include "PSortedArray.h"
#include "EntityChunk.h"


@interface ChunkArray : NSObject
{
    PSortedArray *chunks;
    int firstIndex;
}

- (id)init;

- (void)dealloc;

// enumerate all entities that end after startTime and start before endTime,
// in reverse endTime order.
- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)startTime
                                        toTime:(NSDate *)endTime;
// enumerate all entities that end after startTime and not after endTime,
// in increasing endTime order.
- (NSEnumerator *)enumeratorOfCompleteEntitiesFromTime:(NSDate *)startTime
                                             untilTime:(NSDate *)endTime;

- (void)addChunk:(EntityChunk *)chunk;

- (EntityChunk *)chunkAtIndex:(int)index;
- (void)setFirstIndex:(int)index;
@end
#endif
