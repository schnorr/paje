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
#include "StateAggregator.h"

#include "../General/Macros.h"
#include "../PajeSimulator/SimulChunk.h"
#include "../PajeSimulator/SimulContainer.h"

@interface AggregatingEventChunkArray : AggregatingChunkArray
@end
@implementation AggregatingEventChunkArray

- (id)initWithEntityType:(PajeEntityType *)eType
               container:(PajeContainer *)c
              dataSource:(PajeFilter *)source
     aggregatingDuration:(double)duration
{
    self = [super initWithEntityType:eType
                           container:c
                          dataSource:source
                 aggregatingDuration:duration];
    if (self != nil) {
        Assign(aggregator, 
               [EventAggregator aggregatorWithAggregationDuration:duration]);
    }
    return self;
}

- (void)createChunk
{
    AggregateStateChunk *chunk;

    chunk = [[AggregateStateChunk alloc] initWithEntityType:entityType
               container:container];
    if ([chunks count] > 0) {
        [chunk setStartTime:[[chunks lastObject] endTime]];
    } else {
        [chunk setStartTime:[container startTime]];
    }
    // set an endTime, will be better set when chunk is finished
    [chunk setEndTime:[container endTime]];
    [chunks addObject:chunk];
    [chunk release];
}

- (EntityChunk *)lastChunk
{
    if ([chunks count] == 0) {
        [self createChunk];
    }
    return [chunks lastObject];
}

- (void)finishChunk
{
    AggregateStateChunk *chunk;
    NSDate *chunkEndTime;

    // set end time to that of last entity    
    chunk = (AggregateStateChunk *)[self lastChunk];
    chunkEndTime = [[chunk lastEntity] endTime];
    [chunk setEndTime:chunkEndTime];

    // set incomplete entities as those that cross endtime in lower
    // aggregation level.
    // REVER: tá correto isto? se sim, comentar melhor.
    NSEnumerator *en;
    NSArray *incomplete;
    en = [self originalEnumeratorFromTime:chunkEndTime
                                   toTime:chunkEndTime
                              minDuration:[aggregator aggregationDuration]/2];
    incomplete = [en allObjects];
    [chunk setIncompleteEntities:incomplete];
    [chunk freeze];
}

// reached end of last chunk in this entityType/container
- (void)finishAggregation
{
    AggregateStateChunk *chunk;
    PajeEntity *state;

    if ([self aggregationFinished]) {
        return;
    }

    chunk = (AggregateStateChunk *)[self lastChunk];
    while ((state = [aggregator aggregate]) != nil) {
        [chunk addEntity:state];
    }

    [chunk setEndTime:[[chunk lastEntity] endTime]];
    [chunk setIncompleteEntities:nil];
    [chunk freeze];
    
    Assign(lastEntity, nil);
    //Assign(aggregator, nil);
    finished = YES;
}

- (void)aggregateEntitiesUntilTime:(NSDate *)time
{
    PajeEntity *state;
    PajeEntity *aggregate;
    PajeEntity *newLastEntity = lastEntity;
    NSEnumerator *en;
    AggregateStateChunk *chunk;

    if ([self aggregationFinished]) {
        return;
    }
    
    if (lastTime != nil && [time isEarlierThanDate:lastTime]) {
        return;
    }
    
    if ([(SimulContainer *)container isStopped]
        && [time isLaterThanDate:[container endTime]]) {
        time = [container endTime];
    }
    en = [self originalCompleteEnumeratorFromTime:[[lastEntity endTime] addTimeInterval:-.000001]
                                           toTime:time
                                      minDuration:[aggregator aggregationDuration]/2];

    state = [en nextObject];

    // ignore states that have already been aggregated
    if (lastEntity != nil) {
        while (state != nil) {
            if ([[state endTime] isLaterThanDate:[lastEntity endTime]]) {
                break;
            }
            if (![[state endTime] isEarlierThanDate:[lastEntity endTime]])
            if ([[state startTime] isEarlierThanDate:[lastEntity startTime]]) {
                break;
            }
            state = [en nextObject];
        }
    }

    chunk = (AggregateStateChunk *)[self lastChunk];
    int entityCount = [chunk entityCount];
    while (state != nil) {
        if (entityCount >= 1000 
            && [aggregator entityCount] == 0
            && [[state endTime] isLaterThanDate:[newLastEntity endTime]]) {
            [self finishChunk];
            [self createChunk];
            chunk = (AggregateStateChunk *)[self lastChunk];
            entityCount = [chunk entityCount];
        }

        newLastEntity = state;

        while (![aggregator addEntity:state]) {
            entityCount++;
            aggregate = [aggregator aggregate];
            if (aggregate != nil) {
                [chunk addEntity:aggregate];
            } else {
                [chunk addEntity:state];
                break;
            }
        }

        state = [en nextObject];
    }
    Assign(lastTime, time);
    if ([(SimulContainer *)container isStopped] 
        && ![time isEarlierThanDate:[container endTime]]) {
        [self finishAggregation];
    } else {
        Assign(lastEntity, newLastEntity);

        while ((state = [aggregator aggregateBefore:time]) != nil) {
            [chunk addEntity:state];
        }
        [chunk setEndTime:time];

        NSMutableArray *incomplete = [NSMutableArray array];

        if ([aggregator entityCount] > 0) {
            EntityAggregator *newAggregator;
            newAggregator = [aggregator copy];
            while ((aggregate = [newAggregator aggregate]) != nil) {
                [incomplete addObject:aggregate];
            }
            [newAggregator release];
        }

        en = [self originalEnumeratorFromTime:time
                                       toTime:time
                                  minDuration:[aggregator aggregationDuration]/2];
        en = [[en allObjects] reverseObjectEnumerator];

        while ((state = [en nextObject]) != nil) {
            [incomplete addObject:state];
        }
        incomplete = [[incomplete reverseObjectEnumerator] allObjects];
        [chunk setIncompleteEntities:incomplete];
    }
}

