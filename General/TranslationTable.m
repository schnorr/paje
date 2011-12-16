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
#include "TranslationTable.h"

/*
 * Very dirty implementation.
 * should be changed to use a hash table to make the value->index translation.
 * and a more normal array to the index->value translation.
 */



@implementation TranslationTable

- (id)init
{
    table = [[NSMutableArray array] retain];
    map = [[NSMutableDictionary dictionary] retain];
    return self;
}

- (void)dealloc
{
    [table release];
    [map release];
    [super dealloc];
}

+ (TranslationTable *)translationTable
{
    return [[[self alloc] init] autorelease];
}


/*
 * Querying
 */
 
- (NSUInteger) count
{
    return [table count];
}

- (NSUInteger)indexOfValue:(id)value
{
    id obj = [map objectForKey:value];

    if (obj)
        return [obj intValue];
    else
        return NSNotFound;
}

- (id)valueAtIndex:(NSUInteger)index
{
    return [table objectAtIndex:index];
}


/*
 * Adding Elements
 */
- (NSUInteger)addValue:(id)value
{
    NSUInteger index;
    index = [self indexOfValue:value];
    if (index == NSNotFound) {
        [table addObject:value];
        index = [table count] - 1;
        [map setObject: [NSNumber numberWithInt:index] forKey:value];
    }
    return index;
}


// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
//    [super encodeWithCoder:coder];
    [coder encodeObject:table];
    [coder encodeObject:map];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];//WithCoder:coder];
    table = [[coder decodeObject] retain];
    map = [[coder decodeObject] retain];
    return self;
}
@end
