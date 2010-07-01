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
/*
 * OrderKey.m
 * ----------
 * Key for an ordered array of containers
 * contains the entityType and the container
 */

// 20-mar-2001 BS created

#include <OrderKey.h>
#include "../General/Macros.h"
#include <Foundation/NSArray.h>

@implementation OrderKey
+ (OrderKey *)keyWithEntityType:(id)e container:(id)c
{
    return [[[self alloc] initWithEntityType:e container:c] autorelease];
}

- (id)initWithEntityType:(id)e container:(id)c
{
    self = [super init];
    if (self) {
        Assign(entityType, e);
        Assign(container, c);
    }
    return self;
}

- (void)dealloc
{
    Assign(entityType, nil);
    Assign(container, nil);
    [super dealloc];
}

- (id)container
{
    return container;
}

- (id)entityType
{
    return entityType;
}

- (BOOL)isEqual:(id)other
{
    if (![other isKindOfClass:[OrderKey class]])
        return NO;
    return [entityType isEqual:[(OrderKey *)other entityType]]
        && [container isEqual:[(OrderKey *)other container]];
}

- (NSUInteger)hash
{
    return [entityType hash] ^ [container hash];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSString *)description
{
    return [[NSArray arrayWithObjects:entityType, container, nil] description];
}
@end
