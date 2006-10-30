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
    [[NSNotificationCenter defaultCenter]
                  postNotificationName:@"PajeChunkNotInMemoryNotification"
                                object:self
                              userInfo:userInfo];
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

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    startIndex = [chunks indexOfLastObjectNotAfterValue:startTime];
    endIndex = [chunks indexOfLastObjectBeforeValue:endTime];
    
    if (endIndex >= chunkCount) {
        endIndex = chunkCount - 1;
    }
    if (startIndex > endIndex) {
        startIndex = endIndex;
    }

    chunk = [chunks objectAtIndex:endIndex];
    if (![chunk isFull]) {
        [self raiseMissingChunk:endIndex];
    }

if ([[[chunk entityType] description] hasSuffix:@"active.buffer_head"]) NSLog(@"arr(%@) enum %@-%@:%d-%d", [chunk class], startTime, endTime, startIndex, endIndex);
    if (startIndex == endIndex) {
        return [chunk enumeratorOfEntitiesFromTime:startTime toTime:endTime];
    }

    // there are multiple chunks involved -- get complete and incomplete
    //  entities from last chunk, all complete from intermediary chunks and some
    // complete entities from first chunk.
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

    chunkCount = [chunks count];
    if (chunkCount == 0) {
        return nil;
    }

    startIndex = [chunks indexOfLastObjectNotAfterValue:startTime];
    endIndex = [chunks indexOfLastObjectBeforeValue:endTime];

    while (endIndex >= chunkCount) {
        endIndex = chunkCount - 1;
    }
    if (startIndex > endIndex) {
        startIndex = endIndex;
    }

    chunk = [chunks objectAtIndex:startIndex];
    if (![chunk isFull]) {
        [self raiseMissingChunk:startIndex];
    }

    if (startIndex == endIndex) {
        return [chunk fwEnumeratorOfCompleteEntitiesAfterTime:startTime
                                                    untilTime:endTime];
    }

    // there are multiple chunks involved -- get complete and incomplete
    //  entities from last chunk, all complete from intermediary chunks and some
    // complete entities from first chunk.
    multiEnum = [MultiEnumerator enumerator];

    [multiEnum addEnumerator:
                [chunk fwEnumeratorOfCompleteEntitiesAfterTime:startTime]];

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
if ([chunks count]>2) {
EntityChunk *c1, *c2; c1 = [chunks objectAtIndex:0];c2 = [chunks objectAtIndex:1];
//NSLog(@"addChunk to %@ [l%@ I%@] [f%@ I%@]", [chunk entityType], [c1 lastEntity], [c1 incompleteEntities], [[c2 completeEntities] count]==0?nil: [[c2 completeEntities] objectAtIndex:0], [c2 incompleteEntities]);
}
if ([[[chunk entityType] description] hasSuffix:@"active.buffer_head"]) NSLog(@"firstChunk:%@", [chunks objectAtIndex:0]);
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
