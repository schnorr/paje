/*
    Copyright (c) 2005 Benhur Stein
    
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

#include "Association.h"
#include "Macros.h"

@implementation Association
+ (Association *)associationWithObject:(id)obj double:(double)d
{
    return [[[self alloc] initWithObject:obj double:d] autorelease];
}

- (id)initWithObject:(id)obj double:(double)d
{
    self = [super init];
    if (self != nil) {
        Assign(object, obj);
        value = d;
    }
    return self;
}

- (void)dealloc
{
    Assign(object, nil);
    [super dealloc];
}

- (id)objectValue
{
    return object;
}

- (double)doubleValue
{
    return value;
}

- (void)addDouble:(double)d
{
    value += d;
}

- (NSComparisonResult)inverseDoubleValueComparison:(Association *)other
{
    double dif;
    
    dif = value - [other doubleValue];
    if (dif < 0) return NSOrderedDescending;
    if (dif > 0) return NSOrderedAscending;
    return NSOrderedSame;
}

- (NSComparisonResult)objectValueComparison:(Association *)other
{
    return [(NSObject *)object compare:[other objectValue]];
}

- (unsigned int)hash
{
    return [object hash];
}

- (BOOL)xisEqual:(id)anObj
{
    if (self == anObj) {
        return YES;
    }
    if ([[anObj class] isEqual:[Association class]]) {
        return [object isEqual:[(Association *)anObj objectValue]];
    } else {
        return [object isEqual:anObj];
    }
}

- (BOOL)isEqual:(id)anObj
{
    BOOL r;
    r = [self xisEqual:anObj];
    NSLog(@"%@ == %@ : %s", object, anObj, r?"YES":"NO");
    return r;
}

- (NSString *)xdescription
{
    return [object description];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@, %f>", object, value];
}

// NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:object];
    [coder encodeValueOfObjCType:@encode(double) at:&value];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil) {
        object = [[coder decodeObject] retain];
        [coder decodeValueOfObjCType:@encode(double) at:&value];
    }
    return self;
}

- (id)startTime
{
    return [(NSDate *)object addTimeInterval:-100.0];
}
- (id)name
{
    return object;
}
- (id)container
{
return nil;
}
- (id)valueOfFieldNamed:(id)x
{
return nil;
}
- (id)relatedEntities
{
return nil;
}
@end
