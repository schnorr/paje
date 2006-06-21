/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004, 2005 Benhur Stein
    
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

#include "SimulChunk.h"

#include "../General/Macros.h"

@implementation SimulChunk
+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc
{
    Class class;
    switch ([type drawingType]) {
    case PajeEventDrawingType:
        class = [EventChunk class];
        break;
    case PajeStateDrawingType:
        class = [StateChunk class];
        break;
    case PajeLinkDrawingType:
        class = [LinkChunk class];
        break;
    case PajeVariableDrawingType:
        class = [VariableChunk class];
        break;
    default:
        NSWarnMLog(@"No support for creating chunk of type %@", type);
        class = nil;
    }

    return [[[class alloc] initWithEntityType:type
                                    container:pc] autorelease];
}


- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
{
    self = [super initWithEntityType:type container:pc];
    if (self != nil) {
	lastChunk = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}



- (void)removeAllCompletedEntities
{
    [self _subclassResponsibility:_cmd];
}

- (void)setIncompleteEntities:(NSArray *)array
{
    [self _subclassResponsibility:_cmd];
}

- (NSArray *)incompleteEntities
{
    return [NSArray array];
}


// Simulation
- (void)addEntity:(PajeEntity *)entity
{
    [self _subclassResponsibility:_cmd];
}


- (void)stopWithEvent:(PajeEvent *)event
{
    [self _subclassResponsibility:_cmd];
}

// for events
- (void)newEventEvent:(PajeEvent *)event
                value:(id)value
{
    NSLog(@"Ignoring 'newEvent' event for non event entity type. Event: %@",
        event);
}


// for states
- (void)setStateEvent:(PajeEvent *)event
                value:(id)value
{
    NSLog(@"Ignoring 'setState' event for non state entity type. Event: %@",
        event);
}

- (void)pushStateEvent:(PajeEvent *)event
                 value:(id)value
{
    NSLog(@"Ignoring 'pushState' event for non state entity type. Event: %@",
        event);
}

- (void)popStateEvent:(PajeEvent *)event
{
    NSLog(@"Ignoring 'popState' event for non state entity type. Event: %@",
        event);
}


// for links
- (void)startLinkEvent:(PajeEvent *)event
                 value:(id)value
       sourceContainer:(PajeContainer *)cont
                   key:(id)key;
{
    NSLog(@"Ignoring 'startLink' event for non link entity type. Event: %@",
        event);
}

- (void)endLinkEvent:(PajeEvent *)event
               value:(id)value
       destContainer:(PajeContainer *)cont
                 key:(id)key
{
    NSLog(@"Ignoring 'endLink' event for non link entity type. Event: %@",
        event);
}

// for variables
- (void)setVariableEvent:(PajeEvent *)event
                   value:(id)value
{
    NSLog(@"Ignoring 'setVariable' event for non variable entity type."
           " Event: %@", event);
}

- (void)addVariableEvent:(PajeEvent *)event
                   value:(id)value
{
    NSLog(@"Ignoring 'addVariable' event for non variable entity type."
           " Event: %@", event);
}

- (void)subVariableEvent:(PajeEvent *)event
                   value:(id)value
{
    NSLog(@"Ignoring 'subVariable' event for non variable entity type."
           " Event: %@", event);
}


- (void)setPreviousChunkIncompleteEntities:(NSArray *)array
{
    NSAssert([array count] == 0, @"");
}


- (BOOL)isLastChunk
{
    return lastChunk;
}

- (void)endOfChunkWithTime:(NSDate *)time
{
    [self _subclassResponsibility:_cmd];
}

@end

@implementation EventChunk

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
{
    self = [super initWithEntityType:type
                           container:pc];
    if (self != nil) {
        entities = [[PSortedArray alloc] initWithSelector:@selector(endTime)];
    }
    return self;
}

- (void)dealloc
{
    Assign(entities, nil);
    [super dealloc];
}


- (PSortedArray *)completeEntities
{
    return entities;
}

- (void)removeAllCompletedEntities
{
    [entities removeAllObjects];
}

- (void)setIncompleteEntities:(NSArray *)array
{
    [self _subclassResponsibility:_cmd];
}



- (void)addEntity:(PajeEntity *)entity
{
    NSAssert([self canInsert], @"adding entities to inactive chunk");
    [entities addObject:entity];
}

- (void)stopWithEvent:(PajeEvent *)event
{
    [self setEndTime:[event time]];
    lastChunk = YES;
}

- (void)activate
{
    [super activate];
    entities = [[PSortedArray alloc] initWithSelector:@selector(endTime)];
}

- (void)empty
{
    if ([self isZombie]) {
        return;
    }
    [super empty];
    Assign(entities, nil);
}

- (void)endOfChunkWithTime:(NSDate *)time
{
    [super freeze];
    // make arrays immutable?
    if (!lastChunk) [self setEndTime:time];
}

- (void)newEventEvent:(PajeEvent *)event
                value:(id)value
{
    UserEvent *newEvent;
    newEvent = [UserEvent eventWithType:entityType
                                   name:value
                              container:container
                                  event:event];

    [self addEntity:newEvent];
}
@end


@implementation StateChunk

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
{
    self = [super initWithEntityType:type container:pc];
    if (self != nil) {
//        [self setPreviousChunkIncompleteEntities:[NSArray array]];
    }
    return self;
}

- (void)dealloc
{
    Assign(incompleteEntities, nil);
    Assign(simulationStack, nil);
    [super dealloc];
}

- (void)setIncompleteEntities:(NSArray *)array
{
    if (incompleteEntities != nil) {
        [incompleteEntities release];
        incompleteEntities = nil;
    }
    if (array != nil) {
        incompleteEntities = [array copy];
    }
}

- (NSArray *)incompleteEntities
{
    return incompleteEntities;
}

- (void)setStateEvent:(PajeEvent *)event
                value:(id)value
{
    if ([simulationStack count] > 0) {
        [self popStateEvent:event];
    }
    [self pushStateEvent:event
                   value:value];
}

- (void)pushStateEvent:(PajeEvent *)event
                 value:(id)value
{
    UserState *state = nil;
    int imbricationLevel;

    imbricationLevel = [simulationStack count];
    // if this chunk is being resimulated and the new state already
    // exists as an incomplete state, reuse it; else create a new one.
    if (imbricationLevel == resimulationStackLevel
        && imbricationLevel < [incompleteEntities count]) {
        state = [incompleteEntities objectAtIndex:imbricationLevel];
        if ([[state startTime] isEqualToDate:[event time]]
            && [[state value] isEqual:value]) {
            resimulationStackLevel++;
        } else {
            state = nil;
        }
        
    }
    if (state == nil) {
        state = [UserState stateOfType:entityType
                                 value:value
                             container:container
                            startEvent:event];
        [state setImbricationLevel:imbricationLevel];
    }
    [simulationStack addObject:state];
}

- (void)popStateEvent:(PajeEvent *)event
{
    UserState *poppedState;
    UserState *newTopState;

    poppedState = (UserState *)[simulationStack lastObject];
    if (poppedState != nil) {
        [poppedState setEndEvent:event];
        [self addEntity:poppedState];
        [simulationStack removeLastObject];
        newTopState = (UserState *)[simulationStack lastObject];
        if (newTopState != nil) {
            int stackLevel = [simulationStack count];
            if (stackLevel > resimulationStackLevel) {
                [newTopState addInnerState:poppedState];
            } else if (stackLevel < resimulationStackLevel) {
                resimulationStackLevel = stackLevel;
            }
        }
    } else {
        NSWarnMLog(@"No user state to pop with event %@", event);
    }
}

- (void)setPreviousChunkIncompleteEntities:(NSArray *)newStack
{
    if (simulationStack != nil) {
        [simulationStack release];
        simulationStack = nil;
    }
    if (newStack != nil) {
        simulationStack = [newStack mutableCopy];
        if (incompleteEntities != nil) { // resimulating
            resimulationStackLevel = [simulationStack count];
        } else {
            resimulationStackLevel = -1;
        }
    }
}


- (void)stopWithEvent:(PajeEvent *)event
{
    while ([simulationStack count] > 0) {
        [self popStateEvent:event];
    }

    [super stopWithEvent:event];
}


- (void)activate
{
    [super activate];
    // someone must setPreviousChunkIncompleteEntities, or won't work
}

- (void)endOfChunkWithTime:(NSDate *)time
{
    [self setIncompleteEntities:simulationStack];
    Assign(simulationStack, nil);;
    [super endOfChunkWithTime:time];
}

@end

#include "SimulContainer.h"

@implementation LinkChunk
- (void)startLinkEvent:(PajeEvent *)event
                 value:(id)value
       sourceContainer:(PajeContainer *)cont
                   key:(id)key
{
    UserLink *link = nil;
    unsigned index = 0;
    BOOL found = NO;
    int sourceLogicalTime;
    SimulContainer *sourceContainer = (SimulContainer *)cont;
    SimulContainer *destContainer;

    sourceLogicalTime = [sourceContainer logicalTime];

    sourceLogicalTime++;
    [sourceContainer setLogicalTime:sourceLogicalTime];

    unsigned count = [pendingLinks count];
    for (index = 0; index < count; index++) {
        link = [pendingLinks objectAtIndex:index];
        if ([link canBeStartedWithValue:value key:key]) {
            found = YES;
            break;
        }
    }

    if (found) {
        [link setSourceContainer:sourceContainer sourceEvent:event];
        [link setStartLogicalTime:sourceLogicalTime];
        destContainer = (SimulContainer *)[link destContainer];
        if ([destContainer logicalTime] < sourceLogicalTime + 1) {
            [destContainer setLogicalTime:sourceLogicalTime + 1];
            [link setEndLogicalTime:sourceLogicalTime + 1];
        }
        [self addEntity:link];
        [pendingLinks removeObjectAtIndex:index];
    } else {
        // TODO: search incompletes
        link = [UserLink linkOfType:entityType
                              value:value
                                key:key
                          container:container
                    sourceContainer:sourceContainer
                        sourceEvent:event];
        [pendingLinks addObject:link];
        [link setStartLogicalTime:sourceLogicalTime];
   }
}

- (void)endLinkEvent:(PajeEvent *)event
               value:(id)value
       destContainer:(PajeContainer *)cont
                 key:(id)key
{
    UserLink *link = nil;
    unsigned index = 0;
    BOOL found = NO;
    int destLogicalTime;
    SimulContainer *destContainer = (SimulContainer *)cont;

    destLogicalTime = [destContainer logicalTime];
    destLogicalTime++;
    [destContainer setLogicalTime:destLogicalTime];

    unsigned count = [pendingLinks count];
    for (index = 0; index < count; index++) {
        link = [pendingLinks objectAtIndex:index];
        if ([link canBeEndedWithValue:value key:key]) {
            found = YES;
            break;
        }
    }

    if (found) {
        int lt = [link startLogicalTime] + 1;
        if (lt > destLogicalTime) {
            destLogicalTime = lt;
            [destContainer setLogicalTime:lt];
        }
        [link setEndLogicalTime:destLogicalTime];
        [link setDestContainer:destContainer destEvent:event];
        [self addEntity:link];
        [pendingLinks removeObjectAtIndex:index];
    } else {
        // search link in incomplete entities
//        for (in
        link = [UserLink linkOfType:entityType
                              value:value
                                key:key
                          container:container
                      destContainer:destContainer
                          destEvent:event];
        [link setEndLogicalTime:destLogicalTime];
        [pendingLinks addObject:link];
   }
}


- (void)setPreviousChunkIncompleteEntities:(NSArray *)array
{
    if (pendingLinks != nil) {
        [pendingLinks release];
        pendingLinks = nil;
    }
    if (array != nil) {
        pendingLinks = [array mutableCopy];
    }
}

- (void)stopWithEvent:(PajeEvent *)event
{
    while ([pendingLinks count] > 0) {
        NSLog(@"incomplete links at end of container: %@", pendingLinks);
    }

    [super stopWithEvent:event];
}


- (void)activate
{
    [super activate];
    // someone must setPreviousChunkIncompleteEntities, or won't work
}

- (void)endOfChunkWithTime:(NSDate *)time
{
    [self setIncompleteEntities:pendingLinks];
    Assign(pendingLinks, nil);;
    [super endOfChunkWithTime:time];
}

@end

@implementation VariableChunk
// For the time being, variables are implemented as states.
// FIXME: should be implemented as variables.
- (id)topEntity
{
    return [simulationStack lastObject];
}

- (void)setVariableEvent:(PajeEvent *)event
                   value:(id)value
{
    [container _verifyMinMaxOfEntityType:entityType withValue:value];
    [self setStateEvent:event
                  value:[value stringValue]];
}

- (void)addVariableEvent:(PajeEvent *)event
                   value:(id)value
{
    UserState *currentUserState;
    id oldValue;
    id newValue;

    currentUserState = [self topEntity];
    if (currentUserState != nil) {
        oldValue = [currentUserState value];
        newValue = [NSNumber numberWithDouble:
            [oldValue doubleValue] + [value doubleValue]];
    } else {
        newValue = value;
    }

    [self setVariableEvent:event
                     value:newValue];
}

- (void)subVariableEvent:(PajeEvent *)event
                   value:(id)value
{
    UserState *currentUserState;
    id oldValue;
    id newValue;

    currentUserState = [self topEntity];
    if (currentUserState != nil) {
        oldValue = [currentUserState value];
        newValue = [NSNumber numberWithDouble:
            [oldValue doubleValue] - [value doubleValue]];
    } else {
        newValue = [NSNumber numberWithDouble:-[value doubleValue]];
    }

    [self setVariableEvent:event
                     value:newValue];
}

@end

@implementation AggregateStateChunk
- (BOOL)canEnumerate
{
    return chunkState2 != empty;
}

- (BOOL)canInsert
{
    return chunkState2 != empty;
}

- (void)empty
{
    if (chunkState2 == frozen) {
        [super empty];
    }
}

- (PajeEntity *)firstIncomplete
{
    return [[self incompleteEntities] lastObject];
}

- (void)setEntityCount:(int)newCount
{
    int n;
    PSortedArray *array;
    array = [self completeEntities];
    n = [array count] - newCount;
    if (n > 0) {
        [array removeObjectsInRange:NSMakeRange(newCount, n)];
    }
}
@end
