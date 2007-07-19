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

#include "AggregatingChunk.h"

#include "../General/Macros.h"

//#define ENTITIES_IN_AGGREGATED_CHUNK 1
#define ENTITIES_IN_AGGREGATED_CHUNK 1000


@interface AggregateStateChunk : AggregatingChunk
- (PajeEntity *)firstIncomplete;
@end
@interface AggregateVariableChunk : AggregateStateChunk
@end
@interface AggregateLinkChunk : AggregateStateChunk
@end

@implementation AggregatingChunk
+ (AggregatingChunk *)chunkWithEntityType:(PajeEntityType *)type
                                container:(PajeContainer *)pc
                      aggregationDuration:(double)duration
{
    Class class;
    switch ([type drawingType]) {
    case PajeEventDrawingType:
        class = [AggregateStateChunk class];
        break;
    case PajeStateDrawingType:
        class = [AggregateStateChunk class];
        break;
    case PajeLinkDrawingType:
        class = [AggregateLinkChunk class];
        break;
    case PajeVariableDrawingType:
        class = [AggregateVariableChunk class];
        break;
    default:
        NSWarnMLog(@"No support for creating chunk of type %@", type);
        class = nil;
    }

    return [[[class alloc] initWithEntityType:type
                                    container:pc
                          aggregationDuration:duration] autorelease];
}

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
     aggregationDuration:(double)duration
{
    self = [super initWithEntityType:type
                           container:pc];
    if (self != nil) {
        aggregationDuration = duration;
        Assign(aggregator, [EntityAggregator aggregatorForEntityType:type
                                                 aggregationDuration:duration]);
    }
    return self;
}

- (void)dealloc
{
    Assign(aggregator, nil);
    Assign(lastEntity, nil);
    Assign(latestTime, nil);
    [super dealloc];
}

- (PajeEntity *)firstIncomplete
{
    return nil;
}

- (BOOL)canFinishBeforeEntity:(PajeEntity *)entity
{
//[aggregator willEmptyBeforeEntity:entity]
    if ([self entityCount] >= ENTITIES_IN_AGGREGATED_CHUNK
        && [[entity endTime] isLaterThanDate:[lastEntity endTime]]
        && ([aggregator entityCount] == 0 || [entity duration] > [aggregator aggregationDuration])) {
        return YES;
    }
    return NO;
}

- (void)addEntity:(PajeEntity *)entity
{
    PajeEntity *aggregate;
    while ((aggregate = [aggregator aggregateEntity:entity]) != nil) {
        [super addEntity:aggregate];
        if (aggregate == entity) {
            break;
        }
    }
    //if (endTime == nil) {
        Assign(lastEntity, entity);
    //}
}

- (void)aggregateUntilTime:(NSDate *)time
{
    PajeEntity *entity;
    while ((entity = [aggregator aggregateBefore:time]) != nil) {
        [super addEntity:entity];
    }
}

- (void)setEndTime:(NSDate *)time
{
//NSLog(@"\n\n\nDONT CALL THIS (setEndTime)!!!\n\n\n");
//    [self setLastTime:time];
    [super setEndTime:time];
}

- (NSDate *)endTime
{
    NSDate *time;
    time = [super endTime];
    if (time != nil) {
        return time;
    }
    return [self latestTime];
}

- (NSDate *)continuationTime
{
    if (lastEntity != nil) {
        return [lastEntity endTime];
    } else {
        return [self startTime];
    }
}

- (NSDate *)latestTime
{
    return latestTime;
}

- (void)setLatestTime:(NSDate *)time
{
    [self aggregateUntilTime:[self continuationTime]];
    Assign(latestTime, time);
}

- (PajeEntity *)lastEntity
{
NSLog(@"\n\nSOMEONE IS CALLING lastEntity!!!\n\n");
    return lastEntity;
}

- (void)freeze
{
    [self aggregateUntilTime:[NSDate distantFuture]];
    Assign(aggregator, nil);
    if (endTime == nil) {
        Assign(endTime, [self continuationTime]);
    }
    //NSLog(@"freeze %f e%@ l%@", [aggregator aggregationDuration], endTime, lastTime);
    Assign(latestTime, nil);
    Assign(lastEntity, nil);
    [super freeze];
}

- (void)activate
{
    [super activate];
    Assign(aggregator, [EntityAggregator aggregatorForEntityType:entityType
                                             aggregationDuration:aggregationDuration]);
}

- (void)setIncompleteEntities:(NSArray *)array
{
    if ([aggregator entityCount] > 0) {
        NSMutableArray *notYetAggregated;
        EntityAggregator *newAggregator;
        PajeEntity *entity;
        notYetAggregated = [NSMutableArray array];
        newAggregator = [aggregator copy];
        while ((entity = [newAggregator aggregate]) != nil) {
            [notYetAggregated addObject:entity];
        }
        [newAggregator release];
        array = [array arrayByAddingObjectsFromArray:
                      [[notYetAggregated reverseObjectEnumerator] allObjects]];
    }
    [super setIncompleteEntities:array];
}

@end

@implementation AggregateStateChunk
- (BOOL)canEnumerate
{
    return chunkState != empty;
}

- (BOOL)canInsert
{
    return chunkState != empty;
}

- (void)empty
{
    if (chunkState == frozen) {
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

@implementation AggregateVariableChunk
- (void)setIncompleteEntities:(NSArray *)array
{
    if (incompleteEntities != nil) {
        [incompleteEntities release];
        incompleteEntities = nil;
    }
    if (array != nil) {
        NSEnumerator *en = [array objectEnumerator];
        NSDate *d = [self latestTime];
        PajeEntity *e;
        while ((e = [en nextObject]) != nil) {
            if (d == nil || [[e endTime] isLaterThanDate:d]) {
                Assign(incompleteEntities, [NSArray arrayWithObject:e]);
            }
        }
    }
}

@end
@implementation AggregateLinkChunk

- (BOOL)canFinishBeforeEntity:(PajeEntity *)entity
{
    if ([self entityCount] >= ENTITIES_IN_AGGREGATED_CHUNK
        && [[entity endTime] isLaterThanDate:[lastEntity endTime]] 
        && [aggregator entityCount] == 0) { //FIXME: there can be lots of aggregators, possibly never all empty.
        return YES;
    }
    return NO;
}


@end
