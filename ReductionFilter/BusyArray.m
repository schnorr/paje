/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
// BusyArray

#include "BusyArray.h"
#include "ReduceEntity.h"

@interface BusyArrayEnumerator : NSEnumerator
{
    BusyArray *array;
    Class class;
    unsigned index;
    unsigned lastIndex;
}

- (id)initWithArray:(BusyArray *)a entityClass:(Class)c;
- (id)initWithArray:(BusyArray *)a entityClass:(Class)c
         firstIndex:(unsigned)i1 lastIndex:(unsigned)i2;
- (void)dealloc;
- (id)nextObject;
@end

@implementation BusyArrayEnumerator
- (id)initWithArray:(BusyArray *)a entityClass:(Class)c
{
    NSParameterAssert(a);
    self = [super init];
    if (self) {
        array = [a retain];
        class = c;
        index = 0;
        lastIndex = [array count] - 2;
    }
    return self;
}

- (id)initWithArray:(BusyArray *)a entityClass:(Class)c
         firstIndex:(unsigned)i1 lastIndex:(unsigned)i2
{
    NSParameterAssert(a);
    self = [super init];
    if (self) {
        array = [a retain];
        class = c;
        index = i1;
        lastIndex = [array count] - 2;
        if (i2 < lastIndex)
            lastIndex = i2;
    }
    return self;
}

- (void)dealloc
{
    [array release];
    [super dealloc];
}

- (id)nextObject
{
    id entity;

    // last element of array doesn't generate an entity
    if (index > lastIndex) {
        return nil;
    }

    entity = [class entityWithArray:array index:index];
    index++;

    return entity;
}
@end



@implementation BusyArray
- (id)initWithEntityType:(PajeEntityType *)et container:(PajeContainer *)cont
               startTime:(NSDate *)startTime endTime:(NSDate *)endTime
{
    self = [super initWithSelector:@selector(time)];
    if (self) {
        container = [cont retain];
        entityType = et; // not retained
        [array insertObject:[BusyDate dateWithDate:startTime objects:[NSMutableArray array]] atIndex:0];
        [array insertObject:[BusyDate dateWithDate:endTime objects:[NSMutableArray array]] atIndex:1];
    }
    return self;
}

- (id)initWithEntityType:(PajeEntityType *)et
               container:(PajeContainer *)cont
               startTime:(NSDate *)startTime
                 endTime:(NSDate *)endTime
              enumerator:(NSEnumerator *)enumerator
              nameFilter:(NSSet *)filter
{
    self = [self initWithEntityType:et container:cont
                          startTime:startTime endTime:endTime];
    if (self) {
        id <PajeEntity>obj;
        while ((obj = [enumerator nextObject]) != nil) {
            if (![filter containsObject:[obj name]]) {
                [self addObject:obj];
            }
        }
   }
    return self;
}

- (void)dealloc
{
    [container release];
    [super dealloc];
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
    return [[array objectAtIndex:0] time];
}

- (NSDate *)endTime
{
    return [[array lastObject] time];
}

- (void)addObject:(id <PajeEntity>)entity
{
    id startTime = [entity startTime];
    id endTime = [entity endTime];
    unsigned index1, index2;
    BusyDate *date1;
    BusyDate *date2;
    unsigned i;

    // See if startTime of entity is in the array's time interval.
    // If it is, insert it in the array if not there yet.
    index1 = [self indexOfFirstObjectNotBeforeValue:startTime];
    if ((index1 > 0) && (index1 < [array count])
        && ([startTime isEarlierThanDate:[[array objectAtIndex:index1] time]])) {
        date1 = [BusyDate dateWithDate:startTime
                               objects:[[self objectAtIndex:index1 - 1] allObjects]];
        [array insertObject:date1 atIndex:index1];
    }

    // do the same for endTime
    index2 = [self indexOfFirstObjectNotBeforeValue:endTime];
    if ((index2 > 0) && (index2 < [array count])
        && ([endTime isEarlierThanDate:[[array objectAtIndex:index2] time]])) {
        date2 = [BusyDate dateWithDate:endTime
                               objects:[[self objectAtIndex:index2 - 1] allObjects]];
        [array insertObject:date2 atIndex:index2];
    }

    // insert "entity" in all dates in array that are within the interval.
    for (i = index1; i < index2; i++) {
        [[self objectAtIndex:i] addObject:entity];
    }
}

- (NSEnumerator *)objectEnumeratorOfClass:(Class)c
{
    return [[(BusyArrayEnumerator *)[BusyArrayEnumerator alloc] initWithArray:self entityClass:c] autorelease];
}

- (NSEnumerator *)objectEnumeratorOfClass:(Class)c
                                 fromTime:(NSDate *)t1 toTime:(NSDate *)t2
{
    BusyArrayEnumerator *enumerator;
    unsigned i1, i2;
    i1 = [self indexOfLastObjectNotAfterValue:t1];
    i2 = [self indexOfFirstObjectNotBeforeValue:t2];
    enumerator = [[BusyArrayEnumerator alloc] initWithArray:self entityClass:c
                                                 firstIndex:i1 lastIndex:i2];
    return [enumerator autorelease];
}

- (NSString *)description
{
    return [array description];
}
@end
