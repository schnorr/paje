/*
    Copyright (c) 2006 Benhur Stein
    
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
#ifndef _EntityChunk_h_ 
#define _EntityChunk_h_ 

//
// EntityChunk
//
// contains entities of a type in a container in a slice of time
// (this is an abstract class, concrete subclasses are in PajeSimulator)
//
// Author: Edmar Pessoa Araújo Neto
//

#include <Foundation/Foundation.h>

#include "PajeEntity.h"
#include "PajeType.h"
#include "PajeContainer.h"
#include "PSortedArray.h"


@interface EntityChunk : NSObject //<NSCopying>
{
    PajeContainer *container;
    PajeEntityType *entityType;
    NSDate *startTime;
    NSDate *endTime;
    
    enum { active, frozen, empty } chunkState;

    PSortedArray *entities;
    NSArray *incompleteEntities;

    // for LRU list of chunks
    EntityChunk *prev;
    EntityChunk *next;
}

// chunk has been touched -- move it to head of list
+ (void)touch:(EntityChunk *)chunk;
+ (void)emptyLeastRecentlyUsedChunks;

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc;

- (void)dealloc;

/*
 * Accessors
 */

- (PajeContainer *)container;
- (PajeEntityType *)entityType;

- (void)setStartTime:(NSDate *)time;
- (NSDate *)startTime;

- (void)setEndTime:(NSDate *)time;
- (NSDate *)endTime;


/*
 * Accessing chunk state
 */

// can receive more entities
- (BOOL)isActive;

// cannot receive more entities; can be enumerated
- (BOOL)isFull;

// chunk with entities removed
- (BOOL)isZombie;

- (BOOL)canEnumerate;
- (BOOL)canInsert;

/*
 * Changing chunk state
 */

// sent to a zombie to refill it
- (void)activate;

// sent to an active chunk to make it full
- (void)freeze;

// sent to a full chunk to empty it (make a zombie)
- (void)empty;


/*
 * entity enumerators (must be in reverse [-endTime] order)
 */

// auxiliary methods used when creating enumerators
- (PSortedArray *)completeEntities;
- (NSArray *)incompleteEntities;
- (void)setIncompleteEntities:(NSArray *)array;

// only entities that finish inside the chunk's time boundaries
- (NSEnumerator *)enumeratorOfAllCompleteEntities;
//- (NSEnumerator *)enumeratorOfCompleteEntitiesAfterTime:(NSDate *)time;
- (NSEnumerator *)enumeratorOfCompleteEntitiesFromTime:(NSDate *)time;

// all entities, including those that finish after the chunk's endTime
- (NSEnumerator *)enumeratorOfAllEntities;
- (NSEnumerator *)enumeratorOfEntitiesBeforeTime:(NSDate *)time;
- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime;

// only completed entities, in non-reverse order
// include entities that end on those times.
- (NSEnumerator *)fwEnumeratorOfAllCompleteEntities;
- (NSEnumerator *)fwEnumeratorOfCompleteEntitiesFromTime:(NSDate *)time;
- (NSEnumerator *)fwEnumeratorOfCompleteEntitiesUntilTime:(NSDate *)time;
- (NSEnumerator *)fwEnumeratorOfCompleteEntitiesFromTime:(NSDate *)start
                                               untilTime:(NSDate *)end;

- (int)entityCount;
- (id)lastEntity;

- (void)addEntity:(PajeEntity *)entity;
@end

#endif
