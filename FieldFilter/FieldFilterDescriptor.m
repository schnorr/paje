/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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
/* FieldFilterDescriptor.m created by benhur on Sun 03-Jan-2005 */

#include "FieldFilterDescriptor.h"
#include "../General/Macros.h"

@implementation FieldFilterDescriptor

+ (FieldFilterDescriptor *)descriptorWithFieldName:(NSString *)fn
                                       comparision:(int)c
                                             value:(id)v
{
    return [[[self alloc] initWithFieldName:fn
                                comparision:c
                                      value:v] autorelease];
}

- (id)initWithFieldName:(NSString *)fn
             comparision:(int)c
                   value:(id)v
{
    self = [super init];
    if (self != nil) {
        Assign(fieldName, fn);
        comparision = c;
        Assign(value, v);
    }
    return self;
}

- (void)dealloc
{
   Assign(fieldName, nil);
   Assign(value, nil);
   [super dealloc];
}

- (NSString *)fieldName
{
    return fieldName;
}

- (int)comparision
{
    return comparision;
}

- (id)value
{
    return value;
}
@end
