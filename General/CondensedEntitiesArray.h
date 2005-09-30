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
#ifndef _CondensedEntitiesArray_h_
#define _CondensedEntitiesArray_h_

/* CondensedEntitiesArray
 * ----------------------
 * Store an array of names and durations sorted by decreasing duration
 */

#include <Foundation/Foundation.h>

@interface CondensedEntitiesArray : NSObject <NSCoding>
{
    NSMutableArray *array;
    BOOL sorted;
}

+ (CondensedEntitiesArray *)array;
- (id)init;
- (void)dealloc;

- (unsigned)count;
- (NSString *)nameAtIndex:(unsigned)index;

// for states
- (void)addName:(NSString *)name duration:(double)duration;
- (double)durationAtIndex:(unsigned)index;

// for events
- (void)addName:(NSString *)name count:(unsigned)count;
- (unsigned)countAtIndex:(unsigned)index;


- (void)addArray:(CondensedEntitiesArray *)other;
@end
#endif
