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
#ifndef _TranslationTable_h_
#define _TranslationTable_h_

// TranslationTable
//
// has elements of type <index, value>, both integers.
// index is sequential, starting at 0. it's the order of insertion
//       in the table.
// value is any number.
// has methods to return a value, given an index (like an array)
// and to return the index of a given value.

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

@interface TranslationTable: NSObject
{
    NSMutableArray    *table;    // to map from indexes to values
    NSMutableDictionary        *map;    // to map from values to indexes
    // change to NSMapTable when it exists.
}

// Initializing
+ (TranslationTable *)translationTable;
- (id)init;

// Querying
- (unsigned)count;
- (unsigned)indexOfValue:(id)value;
- (id)valueAtIndex:(unsigned)index;

// Adding Elements
- (unsigned)addValue:(id)value;    // returns index of element
                                    // doesn't insert if already exists

// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
@end

#endif
