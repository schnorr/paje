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


#include "AggregatingChunkArray.h"
#include "AggregatingChunk.h"

#include "../General/Macros.h"
#include "../PajeSimulator/SimulContainer.h"


#define ENTITIES_IN_AGGREGATED_CHUNK 1000

@interface AggregatingVariableChunkArray : AggregatingChunkArray
@end
@implementation AggregatingVariableChunkArray

- (void)finishChunk
{
    EntityChunk *chunk;

    chunk = [self lastChunk];
    [chunk freeze];
}
@end

@implementation AggregatingChunkArray

+ (id)arrayWithEntityType:(PajeEntityType *)eType
                container:(PajeContainer *)c
               dataSource:(PajeFilter *)source
      aggregatingDuration:(double)duration
{
    Class arrayClass;
    switch ([eType drawingType]) {
    case PajeEventDrawingType:
        arrayClass = self;
        break;
    case PajeStateDrawingType:
        arrayClass = self;
        break;
    case PajeVariableDrawingType:
        arrayClass = [AggregatingVariableChunkArray class];
        break;
    case PajeLinkDrawingType:
        arrayClass = self;
        break;
    default:
        NSLog(@"Don't know how to aggregate %@", eType);
        return nil;
    }
    return [[[arrayClass alloc] initWithEntityType:eType
                                         container:c
                                        dataSource:source
                               aggregatingDuration:duration] autorelease];
}

- (id)initWithEntityType:(PajeEntityType *)eType
               container:(PajeContainer *)c
              dataSource:(PajeFilter *)source
     aggregatingDuration:(double)duration
{
    self = [super init];
    if (self != nil) {
        dataSource = source; // not retained
        entityType = [eType retain];
        container = [c retain];
        aggregationDuration = duration;
    }
    return self;
}

- (void)dealloc
{
    Assign(entityType, nil);
    Assign(container, nil);
    dataSource = nil;
    [super dealloc];
}

- (NSEnumerator *)originalEnumeratorFromTime:(NSDate *)t1
                                      toTime:(NSDate *)t2
                                 minDuration:(double)duration
{
    return [dataSource enumeratorOfEntitiesTyped:entityType
                                     inContainer:container
                                        fromTime:t1
                                          toTime:t2
                                     minDuration:duration];
}

- (NSEnumerator *)originalCompleteEnumeratorFromTime:(NSDate *)t1
                                              toTime:(NSDate *)t2
                                         minDuration:(double)duration
{
    return [dataSource enumeratorOfCompleteEntitiesTyped:entityType
                                             inContainer:container
                                                fromTime:t1
                                                  toTime:t2
                                             minDuration:duration];
}

