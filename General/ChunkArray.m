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

#include "ChunkArray.h"

#include "MultiEnumerator.h"
#include "Macros.h"
#include "PajeEntity.h"

@implementation ChunkArray

- (id)init
{
    self = [super init];
    if (self != nil) {
        chunks = [[PSortedArray alloc] initWithSelector:@selector(startTime)];
    }
    return self;
}

- (void)dealloc
{
    Assign(chunks, nil);
    [super dealloc];
}

- (void)raiseMissingChunk:(int)chunkNumber
{
    NSDictionary *userInfo;
    userInfo = [NSDictionary dictionaryWithObject:
                                 [NSNumber numberWithInt:chunkNumber+firstIndex]
                                           forKey:@"ChunkNumber"];
    [[NSException exceptionWithName:@"PajeMissingChunkException"
                             reason:nil
                           userInfo:userInfo] raise];
//
    [[NSNotificationCenter defaultCenter]
                  postNotificationName:@"PajeChunkNotInMemoryNotification"
                                object:self
                              userInfo:userInfo];
}

// enumerate all entities that end after startTime and start before endTime,
// in reverse endTime order.
- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)startTime
                                        toTime:(NSDate *)endTime
{
    NSUInteger startIndex;
    NSUInteger endIndex;
    int index;
    MultiEnumerator *multiEnum;
    EntityChunk *chunk;
    int chunkCount;

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    // chunks are ordered by startTime, and each contains all entities that
    // end inside its time boundaries (after its startTime and not after
    // its endTime (plus incomplete entities, that cross its endTime border)).
    // startIndex and endIndex are the indexes of the first and last chunks
    // that may contain the entities we are interested in.
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
    if (![chunk isFull]) {
        [self raiseMissingChunk:endIndex];
    }

    if (startIndex == endIndex) {
        // all entities are in one chunk.
        return [chunk enumeratorOfEntitiesFromTime:startTime toTime:endTime];
    }

    // there are multiple chunks involved --
    //  get complete and incomplete entities from last chunk,
    //  all complete entities from intermediary chunks
    //  and some (those that end after startTime) complete entities
    //  from first chunk.
    multiEnum = [MultiEnumerator enumerator];

    [multiEnum addEnumerator:[chunk enumeratorOfEntitiesBeforeTime:endTime]];

    for (index = endIndex - 1; index > startIndex; index--) {
        chunk = [chunks objectAtIndex:index];
        if (![chunk isFull]) {
            [self raiseMissingChunk:index];
        }
        [multiEnum addEnumerator:[chunk enumeratorOfAllCompleteEntities]];
    }

    chunk = [chunks objectAtIndex:startIndex];
    if (![chunk isFull]) {
        [self raiseMissingChunk:startIndex];
    }
    [multiEnum addEnumerator:
                    [chunk enumeratorOfCompleteEntitiesFromTime:startTime]];

    return multiEnum;
}

// enumerate all entities that end after startTime and not after endTime,
// in increasing endTime order.
- (NSEnumerator *)enumeratorOfCompleteEntitiesFromTime:(NSDate *)startTime
                                             untilTime:(NSDate *)endTime
{
    NSUInteger startIndex;
    NSUInteger endIndex;
    int index;
    MultiEnumerator *multiEnum;
    EntityChunk *chunk;
    int chunkCount;

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    // chunks are in startTime order
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
    if (![chunk isFull]) {
        [self raiseMissingChunk:startIndex];
    }

    if (startIndex == endIndex) {
        // all entities are in one chunk.
        return [chunk fwEnumeratorOfCompleteEntitiesFromTime:startTime
                                                   untilTime:endTime];
    }

    // there are multiple chunks involved -- get complete and incomplete
    //  entities from last chunk, all complete from intermediary chunks and some
    // complete entities from first chunk.
    // there are multiple chunks involved --
    //  get some (those that end after startTime) complete entities
    //  from first chunk,
    //  all complete entities from intermediary chunks
    //  and entities that end up to endTime from last chunk.
    multiEnum = [MultiEnumerator enumerator];

    [multiEnum addEnumerator:
                [chunk fwEnumeratorOfCompleteEntitiesFromTime:startTime]];

    for (index = startIndex + 1; index < endIndex; index++) {
        chunk = [chunks objectAtIndex:index];
        if (![chunk isFull]) {
            [self raiseMissingChunk:index];
        }
        [multiEnum addEnumerator:[chunk fwEnumeratorOfAllCompleteEntities]];
    }

    chunk = [chunks objectAtIndex:endIndex];
    if (![chunk isFull]) {
            [self raiseMissingChunk:endIndex];
    }
    [multiEnum addEnumerator:
                    [chunk fwEnumeratorOfCompleteEntitiesUntilTime:endTime]];

    return multiEnum;
}

- (void)addChunk:(EntityChunk *)chunk
{
    [chunks addObject:chunk];
}

- (void)setFirstIndex:(int)index
{
    firstIndex = index;
}

- (EntityChunk *)chunkAtIndex:(int)index
{
    int indexInArray = index - firstIndex;
    if (indexInArray < 0 || indexInArray >= [chunks count]) {
        return nil;
    }
    return [chunks objectAtIndex:indexInArray];
}
@end
