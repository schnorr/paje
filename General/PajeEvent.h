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
#ifndef _PajeEvent_h_
#define _PajeEvent_h_

/* PajeEvent.h
 *
 *
 * 20021112 BS creation (from A0Event)
 */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "../General/Protocols.h"

/*
@interface PajeEvent : NSObject <NSCoding>
{
    NSMutableDictionary *fieldDict;
}
*/

#define PajeEvent NSMutableDictionary
@interface NSMutableDictionary (xPajeEvent)
- (NSString *)pajeEventName;
- (NSDate *)time;

+ (id)eventWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;
#if 0
- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (NSArray *)allKeys;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)removeObjectForKey:(id)theKey;
#endif

- (NSArray *)fieldNames;
- (id)valueOfFieldNamed:(NSString *)fieldName;
- (void)setValue:(id)fieldValue ofFieldNamed:(NSString *)fieldName;

#if 0
// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
#endif
@end

#endif
