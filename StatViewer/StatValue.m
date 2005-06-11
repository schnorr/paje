/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
/* StatValue.m created by benhur on Fri 26-Sep-1997 */

#include "StatValue.h"

@implementation StatValue

+ (StatValue *)valueWithValue:(double)v color:(NSColor *)c name:(NSString *)s
{
    return [[[self alloc] initWithValue:v color:c name:s] autorelease];
}

- (id)initWithValue:(double)v color:(NSColor *)c name:(NSString *)s
{
    [super init];
    
    value = v;
    [color release];
    color = [c retain];
    [name release];
    name = [s retain];

    return self;
}

- (void)setValue:(double)v
{
    value = v;
}
- (double)value
{
    return value;
}
- (double)doubleValue
{
    return value;
}
- (void)addToValue:(double)v
{
    value += v;
}

- (void)setColor:(NSColor *)c
{
    [color release];
    color = [c retain];
}
- (NSColor *)color
{
    return color;
}

- (void)setName:(NSString *)s
{
    [name release];
    name = [s retain];
}
- (NSString *)name
{
    return name;
}
- (NSString *)description
{
    return name;
}

- (unsigned int)hash
{
    return [name hash];
}

- (BOOL)isEqual:(id)anObj
{
    if (self == anObj) return YES;
    return [name isEqual:[anObj description]];
}

- (NSComparisonResult)compare:(id)other
{
    double v1 = [self doubleValue];
    double v2 = [other doubleValue];
    if (v1 < v2) return NSOrderedAscending;
    if (v1 > v2) return NSOrderedDescending;
    return NSOrderedSame;
}
@end