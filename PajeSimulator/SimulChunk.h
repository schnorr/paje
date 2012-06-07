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
#include "../General/MultiEnumerator.h"
#include "UserState.h"
#include "UserLink.h"
#include "UserValue.h"

@interface SimulChunk : EntityChunk
{
    BOOL lastChunk;
}

+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc;

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc;

// Simulation
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
- (void)resetStateEvent:(PajeEvent *)event;

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
             doubleValue:(double)value;
- (void)addVariableEvent:(PajeEvent *)event
             doubleValue:(double)value;
- (void)subVariableEvent:(PajeEvent *)event
             doubleValue:(double)value;


// true if chunk is last of container
- (BOOL)isLastChunk;

// sent to an active chunk to finish it
- (void)endOfChunkWithTime:(NSDate *)time;
@end

@interface EventChunk : SimulChunk
@end

@interface StateChunk : SimulChunk
{
    NSMutableArray *simulationStack;
    int resimulationStackLevel;
}

@end


@interface LinkChunk : SimulChunk
{
    NSMutableArray *pendingLinks;
}
@end

@interface VariableChunk : SimulChunk
{
    NSDate *currentTime;
    double currentValue;
    double maxValue;
    double minValue;
    double sumValue;
}
@end
#endif
