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

#include "EntityChunk.h"
#include "Macros.h"
#include "MultiEnumerator.h"
#include "FilteredEnumerator.h"

#define CHUNKS_TO_KEEP 3000

@implementation EntityChunk

// LRU list of all chunks
static EntityChunk *first;
static EntityChunk *last;
static int count;
//

+ (void)emptyLeastRecentlyUsedChunks
{
    int i;
    EntityChunk *chunk;
    chunk = last;
    for (i = 0; chunk != nil && i < count - CHUNKS_TO_KEEP; i++) {
        [chunk empty];
        chunk = chunk->prev;
    }
}

+ (void)remove:(EntityChunk *)chunk
{
    if (chunk->prev != nil) chunk->prev->next = chunk->next;
    if (chunk->next != nil) chunk->next->prev = chunk->prev;
    if (last == chunk) last = chunk->prev;
    if (first == chunk) first = chunk->next;
    chunk->prev = chunk->next = nil;
}

+ (void)touch:(EntityChunk *)chunk
{
    if (first == chunk) return;
    if (first == nil) {
        first = last = chunk;
        return;
    }
    if (chunk->prev != nil) chunk->prev->next = chunk->next;
    if (chunk->next != nil) chunk->next->prev = chunk->prev;
    if (last == chunk && chunk->prev != nil) last = chunk->prev;
    chunk->prev = nil;
    chunk->next = first;
    first->prev = chunk;
    first = chunk;
}

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
{
    self = [super init];
    if (self != nil) {
        entityType = type;    // not retained
        container = pc;       // not retained
        entities = [[PSortedArray alloc] initWithSelector:@selector(endTime)];
        count++;
        [EntityChunk touch:self];
    }
    return self;
}

- (void)dealloc
{
    container = nil;
    entityType = nil;
    Assign(startTime, nil);
    Assign(endTime, nil);
    Assign(entities, nil);
    Assign(incompleteEntities, nil);
    [EntityChunk remove:self];
    count--;
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"chunk of %@ in %@ from %@ to %@ complete:%@ incomplete:%@",
        entityType, container, startTime, endTime, [self completeEntities], [self incompleteEntities]];
}

- (PajeContainer *)container
{
    return container;
}

- (PajeEntityType *)entityType
{
    return entityType;
}

- (NSDate *)startTime
{
    return startTime;
}

- (void)setStartTime:(NSDate *)time
{
    Assign(startTime, time);
}

- (NSDate *)endTime
{
    return endTime;
}

- (void)setEndTime:(NSDate *)time
{
    Assign(endTime, time);
}



- (BOOL)isActive
{
    return chunkState == active;
}

- (BOOL)isFull
{
    return chunkState == frozen;
}

- (BOOL)isZombie
{
    return chunkState == empty;
}

- (BOOL)canEnumerate
{
    return chunkState == frozen;
}

- (BOOL)canInsert
{
    return chunkState == active;
}

// sent to a zombie to refill it
- (void)activate
{
//    NSAssert(chunkState == empty, @"trying to activate a non-zombie chunk");
    chunkState = active;
    entities = [[PSortedArray alloc] initWithSelector:@selector(endTime)];
}

// sent to an active chunk to make it full
- (void)freeze
{
//    NSAssert(chunkState == active, @"trying to freeze a non-active chunk");
    chunkState = frozen;
}

// sent to a full chunk to empty it (make a zombie)
- (void)empty
{
//    NSAssert(chunkState == frozen, @"trying to activate a non-zombie chunk");
    if ([self isZombie]) {
        return;
    }
    // do not empty it nothing would be released
    if ([entities count] == 0) {
        return;
    }
    chunkState = empty;
    Assign(entities, nil);
}




- (id)filterEntity:(PajeEntity *)entity notStartingBefore:(NSDate *)time
{
    if ([[entity startTime] isEarlierThanDate:time]) {
        return entity;
    } else {
        return nil;
    }
}

- (id)filterEntity:(PajeEntity *)entity startingBefore:(NSDate *)time
{
    if ([[entity startTime] isEarlierThanDate:time]) {
        return nil;
    } else {
        return entity;
    }
}

- (id)filterEntity:(PajeEntity *)entity startingLaterThan:(NSDate *)time
{
    if ([[entity startTime] isLaterThanDate:time]) {
        return nil;
    } else {
        return entity;
    }
}

- (id)filterEntity:(PajeEntity *)entity endingLaterThan:(NSDate *)time
{
    if ([[entity endTime] isLaterThanDate:time]) {
        return nil;
    } else {
        return entity;
    }
}

- (id)filterEntity:(PajeEntity *)entity notEndingBefore:(NSDate *)time
{
    if ([[entity endTime] isEarlierThanDate:time]) {
        return entity;
    } else {
        return nil;
    }
}

- (PSortedArray *)completeEntities
{
    return entities;
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
    if (incompleteEntities == nil) {
        return [NSArray array];
    }
    return incompleteEntities;
}


