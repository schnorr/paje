/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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
// BusyEnumerator.m

// 19980227 BS  creation


#include "BusyEnumerator.h"
#include "ReduceEntity.h"
#include "BusyState.h"

@implementation BusyEnumerator

- (id)initWithEnumerator:(NSEnumerator *)original
               container:(PajeContainer *)cont
                fromTime:(NSDate *)start
                  toTime:(NSDate *)end
         concurrentTypes:(NSSet *)busySet
{
    self = [super init];
    enumerator = [original retain];
    busyEntities = [busySet retain];
    array = [[BusyArray alloc] initWithEntityType:[BusyState entityType] container:cont startTime:start endTime:end];
    firstFase = YES;
    return self;
}

- (void)dealloc
{
    [enumerator release];
    [busyEntities release];
    [array release];
    [super dealloc];
}

- (id)nextObject
{
    id obj;
    if (firstFase) {
        do {
            obj = [enumerator nextObject];
            if ((nil != obj) && [busyEntities containsObject:[obj name]])
                [array addObject:obj];
        } while (obj);
        
        if (/*sendOriginal && */(nil != obj)) {
            return obj;
        } else {
            firstFase = NO;
            [enumerator release];
            enumerator = [[array objectEnumeratorOfClass:[CountReduceEntity class]] retain];
        }
    }
    // second fase -- take objects from the array enumerator
    return [enumerator nextObject];
}

@end
