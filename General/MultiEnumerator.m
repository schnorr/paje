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

#include "MultiEnumerator.h"

#ifdef GNUSTEP
@implementation NSEnumerator (Additions)
- (NSArray *)allObjects
{
    NSMutableArray *a = [NSMutableArray array];
    id obj;

    while ((obj = [self nextObject]) != nil) {
        [a addObject:obj];
    }

    return a;
}
@end
#endif

@implementation MultiEnumerator


+ (MultiEnumerator *)enumeratorWithEnumerator:(NSEnumerator *)en
{
    return [[[self alloc] initWithEnumeratorArray:[NSArray arrayWithObject:en]] autorelease];
}

+ (MultiEnumerator *)enumeratorWithEnumeratorArray:(NSArray *)array
{
    return [[[self alloc] initWithEnumeratorArray:array] autorelease];
}

+ (MultiEnumerator *)enumerator
{
    return [[[self alloc] initWithEnumeratorArray:[NSMutableArray array]] autorelease];
}

- (id)initWithEnumeratorArray:(NSArray *)array;
{
    self = [super init];
    if (self != nil) {
        origEnums = [array mutableCopy];
    }
    return self;
}

- (void)dealloc
{
    [origEnums release];
    [super dealloc];
}

- (void)addEnumerator:(NSEnumerator *)enumerator
{
    if (enumerator != nil) {
        [origEnums addObject:enumerator];
    }
}

- (id)nextObject;
{
    id obj = nil;

    while (obj == nil) {

        if ([origEnums count] == 0)
            return nil;

        obj = [[origEnums objectAtIndex:0] nextObject];
        if (obj)
            return obj;

        [origEnums removeObjectAtIndex:0];

    }
    return nil; // shuts up compiler
}
@end
