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

@implementation EntityChunk

- (id)initWithEntityType:(PajeEntityType *)et
               container:(PajeContainer *)pc
{
    self = [super init];
    if (self != nil) {
        Assign(container, pc);
        Assign(entityType, et);
    }
    return self;
}

- (void)dealloc
{
    Assign(container, nil);
    Assign(entityType, nil);
    Assign(startTime, nil);
    Assign(endTime, nil);
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

- (BOOL)isEntity:(PajeEntity *)entity laterThan:(NSDate *)time
{
    return [[entity startTime] isLaterThanDate:time];
}


- (NSEnumerator *)enumeratorOfAllCompleteEntities
{
    [self subclassResponsibility:_cmd];
    return nil;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesAfterTime:(NSDate *)time
{
    [self subclassResponsibility:_cmd];
    return nil;
}

- (NSEnumerator *)enumeratorOfEntitiesBeforeTime:(NSDate *)time
{
    [self subclassResponsibility:_cmd];
    return nil;
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime
{
    [self subclassResponsibility:_cmd];
    return nil;
}

@end
