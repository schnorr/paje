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
#ifndef _OrderKey_h_
#define _OrderKey_h_

/*
 * OrderKey.h
 * ----------
 * Key for an ordered array of containers
 * contains the entityType and the container
 */

// 20-mar-2001 BS created

#include <Foundation/NSObject.h>

@interface OrderKey : NSObject
{
    id entityType;
    id container;
}

+ (OrderKey *)keyWithEntityType:(id)e container:(id)c;
- (id)initWithEntityType:(id)e container:(id)c;

- (void)dealloc;

- (id)container;
- (id)entityType;

- (BOOL)isEqual:(OrderKey *)other;
- (unsigned)hash;
@end

#endif