- (NSEnumerator *)enumeratorOfAllCompleteEntities
{
    NSEnumerator *compEnum;

    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
    [EntityChunk touch:self];
    compEnum = [[self completeEntities] reverseObjectEnumerator];
    
    return compEnum;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesAfterTime:(NSDate *)time
{
    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
    [isa touch:self];
    return [[self completeEntities]
                reverseObjectEnumeratorAfterValue:(id<Comparing>)time];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesFromTime:(NSDate *)time
{
    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
    [isa touch:self];
    return [[self completeEntities]
//                reverseObjectEnumeratorNotBeforeValue:(id<Comparing>)time];
                reverseObjectEnumeratorAfterValue:(id<Comparing>)time];
}

- (NSEnumerator *)fwEnumeratorOfAllCompleteEntities
{
    NSEnumerator *compEnum;

    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
//    [EntityChunk touch:self];
    compEnum = [[self completeEntities] objectEnumerator];
    
    return compEnum;
}

- (NSEnumerator *)fwEnumeratorOfCompleteEntitiesFromTime:(NSDate *)time
{
    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
//    [isa touch:self];
    return [[self completeEntities]
                objectEnumeratorAfterValue:(id<Comparing>)time];
}

- (NSEnumerator *)fwEnumeratorOfCompleteEntitiesUntilTime:(NSDate *)time
{
    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
//    [isa touch:self];
    return [[self completeEntities]
                objectEnumeratorNotAfterValue:(id<Comparing>)time];
}

- (NSEnumerator *)fwEnumeratorOfCompleteEntitiesFromTime:(NSDate *)start
                                               untilTime:(NSDate *)end
{
    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
//    [isa touch:self];
    return [[self completeEntities]
                objectEnumeratorAfterValue:(id<Comparing>)start
                             notAfterValue:(id<Comparing>)end];

    NSEnumerator *compEnum;
    SEL filterSelector = @selector(filterEntity:startingBefore:);

    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
//    [EntityChunk touch:self];

    compEnum = [self fwEnumeratorOfCompleteEntitiesUntilTime:end];

    return [FilteredEnumerator enumeratorWithEnumerator:compEnum
                                                 filter:self
                                               selector:filterSelector
                                                context:start];
}

- (NSEnumerator *)enumeratorOfAllEntities
{
    NSEnumerator *incEnum;
    NSEnumerator *compEnum;
    NSEnumerator *en;

    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
    [EntityChunk touch:self];

    incEnum = [[self incompleteEntities] objectEnumerator];
    compEnum = [[self completeEntities] reverseObjectEnumerator];
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
    NSEnumerator *enAll;
    SEL filterSelector = @selector(filterEntity:notStartingBefore:);
    
    enAll = [self enumeratorOfAllEntities];

    return [FilteredEnumerator enumeratorWithEnumerator:enAll
                                                 filter:self
                                               selector:filterSelector
                                                context:time];
}

- (NSEnumerator *)xxfwEnumeratorOfCompleteEntitiesUntilTime:(NSDate *)time
{
    NSEnumerator *enAll;
    SEL filterSelector = @selector(filterEntity:endingAfterTime:);
    
    enAll = [self fwEnumeratorOfAllCompleteEntities];

    return [FilteredEnumerator enumeratorWithEnumerator:enAll
                                                 filter:self
                                               selector:filterSelector
                                                context:time];
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime
{
    NSEnumerator *incEnum;
    NSEnumerator *compEnum;
    NSEnumerator *en;
    SEL filterSelector = @selector(filterEntity:notStartingBefore:);

    NSAssert([self canEnumerate], @"enumerating non-enumerable chunk");
    [EntityChunk touch:self];

    incEnum = [[self incompleteEntities] objectEnumerator];
    compEnum = [self enumeratorOfCompleteEntitiesFromTime:sliceStartTime];
    if (incEnum != nil && compEnum != nil) {
        en = [MultiEnumerator enumeratorWithEnumeratorArray:
                    [NSArray arrayWithObjects:incEnum, compEnum, nil]];
    } else if (compEnum != nil) {
        en = compEnum;
    } else {
        en = incEnum;
    }

    return [FilteredEnumerator enumeratorWithEnumerator:en
                                                 filter:self
                                               selector:filterSelector
                                                context:sliceEndTime];
}


- (id)xxxcopyWithZone:(NSZone *)z
{
    EntityChunk *copy;
    copy = [[[self class] alloc] initWithEntityType:entityType
                                          container:container];
    [copy setStartTime:startTime];
    [copy setEndTime:endTime];
    return copy;
}

- (int)entityCount
{
    return [[self completeEntities] count];
}

- (id)lastEntity
{
    return [[self completeEntities] lastObject];
}


- (void)addEntity:(PajeEntity *)entity
{
    NSAssert([self canInsert], @"adding entities to inactive chunk");
    [entities addObject:entity];
}

@end
