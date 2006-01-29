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
#ifndef _SimulChunk_h_ 
#define _SimulChunk_h_ 

#include "../General/EntityChunk.h"
#include "../General/PSortedArray.h"
#include "../General/MultiEnumerator.h"
#include "UserState.h"

@interface SimulChunk : EntityChunk
+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc
                 incompleteEntities:(NSMutableArray *)array;
+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc;


- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
      incompleteEntities:(NSMutableArray *)array;
- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc;

/*
 * entity enumerators
 */

// only entities that finish inside the chunk's time boundaries
- (NSEnumerator *)enumeratorOfAllCompleteEntities;
- (NSEnumerator *)enumeratorOfCompleteEntitiesAfterTime:(NSDate *)time;

// all entities, including those that finish after the chunk's endTime
- (NSEnumerator *)enumeratorOfAllEntities;
- (NSEnumerator *)enumeratorOfEntitiesBeforeTime:(NSDate *)time;
- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime;

- (void)removeAllCompletedEntities;

- (NSMutableArray *)incompleteEntities;

// Simulation
- (void)addEntity:(PajeEntity *)entity;

- (void)stopWithEvent:(PajeEvent *)event;

// for states
- (void)pushEntity:(PajeEntity *)entity;
- (UserState *)topEntity;
- (void)removeTopEntity;
@end

@interface EventChunk : SimulChunk
{
    PSortedArray *entities;
}
@end


@interface StateChunk : EventChunk
{
    NSMutableArray *incompleteEntities;
}

@end


@interface LinkChunk : StateChunk
@end
@interface VariableChunk : StateChunk
@end

#endif
