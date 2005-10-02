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
  /*
   * Encapsulate.m
   *
   * Component that reads individual events, states and communications
   * and encapsulates them for grouped access.
   *
   * 19970423 BS  creation
   */

#include "Encapsulate.h"
#include "../General/TimeList.h"
#include "../General/MultiEnumerator.h"
#include "../General/PajeEntity.h"
#include "../General/Macros.h"
#include "../General/NSDate+Additions.h"

#include "StateAggregator.h"

@implementation Encapsulate

- (id)initWithController:(PajeTraceController *)c
{
    [super initWithController:c];
    
    traceChanged = NO;
    timerActive = NO;

    entityLists = [[NSMutableDictionary alloc] init];
    startTimeInMemory = nil;
    endTimeInMemory = nil;

    return self;
}

- (void)dealloc
{
    [entityLists release];
    [startTimeInMemory release];
    [endTimeInMemory release];

    [super dealloc];
}

- (void)reset
/*"Forget everything that has been done, start all over again."*/
{
    traceChanged = YES;
    if (!timerActive) {
        [self performSelector:@selector(timeElapsed:) withObject:self afterDelay:0];
        timerActive = YES;
    }
}

- (void)inputEntity:(id)entity
/*"There's new data in the input port. Encapsulate it."*/
{
    [self addEntity:entity];
    traceChanged = YES;

    if (!timerActive) {
        [self performSelector:@selector(timeElapsed:)
                   withObject:self
                   afterDelay:0.0];
        timerActive = YES;
    }
}

- (void)addEntity:(PajeEntity *)entity
{
    PajeEntityType *entityType = [entity entityType];
    NSMutableDictionary *dict = [entityLists objectForKey:entityType];
    PajeContainer *container = [entity container];
    TimeList *list;
    
    //KLUDGE to identify last date in memory.
    // (doesn't work if events are not seen)
    // FIXME this should be calculated on demand
    if (1 || [entity drawingType] == PajeEventDrawingType) {
        NSDate *time = [entity lastTime];
        if(endTimeInMemory == nil || [time isLaterThanDate:endTimeInMemory]) {
            Assign(endTimeInMemory, time);
        }
        time = [entity firstTime];
        if (startTimeInMemory == nil 
            || [time isEarlierThanDate:startTimeInMemory]) {
            Assign(startTimeInMemory, time);
        }
    }
    //ENDKLUDGE

    if (!dict) {
        // unknown entity type -- create a new dict for it
        dict = [[NSMutableDictionary alloc] init];
        [entityLists setObject:dict forKey:entityType];
        [dict release];
    }

    list = [dict objectForKey:container];

    if (!list) {
        // unknown container for this entity type -- create a new list for it
        list = [[TimeList alloc] init];
        [dict setObject:list forKey:container];
        [list release]; // dict is retaining it
    }

    [list addObject:entity];
}

- (void)entityChangedEndTime:(id<PajeEntity>)entity
{
    PajeEntityType *entityType = [entity entityType];
    NSMutableDictionary *dict = [entityLists objectForKey:entityType];
    id container = [entity container];
    TimeList *list;

    list = [dict objectForKey:container];

    if (!list) {
        NSWarnMLog(@"entity %@ not found", entity);
        return;
    }

    [list objectChangedEndTime:entity];
}


- (void)send
/*"notifies that data has changed."*/
{
    // only send trace if it is already initialized
    // (or else space time diagram will think trace has no data, and the
    // lazy reading will not work well)
    // FIXME should send more specific notification
    [self hierarchyChanged];
    traceChanged = NO;
    [self performSelector:@selector(timeElapsed:) withObject:self afterDelay:0.5];
    timerActive = YES;
}

- (void)timeElapsed:(id)sender
/*"Called by the timer; notifies if necessary."*/
{
    timerActive = NO;
    if (traceChanged) {
        [self send];
    }
}


- (NSDate *)time
{
    return [self startTime];
}

- (NSDate *)firstTime
{
    return [self startTime];
}

- (NSDate *)lastTime
{
    return [self endTime];
}

- (NSDate *)startTimeInMemory
{
    return startTimeInMemory;
}

- (NSDate *)endTimeInMemory
{
    return endTimeInMemory;
}

