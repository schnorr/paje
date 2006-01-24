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
/* PSortedArray.m created by benhur on Mon 07-Apr-1997 */

#include "PSortedArray.h"

@interface PSortedArrayEnumerator : NSEnumerator
{
    PSortedArray *array;
    unsigned index;
}
@end
@implementation PSortedArrayEnumerator
- (id)initWithArray:(PSortedArray *)anArray andIndex:(unsigned)anIndex
{
    array = [anArray retain];
    index = anIndex;
    return self;
}

- (void)dealloc
{
    [array release];
    [super dealloc];
}

- (id)nextObject
{
    if (index < [array count])
        return [array objectAtIndex:index++];
    else
        return nil;
}
@end



@implementation PSortedArray

+ (PSortedArray *)sortedArrayWithSelector:(SEL)sel
{
    return [[[self alloc] initWithSelector:sel] autorelease];
}

- (id)initWithSelector:(SEL)sel
{
    [super init];
    array = [[NSMutableArray array] retain];
    valueSelector = sel;
    return self;
}

- (void)dealloc
{
    [array release];
    [super dealloc];
}

- (unsigned)count
{
    return [array count];
}

- (id)objectAtIndex:(unsigned)index
{
    return [array objectAtIndex:index];
}

- (void)removeObjectAtIndex:(unsigned)index
{
    [array removeObjectAtIndex:index];
}

- (void)removeObject:(id)obj
{
    id<Comparing> value = [obj performSelector:valueSelector];
    unsigned index = [self indexOfFirstObjectNotBeforeValue:value];
    while (index < [array count]
        && [[[array objectAtIndex:index] performSelector:valueSelector]
            isEqual:value])
        [array removeObjectAtIndex:index];
}

- (void)removeObjectIdenticalTo:(id)obj
{
    id<Comparing> value = [obj performSelector:valueSelector];
    unsigned index = [self indexOfFirstObjectNotBeforeValue:value];
    while (index < [array count]) {
        id testobj = [array objectAtIndex:index];

        if (testobj == obj) {
            [array removeObjectAtIndex:index];
        } else {
            if ([[testobj performSelector:valueSelector] isEqual:value])
                index++;
            else
                break;
        }
    }
}

- (void)removeObjectsBeforeValue:(id<Comparing>)value
{
    unsigned index = [self indexOfFirstObjectNotBeforeValue:value];
    if (index > 0)
        [array removeObjectsInRange:NSMakeRange(0, index)];
}

- (void)addObject:(id)obj
{
    id<Comparing> value = [obj performSelector:valueSelector];
    int pos = [array count];

    // if anObject should be the last in array, just add it.
    if (pos == 0
        || [value compare:[[array lastObject] performSelector:valueSelector]]
           != NSOrderedAscending) {  // obj >= array[last]
        [array addObject:obj];
    } else {
        // find the place to insert
        pos-=2;    // no need to retest the last one.
        while (pos >= 0
               && [value compare:[[array objectAtIndex:pos]
                  performSelector:valueSelector]] == NSOrderedAscending)
                  // obj < array[pos]
            pos--;
        [array insertObject:obj atIndex:++pos];
    }
}

- (void)verifyPositionOfObjectIdenticalTo:(id)obj
{
    id<Comparing> value;
    BOOL found = NO;
    int count = [array count];
    int pos, newpos;

    // find object (should be near end)
    pos = count;
    while (!found && pos > 0) {
        pos--;
        if (obj == [array objectAtIndex:pos])
            found = YES;
    }
    if (!found) {
        NSLog(@"object %@ not found while verifying its position in list", obj);
        return;
    }

    value = [obj performSelector:valueSelector];
    newpos = pos;
    // try to see if it should be moved to the end of the array
    while ((newpos+1 < count)
           && [value compare:
               [[array objectAtIndex:newpos+1] performSelector:valueSelector]]
              == NSOrderedDescending) { // obj > array[newpos+1]
        newpos = newpos+1;
    }

    // if not to the end, try to the beginning
    if (newpos == pos) {
        while ((newpos-1 >= 0)
               && [value compare:
                   [[array objectAtIndex:newpos-1] performSelector:valueSelector]]
               == NSOrderedAscending) { // obj < array[newpos-1]
            newpos = newpos - 1;
        }
    }
    
    // if a new position has been found, move it!
    if (newpos != pos) {
        [array insertObject:obj atIndex:newpos];
        if (pos > newpos)
            pos++;
        [array removeObjectAtIndex:pos];
    }
}

