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

#include "NSArray+Additions.h"
#include "Macros.h"
#include <Foundation/NSEnumerator.h>

// Enumerator of objects in a range of indexes of an array
@interface ArrayRangeEnumerator : NSEnumerator
{
    NSArray *array;
    NSRange range;
    unsigned nextIndex;
}
@end

@implementation ArrayRangeEnumerator
- (id)initWithArray:(NSArray *)anArray range:(NSRange)aRange
{
    self = [super init];
    if (self != nil) {
        Assign(array, anArray);
        range = aRange;
        nextIndex = range.location;
        int count = [array count];
        if (NSMaxRange(range) >= count) {
            range.length = count - range.location;
        }
    }
    return self;
}

- (void)dealloc
{
    Assign(array, nil);
    [super dealloc];
}

- (id)nextObject
{
    id nextObject;
    if (NSLocationInRange(nextIndex, range)) {
        nextObject = [array objectAtIndex:nextIndex];
        nextIndex++;
    } else {
        nextObject = nil;
    }
    return nextObject;
}
@end

// Reverse enumerator of objects in a range of indexes of an array

@interface ReverseArrayRangeEnumerator : ArrayRangeEnumerator
@end

@implementation ReverseArrayRangeEnumerator
- (id)initWithArray:(NSArray *)anArray range:(NSRange)aRange
{
    self = [super initWithArray:anArray range:aRange];
    if (self != nil) {
        nextIndex = NSMaxRange(range) - 1;
    }
    return self;
}

- (id)nextObject
{
    id nextObject;
    if (NSLocationInRange(nextIndex, range)) {
        nextObject = [array objectAtIndex:nextIndex];
        nextIndex--;
    } else {
        nextObject = nil;
    }
    return nextObject;
}
@end

@implementation NSArray (PajeAdditions)

- (NSEnumerator *)objectEnumeratorWithRange:(NSRange)range
{
	return [[[ArrayRangeEnumerator alloc]
                        initWithArray:self range:range] autorelease];
}

- (NSEnumerator *)reverseObjectEnumeratorWithRange:(NSRange)range
{
	return [[[ReverseArrayRangeEnumerator alloc]
                        initWithArray:self range:range] autorelease];
}

@end
