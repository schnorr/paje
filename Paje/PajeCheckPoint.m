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
// PajeCheckPoint.m

// 19980211 BS creation

#include "PajeCheckPoint.h"

@implementation PajeCheckPoint
+ (PajeCheckPoint *)checkPointWithTime:(NSDate *)t fileName:(NSString *)f
{
    return [[[self alloc] initWithTime:t fileName:f] autorelease];
}

- (id)initWithTime:(NSDate *)t fileName:(NSString *)f
{
    self = [super init];
    time = [t retain];
    fileName = [f retain];
    return self;
}

- (void)dealloc
{
    [time release];
    [fileName release];
    [super dealloc];
}

- (NSDate *)time
{
    return time;
}

- (NSString *)fileName
{
    return fileName;
}

- (unsigned int)hash
{
    return [time hash];
}

- (BOOL)isEqual:(id)anObject
{
    if (self == anObject)
        return YES;
    if ([anObject isKindOfClass:[PajeCheckPoint class]])
        return [time isEqual:[anObject time]];
    return [time isEqual:anObject];
}
@end