- (void)refillChunkAtIndex:(int)chunkIndex
{
    AggregateStateChunk *chunk;

    chunk = (AggregateStateChunk *)[self chunkAtIndex:chunkIndex];
    NSAssert([chunk isZombie], @"refilling a non-empty chunk");

    [chunk activate];

    PajeEntity *state;
    PajeEntity *aggregate;
    NSEnumerator *en;

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    EntityAggregator *refillAggregator;
    refillAggregator = [EventAggregator aggregatorWithAggregationDuration:
                                            [aggregator aggregationDuration]];

//startTime deste é igual ao endTime do anterior. definir a quem pertence quem
//termina/comeca numa data certa
    en = [self originalCompleteEnumeratorFromTime:[chunk startTime]
                                           toTime:[chunk endTime]
                                      minDuration:[aggregator aggregationDuration]/2];

    while ((state = [en nextObject]) != nil) {
        while (![refillAggregator addEntity:state]) {
            aggregate = [refillAggregator aggregate];
            if (aggregate != nil) {
                [chunk addEntity:aggregate];
            } else {
                [chunk addEntity:state];
                break;
            }
        }
    }

    NSDate *incompleteStartTime = [[chunk firstIncomplete] startTime];
    while ((aggregate = [refillAggregator aggregate]) != nil) {
        if (incompleteStartTime == nil
            || ![[aggregate endTime] isEarlierThanDate:incompleteStartTime]) {
            [chunk addEntity:aggregate];
        }
    }
    [chunk freeze];

    [pool release];
}
@end
@interface AggregatingStateChunkArray : AggregatingChunkArray
/*
- (void)finishChunk;
- (void)createChunk;
- (EntityChunk *)lastChunk;
*/
@end
@implementation AggregatingStateChunkArray

- (id)initWithEntityType:(PajeEntityType *)eType
               container:(PajeContainer *)c
              dataSource:(PajeFilter *)source
     aggregatingDuration:(double)duration
{
    self = [super initWithEntityType:eType
                           container:c
                          dataSource:source
                 aggregatingDuration:duration];
    if (self != nil) {
        Assign(aggregator, 
               [StateAggregator aggregatorWithAggregationDuration:duration]);
    }
    return self;
}

- (void)createChunk
{
    AggregateStateChunk *chunk;

    chunk = [[AggregateStateChunk alloc] initWithEntityType:entityType
               container:container];
    if ([chunks count] > 0) {
        [chunk setStartTime:[[chunks lastObject] endTime]];
    } else {
        [chunk setStartTime:[container startTime]];
    }
    // set an endTime, will be better set when chunk is finished
    [chunk setEndTime:[container endTime]];
    [chunks addObject:chunk];
    [chunk release];
}

- (EntityChunk *)lastChunk
{
    if ([chunks count] == 0) {
        [self createChunk];
    }
    return [chunks lastObject];
}

