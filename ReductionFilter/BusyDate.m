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
// BusyDate

// 19980228 BS  creation

#include "BusyDate.h"

@implementation BusyDate

+ (BusyDate *)dateWithDate:(NSDate *)date objects:(NSArray *)objs
{
    return [[[self alloc] initWithDate:date objects:objs] autorelease];
}
- (id)initWithDate:(NSDate *)date objects:(NSArray *)objs
{
    self = [super init];
    time = [date retain];
    objects = [objs mutableCopy];
    return self;
}
- (void)dealloc
{
    [time release];
    [objects release];
    [super dealloc];
}

- (NSDate *)time { return time; }

- (void)addObject:(id)obj
{
    [objects addObject:obj];
}

- (NSArray *)allObjects { return objects; }

- (NSString *)description
{
    int i;
    NSMutableString *s = [NSMutableString stringWithFormat:@"time = %@; objects = (", [time description]];
    for (i=0; i<[objects count]; i++) {
        id <PajeEntity> o = [objects objectAtIndex:i];
        [s appendFormat:@"%@ %@-%@, ", [o name], [[o startTime] description], [[o endTime] description]];
    }
    [s appendString:@")\n"];
    return s;
}
@end
