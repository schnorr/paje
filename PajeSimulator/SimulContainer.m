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
#include "../General/ChunkArray.h"
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
    if (lastTime == nil) {
        [self setLastTime:[event time]];
    }

    NSEnumerator *typeEnumerator;
    id type;

    typeEnumerator = [userEntities keyEnumerator];
    while ((type = [typeEnumerator nextObject]) != nil) {
        SimulChunk *chunk;
        chunk = [self chunkOfType:type];
        if ([chunk isActive]) {
            [chunk stopWithEvent:event];
            //[chunk setEndTime:[simulator currentTime]];
            //[simulator outputChunk:chunk];
        }
    }
    //[userEntities removeAllObjects];

    NSEnumerator *subEnum;
    SimulContainer *subContainer;

    subEnum = [subContainers objectEnumerator];
    while ((subContainer = [subEnum nextObject]) != nil) {
        [subContainer stopWithEvent:event];
    }
}

- (BOOL)isStopped
{
    return lastTime != nil;
}

- (void)startChunk
{
    NSEnumerator *typeEnumerator;
    id type;

    typeEnumerator = [userEntities keyEnumerator];
    while ((type = [typeEnumerator nextObject]) != nil) {
        SimulChunk *chunk;
        chunk = [self chunkOfType:type];
        if (chunk != nil && [chunk isZombie]) {
            SimulChunk *previousChunk;
            NSArray *stack;
            previousChunk = [self previousChunkOfType:type];
            if (previousChunk != nil) {
                stack = [previousChunk incompleteEntities];
            } else {
                stack = [NSArray array];
            }
            [chunk activate];
            [chunk setPreviousChunkIncompleteEntities:stack];
        }
    }
}

- (void)endOfChunk
{
    NSEnumerator *typeEnumerator;
    id type;

    typeEnumerator = [userEntities keyEnumerator];
    while ((type = [typeEnumerator nextObject]) != nil) {
        SimulChunk *chunk;
        chunk = [self chunkOfType:type];
        if ([chunk isActive]) {
            [chunk endOfChunkWithTime:[simulator currentTime]];
            [simulator outputChunk:chunk];
        }
    }
}

- (void)emptyChunk:(int)chunkNumber
{
    ChunkArray *chunkArray;
    NSEnumerator *chunkArrayEnumerator;
    
    chunkArrayEnumerator = [userEntities objectEnumerator];
    while ((chunkArray = [chunkArrayEnumerator nextObject]) != nil) {
        [[chunkArray chunkAtIndex:chunkNumber] empty];
    }
}

- (SimulChunk *)previousChunkOfType:(id)type
{
    ChunkArray *chunkArray;
    SimulChunk *chunk;
    int currentChunkNumber;

    currentChunkNumber = [simulator currentChunkNumber];    
    chunkArray = [userEntities objectForKey:type];
    
    chunk = (SimulChunk *)[chunkArray chunkAtIndex:currentChunkNumber - 1];
    return chunk;
}

- (SimulChunk *)chunkOfType:(id)type
{
    ChunkArray *chunkArray;
    SimulChunk *chunk;
    int currentChunkNumber;

    currentChunkNumber = [simulator currentChunkNumber];    
    chunkArray = [userEntities objectForKey:type];
    
    if (chunkArray == nil) {
        chunkArray = [[ChunkArray alloc] init];
        [chunkArray setFirstIndex:currentChunkNumber];
        [userEntities setObject:chunkArray forKey:type];
        chunk = [SimulChunk chunkWithEntityType:type
                                      container:self];
        [chunk setStartTime:[simulator currentTime]];
        [chunk setPreviousChunkIncompleteEntities:[NSArray array]];
        [chunkArray addChunk:chunk];
        [chunkArray release];
    } else {
        chunk = (SimulChunk *)[chunkArray chunkAtIndex:currentChunkNumber];
        if (chunk == nil) {
            SimulChunk *previousChunk;
            previousChunk = (SimulChunk *)
                            [chunkArray chunkAtIndex:currentChunkNumber - 1];
            if (previousChunk == nil || [previousChunk isLastChunk]) {
                return nil;
            }
            chunk = [SimulChunk chunkWithEntityType:type
                                          container:self];
            [chunk setStartTime:[previousChunk endTime]];
            [chunk setPreviousChunkIncompleteEntities:
                                           [previousChunk incompleteEntities]];

            [chunkArray addChunk:chunk];
        }
    }
    
    return chunk;
}


