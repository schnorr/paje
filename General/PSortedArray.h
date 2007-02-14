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
#ifndef _PSortedArray_h_
#define _PSortedArray_h_

/* PSortedArray.h created by benhur on Mon 07-Apr-1997 */

#include <Foundation/Foundation.h>
#include "Comparing.h"

@interface PSortedArray : NSObject <NSCoding, NSCopying>
{
    NSMutableArray *array;
    SEL valueSelector;
}

+ (PSortedArray *)sortedArrayWithSelector:(SEL)sel;
- (id)initWithSelector:(SEL)sel;
- (void)setSelector:(SEL)sel;

- (unsigned)count;
- (id)objectAtIndex:(unsigned)index;
- (void)addObject:(id)obj;
- (id)lastObject;

- (void)removeObjectAtIndex:(unsigned)index;
- (void)removeObjectsInRange:(NSRange)aRange;
- (void)removeObject:(id)obj;
- (void)removeObjectIdenticalTo:(id)obj;
- (void)removeObjectsBeforeValue:(id<Comparing>)value;
- (void)removeAllObjects;
- (void)removeLastObject;

- (void)verifyPositionOfObjectIdenticalTo:(id)obj;

- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)objectEnumeratorAfterValue:(id<Comparing>)value;
- (NSEnumerator *)objectEnumeratorNotAfterValue:(id<Comparing>)value;
- (NSEnumerator *)objectEnumeratorNotBeforeValue:(id<Comparing>)value;
- (NSEnumerator *)objectEnumeratorNotBeforeValue:(id<Comparing>)value1
                                   notAfterValue:(id<Comparing>)value2;
- (NSEnumerator *)objectEnumeratorAfterValue:(id<Comparing>)value1
                               notAfterValue:(id<Comparing>)value2;
- (NSEnumerator *)reverseObjectEnumerator;
- (NSEnumerator *)reverseObjectEnumeratorAfterValue:(id<Comparing>)value;
- (NSEnumerator *)reverseObjectEnumeratorNotBeforeValue:(id<Comparing>)value;

- (unsigned)indexOfFirstObjectNotBeforeValue:(id<Comparing>)value; // 0--count
- (unsigned)indexOfFirstObjectAfterValue:(id<Comparing>)value; // 0--count
- (unsigned)indexOfLastObjectNotAfterValue:(id<Comparing>)value; // 0--count-1  may return NSNotFound
- (unsigned)indexOfLastObjectBeforeValue:(id<Comparing>)value; // 0--count-1  may return NSNotFound
- (unsigned)indexOfObjectWithValue:(id<Comparing>)value; // 0--count-1  may return NSNotFound
- (unsigned)indexOfObject:(id)obj; // 0--count-1  may return NSNotFound

- (NSEnumerator *)reverseObjectEnumeratorWithRange:(NSRange)range;

// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// NSCopying Protocol
- (id)copyWithZone:(NSZone *)zone;

@end

#endif