- (void)finishChunk
{
    AggregateStateChunk *chunk;
    NSDate *chunkEndTime;

    // set end time to that of last entity    
    chunk = (AggregateStateChunk *)[self lastChunk];
    chunkEndTime = [[chunk lastEntity] endTime];
    [chunk setEndTime:chunkEndTime];

    // set incomplete entities as those that cross endtime in lower
    // aggregation level.
    // REVER: tá correto isto? se sim, comentar melhor.
    NSEnumerator *en;
    NSArray *incomplete;
    en = [self originalEnumeratorFromTime:chunkEndTime
                                   toTime:chunkEndTime
                              minDuration:[aggregator aggregationDuration]/2];
    incomplete = [en allObjects];
    [chunk setIncompleteEntities:incomplete];
    [chunk freeze];
}

// reached end of last chunk in this entityType/container
- (void)finishAggregation
{
    AggregateStateChunk *chunk;
    PajeEntity *state;

    if ([self aggregationFinished]) {
        return;
    }

    chunk = (AggregateStateChunk *)[self lastChunk];
    while ((state = [aggregator aggregate]) != nil) {
        [chunk addEntity:state];
    }

    [chunk setEndTime:[[chunk lastEntity] endTime]];
    [chunk setIncompleteEntities:nil];
    [chunk freeze];
    
    Assign(lastEntity, nil);
    //Assign(aggregator, nil);
    finished = YES;
}

- (void)aggregateEntitiesUntilTime:(NSDate *)time
{
    PajeEntity *state;
    PajeEntity *aggregate;
    PajeEntity *newLastEntity = lastEntity;
    NSEnumerator *en;
    AggregateStateChunk *chunk;

    if ([self aggregationFinished]) {
        return;
    }
    
    if (lastTime != nil && [time isEarlierThanDate:lastTime]) {
        return;
    }
    
    if ([(SimulContainer *)container isStopped]
        && [time isLaterThanDate:[container endTime]]) {
        time = [container endTime];
    }
    en = [self originalCompleteEnumeratorFromTime:[[lastEntity endTime] addTimeInterval:-.000001]
                                           toTime:time
                                      minDuration:[aggregator aggregationDuration]/2];

    state = [en nextObject];

    // ignore states that have already been aggregated
    if (lastEntity != nil) {
        while (state != nil) {
            if ([[state endTime] isLaterThanDate:[lastEntity endTime]]) {
                break;
            }
            if (![[state endTime] isEarlierThanDate:[lastEntity endTime]])
            if ([[state startTime] isEarlierThanDate:[lastEntity startTime]]) {
                break;
            }
            state = [en nextObject];
        }
    }

    chunk = (AggregateStateChunk *)[self lastChunk];
    int entityCount = [chunk entityCount];
    while (state != nil) {
        if (entityCount >= 1000 
            && [aggregator entityCount] == 0
            && [[state endTime] isLaterThanDate:[newLastEntity endTime]]) {
            [self finishChunk];
            [self createChunk];
            chunk = (AggregateStateChunk *)[self lastChunk];
            entityCount = [chunk entityCount];
        }

        newLastEntity = state;

        while (![aggregator addEntity:state]) {
            entityCount++;
            aggregate = [aggregator aggregate];
            if (aggregate != nil) {
                [chunk addEntity:aggregate];
            } else {
                [chunk addEntity:state];
                break;
            }
        }

        state = [en nextObject];
    }
    Assign(lastTime, time);
    if ([(SimulContainer *)container isStopped] 
        && ![time isEarlierThanDate:[container endTime]]) {
        [self finishAggregation];
    } else {
        Assign(lastEntity, newLastEntity);

        while ((state = [aggregator aggregateBefore:time]) != nil) {
            [chunk addEntity:state];
        }
        [chunk setEndTime:time];

        NSMutableArray *incomplete = [NSMutableArray array];

        if ([aggregator entityCount] > 0) {
            EntityAggregator *newAggregator;
            newAggregator = [aggregator copy];
            while ((aggregate = [newAggregator aggregate]) != nil) {
                [incomplete addObject:aggregate];
            }
            [newAggregator release];
        }

        en = [self originalEnumeratorFromTime:time
                                       toTime:time
                                  minDuration:[aggregator aggregationDuration]/2];
        en = [[en allObjects] reverseObjectEnumerator];

        while ((state = [en nextObject]) != nil) {
            [incomplete addObject:state];
        }
        incomplete = [[incomplete reverseObjectEnumerator] allObjects];
        [chunk setIncompleteEntities:incomplete];
    }
}