- (BOOL)aggregationFinished
{
    return finished;
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)startTime
                                        toTime:(NSDate *)endTime
{
    NSUInteger startIndex;
    NSUInteger endIndex;
    NSUInteger index;
    MultiEnumerator *multiEnum;
    EntityChunk *chunk;
    int chunkCount;
    NSDate *lastTime;
    
    lastTime = [(AggregatingChunk *)[self lastChunk] latestTime];

    // if not yet aggregated until endTime, continue aggregation
    if (![self aggregationFinished]
        && (lastTime == nil || [endTime isLaterThanDate:lastTime])) {
        [self aggregateEntitiesUntilTime:
               [endTime addTimeInterval:2*aggregationDuration]];
    }

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    // chunks are indexed by startTime
    endIndex = [chunks indexOfLastObjectBeforeValue:endTime];
    if (endIndex == NSNotFound) {
        // no chunk starts before endTime
        return nil;
    }
    startIndex = [chunks indexOfLastObjectNotAfterValue:startTime];
    if (startIndex == NSNotFound) {
        // all chunks start after startTime
        startIndex = 0;
    }
    if (startIndex > endIndex) {
        startIndex = endIndex;
    }

    chunk = [chunks objectAtIndex:endIndex];
    if ([chunk isZombie]) {
        [self refillChunkAtIndex:endIndex];
    }

    // if only one chunk involved, it can enumerate for us.
    if (startIndex == endIndex) {
        return [chunk enumeratorOfEntitiesFromTime:startTime toTime:endTime];
    }

    // there are multiple chunks involved -- get complete and incomplete
    // entities from last chunk, all complete from intermediary chunks and some
    // complete entities from first chunk.
    multiEnum = [MultiEnumerator enumerator];

    [multiEnum addEnumerator:[chunk enumeratorOfEntitiesBeforeTime:endTime]];

    for (index = endIndex - 1; index > startIndex; index--) {
        chunk = [chunks objectAtIndex:index];
        if ([chunk isZombie]) {
            [self refillChunkAtIndex:index];
        }
        [multiEnum addEnumerator:[chunk enumeratorOfAllCompleteEntities]];
    }

    chunk = [chunks objectAtIndex:startIndex];
    if ([chunk isZombie]) {
        [self refillChunkAtIndex:startIndex];
    }
    [multiEnum addEnumerator:
                    [chunk enumeratorOfCompleteEntitiesFromTime:startTime]];

    return multiEnum;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesFromTime:(NSDate *)startTime
                                             untilTime:(NSDate *)endTime
{
    NSUInteger startIndex;
    NSUInteger endIndex;
    NSUInteger index;
    MultiEnumerator *multiEnum;
    EntityChunk *chunk;
    int chunkCount;

    [self aggregateEntitiesUntilTime:endTime];

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    // chunks are indexed by startTime
    endIndex = [chunks indexOfLastObjectBeforeValue:endTime];
    if (endIndex == NSNotFound) {
        // no chunk starts before endTime
        return nil;
    }
    startIndex = [chunks indexOfLastObjectNotAfterValue:startTime];
    if (startIndex == NSNotFound) {
        // all chunks start after startTime
        startIndex = 0;
    }
    if (startIndex > endIndex) {
        startIndex = endIndex;
    }

    chunk = [chunks objectAtIndex:startIndex];
    if ([chunk isZombie]) {
        [self refillChunkAtIndex:startIndex];
    }

    // one chunk: it can enumerate
    if (startIndex == endIndex) {
        return [chunk fwEnumeratorOfCompleteEntitiesFromTime:startTime
                                                   untilTime:endTime];
    }

    // multiple chunks: get some entities from first chunk,
    // all from intermediary chunks and some from last chunk
    multiEnum = [MultiEnumerator enumerator];

    [multiEnum addEnumerator:
                    [chunk fwEnumeratorOfCompleteEntitiesFromTime:startTime]];

    for (index = startIndex + 1; index < endIndex; index++) {
        chunk = [chunks objectAtIndex:index];
        if ([chunk isZombie]) {
            [self refillChunkAtIndex:index];
        }
        [multiEnum addEnumerator:[chunk fwEnumeratorOfAllCompleteEntities]];
    }

    chunk = [chunks objectAtIndex:endIndex];
    if ([chunk isZombie]) {
        [self refillChunkAtIndex:endIndex];
    }
    [multiEnum addEnumerator:
                    [chunk fwEnumeratorOfCompleteEntitiesUntilTime:endTime]];

    return multiEnum;
}

- (void)createChunk
{
    EntityChunk *chunk;

    chunk = [AggregatingChunk chunkWithEntityType:entityType
                                        container:container
                              aggregationDuration:aggregationDuration];
    if ([chunks count] > 0) {
        EntityChunk *previousChunk;
        previousChunk = [chunks lastObject];
        [chunk setStartTime:[previousChunk endTime]];
    } else {
        [chunk setStartTime:[container startTime]];
    }
    [chunks addObject:chunk];
}


- (AggregatingChunk *)lastChunk
{
    if ([chunks count] == 0) {
        [self createChunk];
    }
    return [chunks lastObject];
}


// reached end of last chunk in this entityType/container
- (void)finishAggregation
{
    EntityChunk *chunk;

    if ([self aggregationFinished]) {
        return;
    }

    chunk = [self lastChunk];

    [chunk setIncompleteEntities:nil];
    [chunk setEndTime:[container endTime]];
    [chunk freeze];
    
    finished = YES;
}


- (void)finishChunk
{
    AggregatingChunk *chunk;
    NSDate *chunkEndTime;

    // set end time to that of last entity    
    chunk = [self lastChunk];
    chunkEndTime = [chunk continuationTime];

    // set incomplete entities as those that cross endtime in lower
    // aggregation level.
    NSEnumerator *en;
    NSArray *incomplete;
    [chunkEndTime retain]; // sometimes there is a "missing chunk" exception below
    en = [self originalEnumeratorFromTime:chunkEndTime
                                   toTime:chunkEndTime
                              minDuration:aggregationDuration/2];
    [chunkEndTime release];
    incomplete = [en allObjects];
    [chunk setIncompleteEntities:incomplete];

    // chunk aggregator should be empty for this to work
    [chunk freeze];
}


- (void)aggregateEntitiesUntilTime:(NSDate *)time
{
    PajeEntity *entity;
    NSEnumerator *en;
    AggregatingChunk *chunk;

    if ([self aggregationFinished]) {
        return;
    }
    
    chunk = [self lastChunk];

    if ([time isEarlierThanDate:[chunk latestTime]]) {
        return;
    }
    
    if ([(SimulContainer *)container isStopped]
        && [time isLaterThanDate:[container endTime]]) {
        time = [container endTime];
    }

    NSDate *ct = [chunk continuationTime];
    [ct retain]; // sometimes the method below releases ct (missing chunk except)
    en = [self originalCompleteEnumeratorFromTime:ct//[chunk continuationTime]
                                           toTime:time
                                      minDuration:aggregationDuration/2];
    [ct release];

    while ((entity = [en nextObject]) != nil) {
        if ([chunk canFinishBeforeEntity:entity]) {
            [self finishChunk];
            [self createChunk];
            chunk = [self lastChunk];
        }

        [chunk addEntity:entity];
    }

    if ([(SimulContainer *)container isStopped] 
        && ![time isEarlierThanDate:[container endTime]]) {
        [self finishAggregation];
    } else {
        [chunk setLatestTime:time];
        en = [self originalEnumeratorFromTime:time
                                       toTime:time
                                  minDuration:aggregationDuration/2];
        [chunk setIncompleteEntities:[en allObjects]];
    }
}

- (void)refillChunkAtIndex:(int)chunkIndex
{
    EntityChunk *chunk;

    chunk = [self chunkAtIndex:chunkIndex];

    [chunk activate];

    PajeEntity *entity;
    NSEnumerator *en;

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    en = [self originalCompleteEnumeratorFromTime:[chunk startTime]
                                           toTime:[chunk endTime]
                                      minDuration:aggregationDuration/2];

    while ((entity = [en nextObject]) != nil) {
        [chunk addEntity:entity];
    }

    [chunk freeze];

    [pool release];
}
@end