- (void)newEventWithType:(id)type
                   value:(id)value
               withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk newEventEvent:event value:value];
}

- (void)setUserStateOfType:(PajeEntityType *)type
                   toValue:(id)value
                 withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk setStateEvent:event value:value];
}

- (void)pushUserStateOfType:(PajeEntityType *)type
                      value:(id)value
                  withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk pushStateEvent:event value:value];
}

- (void)popUserStateOfType:(PajeEntityType *)type
                 withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk popStateEvent:event];
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

- (void)setUserVariableOfType:(PajeVariableType *)type
                      toValue:(id)value
                    withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk setVariableEvent:event
                      value:value];
}

- (void)addUserVariableOfType:(PajeVariableType *)type
                        value:(id)value
                    withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk addVariableEvent:event
                      value:value];
}

- (void)subUserVariableOfType:(PajeVariableType *)type
                        value:(id)value
                    withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk subVariableEvent:event
                      value:value];
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
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk startLinkEvent:event
                    value:value
          sourceContainer:cont
                      key:key];
}

- (void)endUserLinkOfType:(PajeEntityType *)type
                    value:(id)value
            destContainer:(PajeContainer *)cont
                      key:(id)key
                withEvent:(PajeEvent *)event
{
    SimulChunk *chunk;

    chunk = [self chunkOfType:type];
    if (![chunk isActive]) return;

    [chunk endLinkEvent:event
                  value:value
          destContainer:cont
                    key:key];
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
    //[userEntities removeAllObjects];
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)type
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
{
    ChunkArray *chunkArray;
    NSEnumerator *enumerator;
    chunkArray = [userEntities objectForKey:type];
    BOOL voltou;

    voltou = NO;
    while (!voltou) {
NS_DURING
        if (![self isStopped] && [end isLaterThanDate:[self endTime]]) {
            [simulator getChunksUntilTime:end];
        }
        enumerator = [chunkArray enumeratorOfEntitiesFromTime:start
                                                       toTime:end];
        voltou = YES;
NS_HANDLER
        NSString *exceptionName;
        exceptionName = [localException name];
        if (![exceptionName isEqual:@"PajeMissingChunkException"]) 
            [localException raise];
        [[NSNotificationCenter defaultCenter]
                      postNotificationName:@"PajeChunkNotInMemoryNotification"
                                    object:self
                                  userInfo:[localException userInfo]];
NS_ENDHANDLER
    }
    [SimulChunk emptyLeastRecentlyUsedChunks];
    return enumerator;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)type
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
{
    ChunkArray *chunkArray;
    NSEnumerator *enumerator;
    chunkArray = [userEntities objectForKey:type];
    BOOL voltou;

    voltou = NO;
    while (!voltou) {
NS_DURING
        if (![self isStopped] && [end isLaterThanDate:[self endTime]]) {
            [simulator getChunksUntilTime:end];
        }
        enumerator = [chunkArray enumeratorOfCompleteEntitiesFromTime:start
                                                               toTime:end];
        voltou = YES;
NS_HANDLER
        NSString *exceptionName;
        exceptionName = [localException name];
        if (![exceptionName isEqual:@"PajeMissingChunkException"]) 
            [localException raise];
        [[NSNotificationCenter defaultCenter]
                      postNotificationName:@"PajeChunkNotInMemoryNotification"
                                    object:self
                                  userInfo:[localException userInfo]];
NS_ENDHANDLER
    }
    [SimulChunk emptyLeastRecentlyUsedChunks];
    return enumerator;
}


- (id)chunkState
{
    NSMutableDictionary *state;
    state = [NSMutableDictionary dictionary];

    if (lastTime != nil) [state setObject:lastTime forKey:@"_lastTime"];
    [state setObject:[NSNumber numberWithInt:logicalTime]
              forKey:@"_logicalTime"];

    return state;
}

- (void)setChunkState:(id)obj
{
    NSDictionary *state = (NSDictionary *)obj;

    [self setLastTime:[state objectForKey:@"_lastTime"]];
    [self setLogicalTime:[[state objectForKey:@"_logicalTime"] intValue]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [NSException raise:@"SimulContainer should not be encoded" format:nil];
}
@end
