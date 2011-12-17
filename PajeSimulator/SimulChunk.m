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
#include <math.h>

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


// Simulation

- (void)setPreviousChunkIncompleteEntities:(NSArray *)array
{
    NSAssert([array count] == 0, @"");
}


- (BOOL)isLastChunk
{
    return lastChunk;
}

- (void)stopWithEvent:(PajeEvent *)event
{
    [self setEndTime:[event time]];
    lastChunk = YES;
}

- (void)endOfChunkWithTime:(NSDate *)time
{
    [super freeze];
    // make arrays immutable?
    if (!lastChunk) [self setEndTime:time];
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
             doubleValue:(double)value
{
    NSLog(@"Ignoring 'setVariable' event for non variable entity type."
           " Event: %@", event);
}

- (void)addVariableEvent:(PajeEvent *)event
             doubleValue:(double)value
{
    NSLog(@"Ignoring 'addVariable' event for non variable entity type."
           " Event: %@", event);
}

- (void)subVariableEvent:(PajeEvent *)event
             doubleValue:(double)value
{
    NSLog(@"Ignoring 'subVariable' event for non variable entity type."
           " Event: %@", event);
}


@end

@implementation EventChunk

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
    Assign(simulationStack, nil);
    [super dealloc];
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
    // if incompleteEntities is already set, entities in simulationStack can be ignored
    // (it is a resimulation, and they should be equal to incompleteEntities)
    if (incompleteEntities == nil) {
        [self setIncompleteEntities:simulationStack];
    }
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
    if ([pendingLinks count] > 0) {
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
    // if incompleteEntities is already set, entities in pendingLinks can be ignored
    // (it is a resimulation, and they should be equal to incompleteEntities)
    if (incompleteEntities == nil) {
        [self setIncompleteEntities:pendingLinks];
    }
    Assign(pendingLinks, nil);;
    [super endOfChunkWithTime:time];
}
@end

#include "../General/Association.h"

@implementation VariableChunk

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
{
    self = [super initWithEntityType:type
                           container:pc];
    if (self != nil) {
        //[entities setSelector:@selector(objectValue)];
        [entities setSelector:@selector(time)];
        currentValue = HUGE_VAL;
    }
    return self;
}

- (void)activate
{
    [super activate];
    //[entities setSelector:@selector(objectValue)];
    [entities setSelector:@selector(time)];
}

- (id)topEntity
{
    return [entities lastObject];
}

- (void)setPreviousChunkIncompleteEntities:(NSArray *)newIncompleteEntities
{
    NSAssert([entities count] == 0, @"Internal inconsistency");
//    if (incompleteEntities != nil && [incompleteEntities count] != 0) {
//        NSAssert([newIncompleteEntities count] == 1, @"Internal inconsistency");
//NSLog(@"previnc count=%d", [newIncompleteEntities count]);
if ([newIncompleteEntities count] == 1)
        [self addEntity:[newIncompleteEntities lastObject]];
//    }
    currentValue = HUGE_VAL;
}

- (void)setValue:(double)value
            time:(NSDate *)time
{
    if (value != HUGE_VAL && currentValue == value) return;

    if (currentValue != HUGE_VAL) {
        sumValue += currentValue
                  * [time timeIntervalSinceDate:currentTime];
        [self addEntity:[UserValue valueWithType:entityType
                                     doubleValue:currentValue
                                       container:container
                                       startTime:currentTime
                                         endTime:time]];
    } else {
        UserValue *valueFromPreviousChunk;
        valueFromPreviousChunk = [self topEntity];
        if (valueFromPreviousChunk != nil) {
            if ([valueFromPreviousChunk doubleValue] == value) return;
            [valueFromPreviousChunk setEndTime:time];
        }
    }
    currentValue = value;
    currentTime = time;
    if (currentValue != HUGE_VAL) {
        if (currentValue > maxValue) maxValue = currentValue;
        if (currentValue < minValue) minValue = currentValue;
        [container verifyMinMaxOfEntityType:entityType withValue:value];
    }
}

- (void)setVariableEvent:(PajeEvent *)event
             doubleValue:(double)value
{
    [self setValue:value time:[event time]];
}

- (void)addVariableEvent:(PajeEvent *)event
             doubleValue:(double)value
{
    [self setValue:currentValue + value time:[event time]];
}

- (void)subVariableEvent:(PajeEvent *)event
             doubleValue:(double)value
{
    [self setValue:currentValue - value time:[event time]];
}

- (void)stopWithEvent:(PajeEvent *)event
{
    [self setValue:HUGE_VAL time:[event time]];
}

- (void)endOfChunkWithTime:(NSDate *)time
{
    if (incompleteEntities == nil) {
        UserValue *incomplete;
        if (currentValue != HUGE_VAL) {
            incomplete = [UserValue valueWithType:entityType
                                      doubleValue:currentValue
                                        container:container
                                        startTime:currentTime
                                          endTime:time];
            Assign(incompleteEntities, [NSArray arrayWithObject:incomplete]);
        } else if ([entities count] == 1) {
            incomplete = [entities lastObject];
            [incomplete setEndTime:time];
            Assign(incompleteEntities, [NSArray arrayWithObject:incomplete]);
            [entities removeLastObject];
        }
    }
    [super endOfChunkWithTime:time];
}

- (void)xsetEndTime:(NSDate *)time
{
    [self setValue:currentValue time:time];
    [super setEndTime:time];
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime
{
    NSEnumerator *incEnum = nil;
    NSEnumerator *compEnum = nil;
    NSEnumerator *en;
    NSUInteger firstIndex;
    NSUInteger lastIndex;
    NSRange range;
    NSUInteger count;
    BOOL mayHaveIncomplete = YES;
    
    [EntityChunk touch:self];
    count = [entities count];
    if (count > 0) {
        firstIndex = [entities indexOfLastObjectBeforeValue:sliceStartTime];
        if (firstIndex == NSNotFound) {
            firstIndex = 0;
        }
        if (firstIndex == count - 1) {
            lastIndex = firstIndex;
            if ([[[entities objectAtIndex:firstIndex] endTime]
                                        isEarlierThanDate:sliceStartTime]) {
                firstIndex++; // no complete entities!
            }
        } else {
            lastIndex = [entities indexOfLastObjectBeforeValue:sliceEndTime];
            if (lastIndex == NSNotFound) {
                lastIndex = -1;
            }
            if (lastIndex != count - 1) {
                mayHaveIncomplete = NO;
            }
        }
        int numEntities = lastIndex - firstIndex + 1;
        if (numEntities > 0) {
            range = NSMakeRange(firstIndex, numEntities);
            compEnum = [entities reverseObjectEnumeratorWithRange:range];
        }
    }
    if (mayHaveIncomplete) {
        PajeEntity *incomplete;
        incomplete = [incompleteEntities lastObject];
        if (incomplete != nil) {
            NSDate *incompleteStartTime;
            incompleteStartTime = [incomplete startTime];
            if ([incompleteStartTime isEarlierThanDate:sliceEndTime]) {
                incEnum = [incompleteEntities objectEnumerator];
            }
        }
    }

    if (incEnum != nil && compEnum != nil) {
        en = [MultiEnumerator enumeratorWithEnumeratorArray:
                    [NSArray arrayWithObjects:incEnum, compEnum, nil]];
    } else if (compEnum != nil) {
        en = compEnum;
    } else {
        en = incEnum;
    }
    return en;
}

- (NSEnumerator *)enumeratorOfEntitiesBeforeTime:(NSDate *)time
{
    // variables are sorted by startTime, default enumerator does not work.
    // Variables do not overlap in a chunk. optimize the default enumerator
    // a bit by not filtering.
    NSEnumerator *incEnum = nil;
    NSEnumerator *compEnum = nil;
    NSEnumerator *en;
    int count;
    BOOL mayHaveIncomplete = YES;
    
    [EntityChunk touch:self];
    count = [entities count];
    if (count > 0) {
        NSUInteger lastIndex = [entities indexOfLastObjectBeforeValue:time];
        if (lastIndex != NSNotFound) {
            unsigned firstIndex = 0;
            if (lastIndex != count - 1) {
                mayHaveIncomplete = NO;
            }
            NSUInteger numEntities = lastIndex - firstIndex + 1;
            if (numEntities > 0) {
                NSRange range;
                range = NSMakeRange(firstIndex, numEntities);
                compEnum = [entities reverseObjectEnumeratorWithRange:range];
            }
        }
    }
    if (mayHaveIncomplete) {
        PajeEntity *incomplete;
        incomplete = [incompleteEntities lastObject];
        if (incomplete != nil) {
            NSDate *incompleteStartTime;
            incompleteStartTime = [incomplete startTime];
            if ([incompleteStartTime isEarlierThanDate:time]) {
                incEnum = [incompleteEntities objectEnumerator];
            }
        }
    }

    if (incEnum != nil && compEnum != nil) {
        en = [MultiEnumerator enumeratorWithEnumeratorArray:
                    [NSArray arrayWithObjects:incEnum, compEnum, nil]];
    } else if (compEnum != nil) {
        en = compEnum;
    } else {
        en = incEnum;
    }
    return en;
}

- (NSEnumerator *)xxenumeratorOfAllCompleteEntities
{
    NSEnumerator *compEnum;
    NSRange range;

    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
    [EntityChunk touch:self];
    range = NSMakeRange(0, [entities count]/* - 1*/);
    compEnum = [entities reverseObjectEnumeratorWithRange:range];
    
    return compEnum;
}
@end
