/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
#ifndef _StatArray_h_
#define _StatArray_h_
/* StatArray.h created by benhur on Fri 26-Sep-1997 */

#include <Foundation/Foundation.h>
#include "../General/PajeType.h"
#include "../General/PajeFilter.h"
#include "../General/CondensedEntitiesArray.h"

@interface StatArray : NSObject
{
    NSString *name;
    PajeEntityType *entityType;
    PajeFilter *filter;
}

+ (StatArray *)stateArrayWithName:(NSString *)theName
                             type:(PajeEntityType *)type
                        startTime:(NSDate *)start
                          endTime:(NSDate *)end
                           filter:(PajeFilter *)f
                 entityEnumerator:(NSEnumerator *)en;

- (id)initWithName:(NSString *)theName
              type:(PajeEntityType *)type
            filter:(PajeFilter *)f;

- (NSString *)name;

- (double)totalValue;
- (double)maxValue;
- (double)minValue;

- (unsigned)subCount;
- (id)subValueAtIndex:(unsigned)index;
- (NSColor *)subColorAtIndex:(unsigned)index;
- (double)subDoubleValueAtIndex:(unsigned)index;
@end
#endif
