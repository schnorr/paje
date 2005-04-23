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
#include "NSUserDefaults+Additions.h"
#include "NSColor+Additions.h"
#include "UniqueString.h"

@implementation NSUserDefaults (Additions)
- (void)setColor:(NSColor *)color forKey:(NSString *)key
{
    [self setObject:[color description] forKey:[key description]];
}

- (NSColor *)colorForKey:(NSString *)key
{
    return [NSColor colorFromString:[self objectForKey:key]];
}

- (void)setColorDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
    NSMutableDictionary *newdict = [NSMutableDictionary dictionary];
    NSEnumerator *en = [dict keyEnumerator];
    id colorKey;
    while ((colorKey = [en nextObject]) != nil) {
        NSColor *c = [dict objectForKey:colorKey];
        if ([c isKindOfClass:[NSColor class]]) {
            [newdict setObject:[c description] forKey:[colorKey description]];
        }
    }
    [self setObject:newdict forKey:[key description]];
}

- (NSDictionary *)colorDictionaryForKey:(NSString *)key
{
    NSDictionary *dict = [self dictionaryForKey:key];
    if (dict != nil) {
        NSEnumerator *en = [dict keyEnumerator];
        id key;
        NSColor *c;
        NSMutableDictionary *newdict = [NSMutableDictionary dictionary];
        while ((key = [en nextObject]) != nil) {
            c = [NSColor colorFromString:[dict objectForKey:key]];
            if (c != nil) {
                [newdict setObject:c forKey:U(key)];
            }
        }
        dict = newdict;
    }
    return dict;
}

- (void)setRect:(NSRect)rect forKey:(NSString *)key
{
    [self setObject:NSStringFromRect(rect) forKey:key];
}

- (NSRect)rectForKey:(NSString *)key
{
    NSString *s = [self stringForKey:key];
    if (s != nil) {
        return NSRectFromString(s);
    } else {
        return NSZeroRect;
    }
}

- (void)setDouble:(double)value forKey:(NSString *)key
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

- (double)doubleForKey:(NSString *)key
{
    id obj;

    obj = [self objectForKey:key];
    if (obj != nil && ([obj isKindOfClass:[NSString class]]
                    || [obj isKindOfClass:[NSNumber class]])) {
        return [obj doubleValue];
    }
    return 0;
}


- (void)setArchivedObject:(id)anObject forKey:(NSString *)aKey
{
    NSData *archivedObject;

    archivedObject = [NSArchiver archivedDataWithRootObject:anObject];
    [self setObject:archivedObject forKey:aKey];
}

- (id)unarchiveObjectForKey:(NSString *)aKey
{
    NSData *archivedObject;

    archivedObject = [self objectForKey:aKey];
    if ([archivedObject isKindOfClass:[NSData class]]) {
        return [NSUnarchiver unarchiveObjectWithData:archivedObject];
    } else {
        return archivedObject;
    }
} 
@end 