- (void)refillChunkAtIndex:(int)chunkIndex
{
    AggregateStateChunk *chunk;

    chunk = (AggregateStateChunk *)[self chunkAtIndex:chunkIndex];
    NSAssert([chunk isZombie], @"refilling a non-empty chunk");

    [chunk activate];

    PajeEntity *state;
    PajeEntity *aggregate;
    NSEnumerator *en;

    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    EntityAggregator *refillAggregator;
    refillAggregator = [StateAggregator aggregatorWithAggregationDuration:
                                            [aggregator aggregationDuration]];

//startTime deste é igual ao endTime do anterior. definir a quem pertence quem
//termina/comeca numa data certa
    en = [self originalCompleteEnumeratorFromTime:[chunk startTime]
                                           toTime:[chunk endTime]
                                      minDuration:[aggregator aggregationDuration]/2];

    while ((state = [en nextObject]) != nil) {
        while (![refillAggregator addEntity:state]) {
            aggregate = [refillAggregator aggregate];
            if (aggregate != nil) {
                [chunk addEntity:aggregate];
            } else {
                [chunk addEntity:state];
                break;
            }
        }
    }

    NSDate *incompleteStartTime = [[chunk firstIncomplete] startTime];
    while ((aggregate = [refillAggregator aggregate]) != nil) {
        if (incompleteStartTime == nil
            || ![[aggregate endTime] isEarlierThanDate:incompleteStartTime]) {
            [chunk addEntity:aggregate];
        }
    }
    [chunk freeze];

    [pool release];
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
        arrayClass = [AggregatingEventChunkArray class];
        break;
    case PajeStateDrawingType:
        arrayClass = [AggregatingStateChunkArray class];
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
        //Assign(aggregator, 
        //       [StateAggregator aggregatorWithAggregationDuration:duration]);
        lastEntity = nil;
    }
    return self;
}

- (void)dealloc
{
    Assign(entityType, nil);
    Assign(container, nil);
    Assign(aggregator, nil);
    Assign(lastEntity, nil);
    Assign(lastTime, nil);
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
    //return aggregator == nil;
    return finished;
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)startTime
                                        toTime:(NSDate *)endTime
{
    unsigned startIndex;
    unsigned endIndex;
    int index;
    MultiEnumerator *multiEnum;
    EntityChunk *chunk;
    int chunkCount;

    // if not yet aggregated until endTime, continue aggregation
    if (![self aggregationFinished]
        && (lastTime == nil || [endTime isLaterThanDate:lastTime])) {
        [self aggregateEntitiesUntilTime:
                [endTime addTimeInterval:2*[aggregator aggregationDuration]]];
    }

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    // chunks are indexed by startTime
    startIndex = [chunks indexOfLastObjectNotAfterValue:startTime];
    endIndex = [chunks indexOfLastObjectBeforeValue:endTime];

    if (endIndex >= chunkCount) {
        endIndex = chunkCount - 1;
        chunk = [chunks objectAtIndex:endIndex];
    }
    if (startIndex > endIndex) {
        return nil;
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
                    [chunk enumeratorOfCompleteEntitiesAfterTime:startTime]];

    return multiEnum;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesFromTime:(NSDate *)startTime
                                                toTime:(NSDate *)endTime
{
    unsigned startIndex;
    unsigned endIndex;
    int index;
    MultiEnumerator *multiEnum;
    EntityChunk *chunk;
    int chunkCount;

    // if not yet aggregated until endTime, continue aggregation
    if (lastEntity == nil || [endTime isLaterThanDate:lastTime]) {
        [self aggregateEntitiesUntilTime:endTime];
    }

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    // chunks are indexed by startTime
    startIndex = [chunks indexOfLastObjectNotAfterValue:startTime];
    endIndex = [chunks indexOfLastObjectBeforeValue:endTime];

    if (endIndex >= chunkCount) {
        endIndex = chunkCount - 1;
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
        return [chunk fwEnumeratorOfCompleteEntitiesAfterTime:startTime
                                                    untilTime:endTime];
    }

    // multiple chunks: get some entities from first chunk,
    // all from intermediary chunks and some from last chunk
    multiEnum = [MultiEnumerator enumerator];

    [multiEnum addEnumerator:
                    [chunk fwEnumeratorOfCompleteEntitiesAfterTime:startTime]];

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

- (void)aggregateEntitiesUntilTime:(NSDate *)time
{
    [self subclassResponsibility:_cmd];
}

- (void)refillChunkAtIndex:(int)chunkIndex
{
    [self subclassResponsibility:_cmd];
}
@end