- (void)verifyStartTime:(NSDate *)start endTime:(NSDate *)end
{
    NSDebugMLLog(@"tim", @"[%@:%@] [%@:%@]",
                start, end, startTimeInMemory, endTimeInMemory);
    if ([start isEarlierThanDate:startTimeInMemory]
         || ![endTimeInMemory isLaterThanDate:end]) {
        NSDictionary *userInfo;
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            start, @"StartTime",
            end, @"EndTime",
            nil];
        NSDebugMLLog(@"tim", @"notify [%@:%@] [%@:%@]",
                    start, end, startTimeInMemory, endTimeInMemory);
        [[NSNotificationCenter defaultCenter]
                      postNotificationName:@"PajeTraceNotInMemoryNotification"
                                    object:self
                                  userInfo:userInfo];
    }
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
{
    NSDictionary *dict;
    TimeList *list;
    NSEnumerator *subcontainerEnum;
    id subcontainer;
    MultiEnumerator *multiEnum;
    PajeEntityType *parentType;
    
    [self verifyStartTime:start endTime:end];
    
    dict = [entityLists objectForKey:entityType];
    // if container directly contains entityType's
    list = [dict objectForKey:container];
    if (list != nil) {
        multiEnum = [MultiEnumerator enumerator];
        [multiEnum addEnumerator:[list timeEnumeratorFromTime:start
                                                       toTime:end]];
        [multiEnum addEnumerator:
                           [container enumeratorOfEntitiesTyped:entityType
                                                       fromTime:start
                                                         toTime:end]];
        return multiEnum;
    }

    // if container should contain entityType directly, we have no entities!
    if ([[entityType containerType] isEqual:[container entityType]]) {
        return [container enumeratorOfEntitiesTyped:entityType
                                           fromTime:start
                                             toTime:end];
    }
    
    // container does not contain entityType's directly.
    // Try containers in-between.
    parentType = [entityType containerType];
    subcontainerEnum = [self enumeratorOfContainersTyped:parentType
                                             inContainer:container];
    multiEnum = [MultiEnumerator enumerator];
    while ((subcontainer = [subcontainerEnum nextObject]) != nil) {
        list = [dict objectForKey:subcontainer];
        if (list != nil) {
            [multiEnum addEnumerator:[list timeEnumeratorFromTime:start
                                                           toTime:end]];
            [multiEnum addEnumerator:
                               [container enumeratorOfEntitiesTyped:entityType
                                                           fromTime:start
                                                             toTime:end]];

        }
    }
    return multiEnum;
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
    NSEnumerator *en;
    
    if (0 && minDuration > 1e-6) {
    en = [self enumeratorOfEntitiesTyped:entityType
                             inContainer:container
                                fromTime:[start addTimeInterval:-minDuration]
                                  toTime:[end addTimeInterval:minDuration]
                             minDuration:minDuration/2];
    } else
    en = [self enumeratorOfEntitiesTyped:entityType
                             inContainer:container
                                fromTime:[start addTimeInterval:-minDuration]
                                  toTime:[end addTimeInterval:minDuration]];
    if (minDuration <= 1e-6
        || ([entityType drawingType] != PajeStateDrawingType
            && [entityType drawingType] != PajeEventDrawingType)) {
        return en;
    }
    EntityAggregator *aggregator;
    PajeEntity *state;
    NSMutableArray *filtered;
    PajeEntity *aggregate;
    
    if ([entityType drawingType] == PajeStateDrawingType) {
        aggregator = [StateAggregator aggregatorWithMaxDuration:minDuration];
    } else {
        aggregator = [EventAggregator aggregatorWithMaxDuration:minDuration];
    }
    filtered = [NSMutableArray array];
    en = [[en allObjects] reverseObjectEnumerator];
    while ((state = [en nextObject]) != nil) {
        if (![aggregator addEntity:state]) {
            aggregate = [aggregator aggregate];
            if (aggregate != nil) {
                [filtered addObject:aggregate];
                if (![aggregator addEntity:state]) {
                    [filtered addObject:state];
                }
            } else {
                [filtered addObject:state];
            }
        }
    }
    aggregate = [aggregator aggregate];
    if (aggregate != nil) {
        [filtered addObject:aggregate];
    }
    return [filtered reverseObjectEnumerator];
}

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container
{
    NSEnumerator *ienum;
    PajeContainer *instance;
    NSMutableArray *instancesInContainer = [NSMutableArray array];

    if ([entityType isContainer]) {
        PajeContainerType *containerType = (PajeContainerType *)entityType;
        ienum = [[containerType allInstances] objectEnumerator];
        while ((instance = [ienum nextObject]) != nil) {
            if ([instance isContainedBy:container]) {
                [instancesInContainer addObject:instance];
            }
        }
    }
//    return [[instancesInContainer sortedArrayUsingSelector:@selector(compare:)]
//                  objectEnumerator];
    return [instancesInContainer objectEnumerator];
}


- (void)removeObjectsBeforeTime:(NSDate *)time
{
    NSEnumerator *e;
    NSMutableDictionary *d;

    if (![time isLaterThanDate:startTimeInMemory]) {
        return;
    }

    e = [entityLists objectEnumerator];
    while ((d = [e nextObject]) != nil) {
#if 0
        //xxx waiting for NSDictionary to implement makeObjectsPerformSelector:
        [d makeObjectsPerformSelector:@selector(removeObjectsBeforeTime:) withOb
ject:time];
#else
        NSEnumerator *e2 = [d objectEnumerator];
        TimeList *l;
        while ((l = [e2 nextObject]) != nil) {
            [l removeObjectsBeforeTime:time];
        }
#endif
    }

    Assign(startTimeInMemory, time);

    if ([time isLaterThanDate:endTimeInMemory]) {
        Assign(endTimeInMemory, time);
    }
}

- (void)removeObjectsAfterTime:(NSDate *)time
{
    NSEnumerator *e;
    NSMutableDictionary *d;

    if (![time isEarlierThanDate:endTimeInMemory]) {
        return;
    }

    e = [entityLists objectEnumerator];
    while ((d = [e nextObject]) != nil) {
#if 0
        //xxx waiting for NSDictionary to implement makeObjectsPerformSelector:
        [d makeObjectsPerformSelector:@selector(removeObjectsAfterTime:) withObj
ect:time];
#else
        NSEnumerator *e2 = [d objectEnumerator];
        TimeList *l;
        while ((l = [e2 nextObject]) != nil) {
            [l removeObjectsAfterTime:time];
        }
#endif
    }

    Assign(endTimeInMemory, time);

    if ([time isEarlierThanDate:startTimeInMemory]) {
        Assign(startTimeInMemory, time);
    }
}


@end
