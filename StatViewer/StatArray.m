/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
/* StatArray.m created by benhur on Fri 26-Sep-1997 */

#include "StatArray.h"
#include "StatValue.h"
#include <math.h>

@implementation StatArray

+ (StatArray *)arrayWithName:(NSString *)theName
{
    return [[[self alloc] initWithName:theName] autorelease];
}

- (id)initWithName:(NSString *)theName
{
    [super init];

    array = [[NSMutableSet alloc] init];
    name = [theName retain];
    sum = 0;
    max = -HUGE_VAL;
    min = HUGE_VAL;

    return self;
}

- (id)init
{
    return [self initWithName:@""];
}

#ifdef GNUSTEP
- (id)initWithCapacity:(unsigned)c
{
    return self;
}
#endif

- (void)dealloc
{
    [array release];
    [name release];
    [super dealloc];
}

- (void)addObject:(id/*<StatValue>*/)object
{
    double v = [object doubleValue];
    double v2 = v;
    id obj = [array member:object];

    if (obj) {
        [obj addToValue:v];
        v2 = [obj value];
    } else
        [array addObject:object];

    sum += v;
    if (v2 > max) max = v2;
    if (v2 < min) min = v2;
}

- (void)addValue:(double)v toName:(NSString *)n
{
    double v2 = v;
    id obj = [array member:n];

    if (obj) {
        [obj addToValue:v];
        v2 = [obj value];
    } else
        [array addObject:[StatValue valueWithValue:v
                                             color:[NSColor blackColor]
                                              name:n]];

    sum += v;
    if (v2 > max) max = v2;
    if (v2 < min) min = v2;
}

- (void)removeAllObjects
{
    [array removeAllObjects];
    sum = 0;
    max = -HUGE_VAL;
    min = HUGE_VAL;
}

- (unsigned)count
{
    return [array count];
}

- (NSEnumerator *)objectEnumerator
{
    return [array objectEnumerator];
}


- (double)sum
{
    return sum;
}

- (void)setSum:(double)value
{
    sum = value;
}

- (double)maxValue
{
    return max;
}

- (double)minValue
{
    return min;
}

- (void)setName:(NSString *)newName
{
    [name release];
    name = [newName retain];
}

- (NSString *)name
{
    return name;
}
@end
