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

#include <AppKit/AppKit.h>

@interface StatArray : NSMutableSet
{
    NSMutableSet *array;
    double sum;
    double max;
    double min;
    NSString *name;
}

+ (StatArray *)arrayWithName:(NSString *)theName;
- (id)init;
- (id)initWithName:(NSString *)theName;

- (void)addObject:(id/*<StatValue>*/)object;
- (unsigned)count;
- (NSEnumerator *)objectEnumerator;

- (double)sum;
- (void)setSum:(double)value;
- (double)maxValue;
- (double)minValue;
- (void)setName:(NSString *)newName;
- (NSString *)name;

@end
#endif
