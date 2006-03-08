/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
/* PajeEvent.m
 *
 *
 * 20021112 BS creation (from A0Event)
 */

#include "PajeEvent.h"
#include "../General/NSUserDefaults+Additions.h"
#include "../General/UniqueString.h"
#include "../General/Protocols.h"
#include "../General/PajeType.h"
#include "../General/Macros.h"

@implementation NSMutableDictionary(xPajeEvent)
+ (id)eventWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    return [[[self alloc] initWithObjects:objects forKeys:keys] autorelease];
}

#if 0
- (id)xxinitWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    self = [super init];
    fieldDict = [[NSMutableDictionary alloc] initWithObjects:objects
                                                     forKeys:keys];
    return self;
}

- (id)xxmutableCopyWithZone:(NSZone *)zone
{
    PajeEvent *copy = [[[self class] allocWithZone:zone] init];
    copy->fieldDict = [fieldDict mutableCopyWithZone:zone];
    return copy;
}
- (id)xinitWithName:(NSString *)n
{
    self = [super init];
    fieldDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:n, @"PajeEventName", nil];
    return self;
}

- (void)xdealloc
{
    [fieldDict release];
    [super dealloc];
}

//
// Methods for being an NSMutableDictionary
//

- (unsigned)xcount
{
    return [fieldDict count];
}

- (id)objectForKey:(id)aKey
{
    return [fieldDict objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [fieldDict keyEnumerator];
}

- (NSArray *)allKeys
{
    return [fieldDict allKeys];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    [fieldDict setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)theKey
{
    [fieldDict removeObjectForKey:theKey];
}

- (NSString *)description
{
    return [fieldDict description];
//    return [NSString stringWithFormat:@"%@ in thread %@ at time %@",
//        [self name], [self thread], [[self time] description]];
}
#endif
- (NSString *)pajeEventName    {return [self objectForKey:@"PajeEventName"];}
- (NSDate *)time      {return [self objectForKey:@"Time"];}

- (NSArray *)fieldNames
{
    return [self allKeys];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    return [self objectForKey:fieldName];
}

- (void)setValue:(id)fieldValue ofFieldNamed:(NSString *)fieldName
{
    [self setObject:fieldValue forKey:fieldName];
}

#if 0
// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:fieldDict];
}

- (id)initWithCoder:(NSCoder *)coder
{
    fieldDict = [[coder decodeObject] retain];

    return self;
}
#endif
@end
