/*
    Copyright (c) 1998, 1999, 2000, 2001, 2002, 2003, 2004 Benhur Stein
    
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
//
// PajeContainer
//
// superclass for containers
//

#include "SimulContainer.h"
#include "SimulChunk.h"
#include "UserState.h"
#include "UserLink.h"
#include "../General/Macros.h"
#include "PajeSimul.h"
#include "../General/UniqueString.h"

@implementation SimulContainer

+ (SimulContainer *)containerWithType:(PajeEntityType *)type
                                 name:(NSString *)n
                                alias:(NSString *)a
                            container:(PajeContainer *)c
                         creationTime:(NSDate *)time
                            simulator:(id)simul
{
    return [[[self alloc] initWithType:type
                                  name:n
                                 alias:a
                             container:c
                          creationTime:time
                             simulator:simul] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
             alias:(NSString *)a
         container:(PajeContainer *)c
      creationTime:(NSDate *)time
         simulator:(id)simul
{
    self = [super initWithType:type
                          name:n
                     container:c];
    if (self != nil) {
        Assign(creationTime, time);
        simulator = simul;

        Assign(alias, a);
        Assign(userEntities, [NSMutableDictionary dictionary]);
        Assign(minValues, [NSMutableDictionary dictionary]);
        Assign(maxValues, [NSMutableDictionary dictionary]);
    }
    
    return self;
}

- (void)dealloc
{
    Assign(creationTime, nil);
    Assign(alias, nil);
    Assign(lastTime, nil);
    Assign(userEntities, nil);
    Assign(minValues, nil);
    Assign(maxValues, nil);
    [super dealloc];
}

- (NSString *)alias
{
    return alias;
}

- (NSDate *)startTime
{
    return creationTime;
}

- (NSDate *)time
{
    return creationTime;
}

- (NSDate *)endTime
{
    if (lastTime != nil) {
        return lastTime;
    }
    if (container != nil) {
        return [container endTime];
    }
    return [simulator endTime];
}

- (void)setLastTime:(NSDate *)time
{
    Assign(lastTime, time);
}


- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)stopWithEvent:(PajeEvent *)event
{
    if (lastTime != nil) {
        return;
    }
    [self setLastTime:[event time]];

    NSEnumerator *chunkEnumerator;
    EventChunk *chunk;

    chunkEnumerator = [userEntities objectEnumerator];
    while ((chunk = [chunkEnumerator nextObject]) != nil) {
        [chunk stopWithEvent:event];
        [chunk setEndTime:[simulator currentTime]];
        [simulator outputChunk:chunk];
    }
    [userEntities removeAllObjects];

    NSEnumerator *subEnum;
    SimulContainer *subContainer;

    subEnum = [subContainers objectEnumerator];
    while ((subContainer = [subEnum nextObject]) != nil) {
        [subContainer stopWithEvent:event];
    }
}

- (void)endOfChunk
{
    NSEnumerator *chunkEnumerator;
    EventChunk *chunk;

    chunkEnumerator = [userEntities objectEnumerator];
    while ((chunk = [chunkEnumerator nextObject]) != nil) {
        EventChunk *completedChunk;
        completedChunk = [chunk copy];
        [completedChunk setEndTime:[simulator currentTime]];
        [simulator outputChunk:completedChunk];
        [completedChunk release];
        [chunk removeAllCompletedEntities];
        [chunk setStartTime:[simulator currentTime]];
    }
}

- (SimulChunk *)chunkOfType:(id)type
{
    id chunk = [userEntities objectForKey:type];
    
    if (chunk == nil) {
        chunk = [SimulChunk chunkWithEntityType:type
                                      container:self];
        [userEntities setObject:chunk forKey:type];
    }
    
    return chunk;
}


- (void)newEventWithType:(id)type
                   value:(id)value
               withEvent:(PajeEvent *)event
{
    UserEvent *newEvent;
    newEvent = [UserEvent eventWithType:type
                                   name:value
                              container:self
                                  event:event];

    [[self chunkOfType:type] addEntity:newEvent];
}

- (void)setUserStateOfType:(PajeEntityType *)type
                   toValue:(id)value
                 withEvent:(PajeEvent *)event
{
    UserState *oldUserState;
    UserState *newUserState;
    StateChunk *chunk;

    chunk = (StateChunk *)[self chunkOfType:type];

    oldUserState = [chunk topEntity];
    if (oldUserState != nil) {
        [oldUserState setEndEvent:event];
        [chunk addEntity:oldUserState];
        [chunk removeTopEntity];
    }

    newUserState = [UserState stateOfType:type
                                    value:value
                                container:self
                               startEvent:event];
    [chunk pushEntity:newUserState];
}

- (void)pushUserStateOfType:(PajeEntityType *)type
                      value:(id)value
                  withEvent:(PajeEvent *)event
{
    UserState *newUserState;
    StateChunk *chunk;

    chunk = (StateChunk *)[self chunkOfType:type];

    newUserState = [UserState stateOfType:type
                                    value:value
                                container:self
                               startEvent:event];

    [chunk pushEntity:newUserState];
}

- (void)popUserStateOfType:(PajeEntityType *)type
                 withEvent:(PajeEvent *)event
{
    UserState *poppedUserState;
    UserState *newTopUserState;
    StateChunk *chunk;

    chunk = (StateChunk *)[self chunkOfType:type];

    poppedUserState = [chunk topEntity];
    if (poppedUserState != nil) {
        [poppedUserState setEndEvent:event];
        [chunk addEntity:poppedUserState];
        [chunk removeTopEntity];
        newTopUserState = [chunk topEntity];
        if (newTopUserState != nil) {
            [newTopUserState addInnerState:poppedUserState];
        }
    } else {
        NSWarnMLog(@"No user state to pop with event %@", event);
    }
}

- (void)_verifyMinMaxOfEntityType:(PajeVariableType *)type
                        withValue:(NSNumber *)value
{
    NSNumber *oldMin;
    NSNumber *oldMax;
    oldMin = [minValues objectForKey:type];
    oldMax = [maxValues objectForKey:type];

    if ((oldMin == nil) || ([oldMin compare:value] == NSOrderedDescending)) {
        [minValues setObject:value forKey:type];
        [type possibleNewMinValue:value];
    }

    if ((oldMax == nil) || ([oldMax compare:value] == NSOrderedAscending)) {
        [maxValues setObject:value forKey:type];
        [type possibleNewMaxValue:value];
    }
}

// For the time being, variables are implemented as states.
// FIXME: should be implemented as variables.
- (void)setUserVariableOfType:(PajeVariableType *)type
                      toValue:(id)value
                    withEvent:(PajeEvent *)event
{
    [self _verifyMinMaxOfEntityType:type withValue:value];
    [self setUserStateOfType:type
                     toValue:[value stringValue]
                   withEvent:event];
}

- (void)addUserVariableOfType:(PajeVariableType *)type
                        value:(id)value
                    withEvent:(PajeEvent *)event
{
    UserState *currentUserState;
    id oldValue;
    id newValue;
    VariableChunk *chunk;

    chunk = (VariableChunk *)[self chunkOfType:type];

    currentUserState = [chunk topEntity];
    if (currentUserState != nil) {
        oldValue = [currentUserState value];
        newValue = [NSNumber numberWithDouble:
            [oldValue doubleValue] + [value doubleValue]];
    } else
        newValue = value;

    [self setUserVariableOfType:type
                        toValue:newValue
                      withEvent:event];
}

- (void)subUserVariableOfType:(PajeVariableType *)type
                        value:(id)value
                    withEvent:(PajeEvent *)event
{
    UserState *currentUserState;
    id oldValue;
    id newValue;
    VariableChunk *chunk;

    chunk = (VariableChunk *)[self chunkOfType:type];

    currentUserState = [chunk topEntity];
    if (currentUserState != nil) {
        oldValue = [currentUserState value];
        newValue = [NSNumber numberWithDouble:
            [oldValue doubleValue] - [value doubleValue]];
    } else
        newValue = [NSNumber numberWithDouble:-[value doubleValue]];

    [self setUserVariableOfType:type
                        toValue:newValue
                      withEvent:event];
}

- (NSNumber *)minValueForEntityType:(PajeEntityType *)type
{
    return [minValues objectForKey:type];
}

- (NSNumber *)maxValueForEntityType:(PajeEntityType *)type
{
    return [maxValues objectForKey:type];
}


- (void)startUserLinkOfType:(PajeEntityType *)type
                      value:(id)value
            sourceContainer:(PajeContainer *)cont
                        key:(id)key
                  withEvent:(PajeEvent *)event
{
    NSMutableArray *pendingLinks;
    UserLink *link = nil;
    unsigned index = 0;
    BOOL found = NO;
    int sourceLogicalTime;
    LinkChunk *chunk;
    SimulContainer *sourceContainer = (SimulContainer *)cont;
    SimulContainer *destContainer;

    chunk = (LinkChunk *)[self chunkOfType:type];
    pendingLinks = [chunk incompleteEntities];

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
        if ([destContainer logicalTime] < sourceLogicalTime+1) {
            [destContainer setLogicalTime:sourceLogicalTime+1];
            [link setEndLogicalTime:sourceLogicalTime+1];
        }
        [chunk addEntity:link];
        [pendingLinks removeObjectAtIndex:index];
    } else {
        link = [UserLink linkOfType:type
                              value:value
                                key:key
                          container:self
                    sourceContainer:sourceContainer
                        sourceEvent:event];
        [pendingLinks addObject:link];
        [link setStartLogicalTime:sourceLogicalTime];
   }
}

- (void)endUserLinkOfType:(PajeEntityType *)type
                    value:(id)value
            destContainer:(PajeContainer *)cont
                      key:(id)key
                withEvent:(PajeEvent *)event
{
    NSMutableArray *pendingLinks;
    UserLink *link = nil;
    unsigned index = 0;
    BOOL found = NO;
    int destLogicalTime;
    LinkChunk *chunk;
    SimulContainer *destContainer = (SimulContainer *)cont;

    chunk = (LinkChunk *)[self chunkOfType:type];
    pendingLinks = [chunk incompleteEntities];

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
        int lt = [link startLogicalTime]+1;
        if (lt > destLogicalTime) {
            destLogicalTime = lt;
            [destContainer setLogicalTime: lt];
        }
        [link setEndLogicalTime:destLogicalTime];
        [link setDestContainer:destContainer destEvent:event];
        [chunk addEntity:link];
        [pendingLinks removeObjectAtIndex:index];
    } else {
        link = [UserLink linkOfType:type
                              value:value
                                key:key
                          container:self
                      destContainer:destContainer
                          destEvent:event];
        [link setEndLogicalTime:destLogicalTime];
        [pendingLinks addObject:link];
   }
}

- (int)logicalTime
{
    return logicalTime;
}

- (void)setLogicalTime:(int)lt
{
    logicalTime = lt;
}

- (void)reset
{
    [userEntities removeAllObjects];
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)type
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
{
    id entity = [userEntities objectForKey:type];

    if (entity == nil) {
        return [[NSArray array] objectEnumerator];
    }
    if (![entity isKindOfClass:[NSArray class]]) {
        return [[NSArray arrayWithObject:entity] objectEnumerator];
    }
    
    return [(NSArray *)entity objectEnumerator];
}


- (void)encodeCheckPointWithCoder:(NSCoder *)coder
{
    //NSDebugMLLog(@"enc", @"encoding %@ (lt=%@ %d ue=%@)",
    //                     self, lastTime, logicalTime, userEntities);
    [coder encodeObject:lastTime];
    [coder encodeObject:[NSNumber numberWithInt:logicalTime]];

    NSMutableDictionary *incompleteEntitiesByType;
    incompleteEntitiesByType = [[NSMutableDictionary alloc] init];

    NSEnumerator *chunkEnum;
    EventChunk *chunk;
    chunkEnum = [userEntities objectEnumerator];
    while ((chunk = [chunkEnum nextObject]) != nil) {
        NSArray *incomplete = [chunk incompleteEntities];
        if (incomplete != nil) {
            [incompleteEntitiesByType setObject:incomplete
                                         forKey:[[chunk entityType] name]];
        }
    }
    [coder encodeObject:incompleteEntitiesByType];
    [incompleteEntitiesByType release];
}

- (void)decodeCheckPointWithCoder:(NSCoder *)coder
{
    [self setLastTime:[coder decodeObject]];
    [self setLogicalTime:[[coder decodeObject] intValue]];

    [userEntities removeAllObjects];
    NSMutableDictionary *incompleteEntitiesByType;
    incompleteEntitiesByType = [coder decodeObject];

    NSEnumerator *entityTypeNameEnum;
    NSString *entityTypeName;
    
    entityTypeNameEnum = [incompleteEntitiesByType keyEnumerator];
    while ((entityTypeName = [entityTypeNameEnum nextObject]) != nil) {
        PajeEntityType *chunkEntityType;
        SimulChunk *chunk;
        chunkEntityType = [simulator entityTypeWithName:entityTypeName];
        NSMutableArray *incompleteEntities
                = [incompleteEntitiesByType objectForKey:entityTypeName];
        [incompleteEntities makeObjectsPerformSelector:@selector(setContainer:)
                                            withObject:self];
        [incompleteEntities makeObjectsPerformSelector:@selector(setEntityType:)
                                            withObject:chunkEntityType];
        chunk = [SimulChunk chunkWithEntityType:chunkEntityType
                                      container:self
                             incompleteEntities:incompleteEntities];
        [userEntities setObject:chunk forKey:chunkEntityType];
    }
    //NSDebugMLLog(@"enc", @"decoded %@ (lt=%@ %d ue=%@)",
    //                     self, lastTime, logicalTime, userEntities);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [NSException raise:@"SimulContainer should not be encoded" format:nil];
}
@end
