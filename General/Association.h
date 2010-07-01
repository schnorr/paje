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
#ifndef _Association_h_
#define _Association_h_

/* Association
 * -----------
 * Store an association of an object and a double
 */

#include <Foundation/Foundation.h>

@interface Association : NSObject <NSCoding>
{
    id object;
    double value;
}

+ (Association *)associationWithObject:(id)obj double:(double)d;
- (id)initWithObject:(id)obj double:(double)d;

- (id)objectValue;
- (double)doubleValue;

- (void)addDouble:(double)d;

- (NSComparisonResult)inverseDoubleValueComparison:(Association *)other;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)anObj;
@end
#endif
