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
//
// UserValue
//
// Holds a generic user-generated event.
//

#include "UserValue.h"
#include "../General/Macros.h"

@implementation UserValue

+ (UserValue *)valueWithType:(PajeEntityType *)type
                 doubleValue:(double)v
                   container:(PajeContainer *)c
                   startTime:(NSDate *)t1
                     endTime:(NSDate *)t2
{
    return [[[self alloc] initWithType:type
                           doubleValue:v
                             container:c
                             startTime:t1
                               endTime:t2] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
       doubleValue:(double)v
         container:(PajeContainer *)c
         startTime:(NSDate *)t1
           endTime:(NSDate *)t2
{
    self = [super initWithType:type
                          name:@""
                     container:c];

    if (self != nil) {
        Assign(startTime, t1);
        Assign(endTime, t2);
        value = v;
    }

    return self;
}

- (void)dealloc
{
    Assign(startTime, nil);
    Assign(endTime, nil);

    [super dealloc];
}

- (NSDate *)startTime
{
    return startTime;
}

- (NSDate *)endTime
{
    if (endTime != nil) {
        return endTime;
    }
    return [container endTime];
}

- (NSDate *)time
{
    return startTime;
}

- (void)setEndTime:(NSDate *)time
{
    Assign(endTime, time);
}

- (double)doubleValue
{
    return value;
}

- (id)value
{
    return [NSNumber numberWithDouble:value];
}

- (double)minValue
{
    return value;
}

- (double)maxValue
{
    return value;
}

- (int)condensedEntitiesCount
{
    return 1;
}

- (NSArray *)fieldNames
{
    return [[super fieldNames] arrayByAddingObject: @"Value"];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id val;
    if ([fieldName isEqualToString:@"Value"]) {
        val = [NSNumber numberWithDouble:value];
    } else {
        val = [super valueOfFieldNamed:fieldName];
    }
    return val;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:[NSNumber numberWithDouble:value]];
    [coder encodeObject:startTime];
    [coder encodeObject:endTime];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    value = [(NSNumber *)[coder decodeObject] doubleValue];
    Assign(startTime, [coder decodeObject]);
    Assign(endTime, [coder decodeObject]);
    return self;
}
@end