int delta_d_ctr;
int delta_d_tctr;
double delta_d_time;
double delta_d_time0;
NSDate *delta_d_t0;
- (unsigned)indexOfFirstObjectNotBeforeValue:(id<Comparing>)value
{
    int lo, hi, pivot, cnt;
    lo = 0;
    pivot = -1; // to force the final test if the while doesn't execute
    cnt = [array count];
    hi = cnt - 1;

//    delta_d_t0 = [NSDate new];
    while (hi > lo) {
        pivot = (hi + lo) / 2;
        if ([value compare:[[array objectAtIndex:pivot]
                performSelector:valueSelector]] == NSOrderedDescending)
            // value > array[pivot]
            lo = pivot+1;
        else
            hi = pivot;
//        delta_d_ctr++;
    }
//    delta_d_time -= [delta_d_t0 timeIntervalSinceNow];
//    [delta_d_t0 release];
//    delta_d_tctr++;
//    if ((delta_d_tctr%1000)==999)
//        NSLog(@"DELTA_D %d %d %f %f", delta_d_tctr, delta_d_ctr, delta_d_time, delta_d_time0);
    if (lo != pivot && lo < cnt
        && [value compare:[[array objectAtIndex:lo]
                performSelector:valueSelector]] == NSOrderedDescending) // v>a[lo]
        return lo+1;
    else
        return lo;
}

- (unsigned)indexOfLastObjectNotAfterValue:(id<Comparing>)value
{
    unsigned index = [self indexOfFirstObjectNotBeforeValue:value];

    if (index < [array count]) {
        id arrValue;
        arrValue = [[array objectAtIndex:index] performSelector:valueSelector];
        if ([value compare:arrValue] == NSOrderedSame) {
            return index;
        }
    }
    if (index > 0) {
        return index - 1;
    }
    return NSNotFound;
}

- (unsigned)indexOfObjectWithValue:(id<Comparing>)value
{
    unsigned index = [self indexOfFirstObjectNotBeforeValue:value];

    if (index < [array count]) {
        id arrValue;
        arrValue = [[array objectAtIndex:index] performSelector:valueSelector];
        if ([value compare:arrValue] == NSOrderedSame) {
            return index;
        }
    }
    return NSNotFound;
}

- (unsigned)indexOfObject:(id)anObject
{
    return [self indexOfObjectWithValue:[anObject performSelector:valueSelector]];
}

- (NSEnumerator *)objectEnumeratorAfterValue:(id<Comparing>)value
{
    return [[[PSortedArrayEnumerator alloc]
        initWithArray:self andIndex:[self indexOfFirstObjectNotBeforeValue:value]]
        autorelease];
}

- (NSEnumerator *)objectEnumerator
{
    return [array objectEnumerator];
}

- (void) removeObjectsInRange: (NSRange)aRange
{
    [array removeObjectsInRange:aRange];
}

// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
//    [super encodeWithCoder:coder];
    [coder encodeObject:array];
    [coder encodeValueOfObjCType:@encode(SEL) at:&valueSelector];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];//WithCoder:coder];
    array = [[coder decodeObject] retain];
    [coder decodeValueOfObjCType:@encode(SEL) at:&valueSelector];
    return self;
}

- (NSString *)description
{
    return [array description];
}
@end
