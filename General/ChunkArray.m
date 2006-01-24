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
        chunks = [[PSortedArray alloc] initWithSelector:@selector(endTime)];
    }
    return self;
}

- (void)dealloc
{
    Assign(chunks, nil);
    [super dealloc];
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

    startIndex = [chunks indexOfFirstObjectNotBeforeValue:startTime];
    endIndex = [chunks indexOfFirstObjectNotBeforeValue:endTime];
    
    if (endIndex >= chunkCount) {
        endIndex = chunkCount - 1;
    }
    if (startIndex > endIndex) {
        return nil;
    }

    if (startIndex == endIndex) {
       chunk = [chunks objectAtIndex:startIndex];
       return [chunk enumeratorOfEntitiesFromTime:startTime toTime:endTime];
    }

    // there are multiple chunks involved -- get complete and incomplete
    //  entities from last chunk, all complete from intermediary chunks and some
    // complete entities from first chunk.
    multiEnum = [MultiEnumerator enumerator];

    chunk = [chunks objectAtIndex:endIndex];
    [multiEnum addEnumerator:[chunk enumeratorOfEntitiesBeforeTime:endTime]];

    for (index = endIndex - 1; index > startIndex; index--) {
        chunk = [chunks objectAtIndex:index];
        [multiEnum addEnumerator:[chunk enumeratorOfAllCompleteEntities]];
    }

    chunk = [chunks objectAtIndex:startIndex];
    [multiEnum addEnumerator:
                    [chunk enumeratorOfCompleteEntitiesAfterTime:startTime]];

    return multiEnum;
}

- (void)addChunk:(EntityChunk *)chunk
{
    [chunks addObject:chunk];
}

- (void)removeChunksBeforeTime:(NSDate *)time
{
    int index;
    index = [chunks indexOfFirstObjectNotBeforeValue:time];
    if (index >= 1) {
        [chunks removeObjectsInRange:NSMakeRange(0, index)];
    }
}

- (void)removeChunksAfterTime:(NSDate *)time
{
    int index;
    int count;
    count = [chunks count];
    index = [chunks indexOfLastObjectNotAfterValue:time] + 1;
    if (index < count) {
        [chunks removeObjectsInRange:NSMakeRange(index, count - index)];
    }
}

@end
