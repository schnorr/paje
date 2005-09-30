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
    id entity;
    id subContainer;
    NSEnumerator *subEnum;

    if (lastTime != nil) {
        return;
    }
    [self setLastTime:[event time]];

    while ((entity = [self popEntity]) != nil) {
        /*if ([entity isKindOfClass:[UserLink class]])
            if ([entity destContainer] == nil)
                [entity setDestContainer:self destEvent:event];
            else
                [entity setSourceContainer:self sourceEvent:event];
        else*/
            [entity setEndEvent:event];
//NSLog(@"stop %@ with event %@ = %@ st=%@ et=%@", self, event, entity, [entity startTime], [entity endTime]);
        if (![entity isKindOfClass:[UserLink class]])
        [simulator outputEntity:entity];
    }

    subEnum = [subContainers objectEnumerator];
    while ((subContainer = [subEnum nextObject]) != nil) {
        [subContainer stopWithEvent:event];
    }
}

- (id)entityOfType:(id)type
{
    id entity = [userEntities objectForKey:type];
    
    if (![entity isKindOfClass:[NSArray class]]) {
        return entity; // can be nil
    }
    
    return [(NSArray *)entity lastObject];
}

- (void)setEntity:(id)entity ofType:(id)type
{
    id oldEntity = [userEntities objectForKey:type];

    if (oldEntity != nil && [oldEntity isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *array = (NSMutableArray *)oldEntity;
        unsigned count = [array count];
        if ([entity respondsToSelector:@selector(setImbricationLevel:)]) {
            [entity setImbricationLevel:(count>0) ? count-1 : 0];
        }
        if (count == 0) {
            [array addObject:entity];
        } else {
            [array replaceObjectAtIndex:count-1 withObject:entity];
        }
    } else {
        [userEntities setObject:entity forKey:type];
    }
}

- (void)pushEntity:(id)entity ofType:(id)type
{
    NSMutableArray *array = nil;
    id oldEntity = [userEntities objectForKey:type];

    if (oldEntity == nil) {
        [userEntities setObject:entity forKey:type];
    } else if ([oldEntity isKindOfClass:[NSMutableArray class]]) {
        array = (NSMutableArray *)oldEntity;
        [array addObject:entity];
    } else {
        array = [NSMutableArray arrayWithObjects:oldEntity, entity, nil];
        [userEntities setObject:array forKey:type];
    }
    if ([entity respondsToSelector:@selector(setImbricationLevel:)]) {
        if (array != nil) {
            [entity setImbricationLevel:[array count]-1];
        } else {
            [entity setImbricationLevel:0];
        }
    }
}

- (id)popEntityOfType:(id)type
{
    NSMutableArray *array;
    id entity = [userEntities objectForKey:type];

    if (entity) {
        if ([entity isKindOfClass:[NSMutableArray class]]) {
            array = (NSMutableArray *)entity;
            entity = [array lastObject];
            if (entity) {
                [[entity retain] autorelease];
                [array removeLastObject];
            }
        } else {
            [[entity retain] autorelease];
            [userEntities removeObjectForKey:type];
        }
    }

    return entity;
}

- (id)popEntity
{
    NSArray *entityTypes;
    NSMutableArray *entities;
    id type;
    id entity;

retry:
    entityTypes = [userEntities allKeys];
    if ([entityTypes count] == 0)
        return nil;

    type = [entityTypes objectAtIndex:0];
    entity = [userEntities objectForKey:type];

    if (entity) {
        if ([entity isKindOfClass:[NSMutableArray class]]) {
            entities = (NSMutableArray *)entity;
            entity = [entities lastObject];
            if (entity) {
                [[entity retain] autorelease];
                [entities removeLastObject];
            } else {
                [userEntities removeObjectForKey:type];
                goto retry;
            }
        } else {
            [[entity retain] autorelease];
            [userEntities removeObjectForKey:type];
        }
    }

    return entity;
}

- (void)setUserStateOfType:(id)type
                   toValue:(id)value
                 withEvent:(PajeEvent *)event
{
    UserState *currentUserState, *newUserState;

    newUserState = [UserState stateOfType:type
                                    value:value
                                container:self
                               startEvent:event];

    currentUserState = [self entityOfType:type];
    if (currentUserState != nil) {
        [currentUserState setEndEvent:event];
        //[simulator entityChangedEndTime:currentUserState];
        [simulator outputEntity:currentUserState];
    }

    [self setEntity:newUserState ofType:type];

    //[simulator outputEntity:newUserState];
}

- (void)pushUserStateOfType:(PajeEntityType *)type
                      value:(id)value
                  withEvent:(PajeEvent *)event
{
    UserState *newUserState;

    newUserState = [UserState stateOfType:type
                                    value:value
                                container:self
                               startEvent:event];

    [self pushEntity:newUserState ofType:type];

//    [simulator outputEntity:newUserState];
}

- (void)popUserStateOfType:(id)type
                 withEvent:(PajeEvent *)event
{
    UserState *currentUserState;
    UserState *newCurrentUserState;

    currentUserState = [self popEntityOfType:type];
    if (currentUserState != nil) {
        [currentUserState setEndEvent:event];
        [simulator outputEntity:currentUserState];
//        [simulator entityChangedEndTime:currentUserState];
        newCurrentUserState = [self entityOfType:type];
        if (newCurrentUserState != nil) {
            [newCurrentUserState addInnerState:currentUserState];
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

    currentUserState = [self entityOfType:type];
    if (currentUserState) {
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

    currentUserState = [self entityOfType:type];
    if (currentUserState) {
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
            sourceContainer:(PajeContainer *)sourceContainer
                        key:(id)key
                  withEvent:(PajeEvent *)event
{
    NSMutableArray *pendingLinks = [userEntities objectForKey:type];
    UserLink *link = nil;
    unsigned index = 0;
    BOOL found = NO;
    int sourceLogicalTime;
    
    sourceLogicalTime = [(SimulContainer *)sourceContainer logicalTime];

    sourceLogicalTime++;
    [(SimulContainer *)sourceContainer setLogicalTime:sourceLogicalTime];
    
    if (!pendingLinks) {
        pendingLinks = [NSMutableArray array];
        [userEntities setObject:pendingLinks forKey:type];
    } else {
        unsigned count = [pendingLinks count];
        for (index = 0; index < count; index++) {
            link = [pendingLinks objectAtIndex:index];
            if ([link canBeStartedWithValue:value key:key]) {
                found = YES;
                break;
            }
        }
    }

    if (found) {
        [link setSourceContainer:sourceContainer sourceEvent:event];
        [link setStartLogicalTime:sourceLogicalTime];
        if ([(SimulContainer *)[link destContainer] logicalTime] < sourceLogicalTime+1) {
            [(SimulContainer *)[link destContainer] setLogicalTime:sourceLogicalTime+1];
            [link setEndLogicalTime:sourceLogicalTime+1];
        }
        [simulator outputEntity:link];
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
            destContainer:(PajeContainer *)destContainer
                      key:(id)key
                withEvent:(PajeEvent *)event
{
    NSMutableArray *pendingLinks = [userEntities objectForKey:type];
    UserLink *link = nil;
    unsigned index = 0;
    BOOL found = NO;
    int destLogicalTime;
    
    destLogicalTime = [(SimulContainer *)destContainer logicalTime];

    destLogicalTime++;
    [(SimulContainer *)destContainer setLogicalTime:destLogicalTime];

    if (pendingLinks == nil) {
        pendingLinks = [NSMutableArray array];
        [userEntities setObject:pendingLinks forKey:type];
    } else {
        unsigned count = [pendingLinks count];
        for (index = 0; index < count; index++) {
            link = [pendingLinks objectAtIndex:index];
            if ([link canBeEndedWithValue:value key:key]) {
                found = YES;
                break;
            }
        }
    }

    if (found) {
        int lt = [link startLogicalTime]+1;
        if (lt > destLogicalTime) {
            destLogicalTime = lt;
            [(SimulContainer *)destContainer setLogicalTime: lt];
        }
        [link setEndLogicalTime:destLogicalTime];
        [link setDestContainer:destContainer destEvent:event];
        [simulator outputEntity:link];
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
    NSDebugMLLog(@"tim", @"encoding %@ (lt=%@ %d ue=%@)",
                         self, lastTime, logicalTime, userEntities);
    [coder encodeObject:lastTime];
    [coder encodeObject:[NSNumber numberWithInt:logicalTime]];
    [coder encodeObject:userEntities];
}

- (void)decodeCheckPointWithCoder:(NSCoder *)coder
{
    [self setLastTime:[coder decodeObject]];
    [self setLogicalTime:[[coder decodeObject] intValue]];
    Assign(userEntities, [coder decodeObject]);
//FIXME: entities are decoded without container (containers cannot be decoded),
//       must set it.
{int i;
NSArray *keys= [userEntities allValues];
for (i=0;i<[keys count];i++) {
if (![[keys objectAtIndex:i] isKindOfClass:[NSArray class]]) {
[[keys objectAtIndex:i] setContainer:self];
} else {
int j;
NSArray *v= [keys objectAtIndex:i];
for (j=0;j<[v count];j++) {
[[v objectAtIndex:j] setContainer:self];
}
}
}
}
    NSDebugMLLog(@"tim", @"decoded %@ (lt=%@ %d ue=%@)",
                         self, lastTime, logicalTime, userEntities);
}

@end
