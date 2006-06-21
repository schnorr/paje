/*
    Copyright (c) 2006 Benhur Stein
    
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
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
#ifndef _SimulChunk_h_ 
#define _SimulChunk_h_ 

#include "../General/EntityChunk.h"
#include "../General/MultiEnumerator.h"
#include "UserState.h"
#include "UserLink.h"

@interface SimulChunk : EntityChunk
{
    BOOL lastChunk;
}

+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc;


- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc;


- (void)removeAllCompletedEntities;

- (void)setIncompleteEntities:(NSArray *)array;
- (NSArray *)incompleteEntities;

// Simulation
- (void)addEntity:(PajeEntity *)entity;

- (void)stopWithEvent:(PajeEvent *)event;

- (void)setPreviousChunkIncompleteEntities:(NSArray *)array;

// for events
- (void)newEventEvent:(PajeEvent *)event
                value:(id)value;

// for states
- (void)setStateEvent:(PajeEvent *)event
                value:(id)value;
- (void)pushStateEvent:(PajeEvent *)event
                 value:(id)value;
- (void)popStateEvent:(PajeEvent *)event;

// for links
- (void)startLinkEvent:(PajeEvent *)event
                 value:(id)value
       sourceContainer:(PajeContainer *)cont
                   key:(id)key;
- (void)endLinkEvent:(PajeEvent *)event
               value:(id)value
       destContainer:(PajeContainer *)cont
                 key:(id)key;

// for variables
- (void)setVariableEvent:(PajeEvent *)event
                   value:(id)value;
- (void)addVariableEvent:(PajeEvent *)event
                   value:(id)value;
- (void)subVariableEvent:(PajeEvent *)event
                   value:(id)value;


// true if chunk is last of container
- (BOOL)isLastChunk;

// sent to an active chunk to finish it
- (void)endOfChunkWithTime:(NSDate *)time;
@end

@interface EventChunk : SimulChunk
{
    PSortedArray *entities;
}
@end


@interface StateChunk : EventChunk
{
    NSArray *incompleteEntities;
    NSMutableArray *simulationStack;
    int resimulationStackLevel;
}

@end


@interface LinkChunk : StateChunk
{
    NSMutableArray *pendingLinks;
}
@end
@interface VariableChunk : StateChunk
@end

@interface AggregateStateChunk : StateChunk
- (PajeEntity *)firstIncomplete;
@end
#endif
