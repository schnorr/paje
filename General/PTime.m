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
/* PTime.m
 *
 * see PTime.h
 */

/* 19980213 BS  creation
 */

#include "PTime.h"

PTime *initialTime;

@implementation PTime

+ (void)setInitialTime:(PTime *)time
{
    [initialTime release];
    initialTime = [time retain];
}

// there's a bug in NSDate, it's classForCoder and classForArchiver return NSDate
- (Class)classForCoder
{
    return [self class];
}
- (Class)classForArchiver
{
    return [self class];
}

- (id)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds
{
#ifndef GNUSTEP
    self = [super init];
#endif
    secondsSinceReferenceDate = seconds;
    return self;
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return secondsSinceReferenceDate;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%.6f", initialTime ? [self timeIntervalSinceDate:initialTime] : [self timeIntervalSinceReferenceDate]];
}
- (NSString *)stringValue
{
    return [self description];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeValueOfObjCType:@encode(NSTimeInterval) at:&secondsSinceReferenceDate];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [coder decodeValueOfObjCType:@encode(NSTimeInterval) at:&secondsSinceReferenceDate];
    return self;
}
@end
