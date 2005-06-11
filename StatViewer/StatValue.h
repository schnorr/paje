/*
    Copyright (c) 1997-2005 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
#ifndef _StatValue_h_
#define _StatValue_h_
/* StatValue.h created by benhur on Fri 26-Sep-1997 */

#include <AppKit/AppKit.h>

@interface StatValue : NSObject
{
    double value;
    NSColor *color;
    NSString *name;
}

+ (StatValue *)valueWithValue:(double)v color:(NSColor *)c name:(NSString *)s;
- (id)initWithValue:(double)v color:(NSColor *)c name:(NSString *)s;

- (void)setValue:(double)v;
- (void)setColor:(NSColor *)c;
- (void)setName:(NSString *)s;
- (void)addToValue:(double)v;

- (double)value;
- (double)doubleValue;
- (NSColor *)color;
- (NSString *)name;

- (unsigned int)hash;
- (BOOL)isEqual:(id)anObj;
@end
#endif