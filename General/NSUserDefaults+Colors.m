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
#include "NSUserDefaults+Colors.h"
#include "UniqueString.h"

#ifndef GNUSTEP
@implementation NSColor (Additions)
+ (NSColor *)colorFromString:(NSString *)value
{
    if ([value isKindOfClass:[NSString class]]) {
        NSScanner *scanner = [NSScanner scannerWithString:value];
        NSString *colorSpaceName;
        NSString *s1, *s2;
        float a, b, c, d, e;

        if ([scanner scanUpToString:@" " intoString:&colorSpaceName]) {
            if ([colorSpaceName isEqual:NSDeviceCMYKColorSpace]) {
                if (   [scanner scanFloat:&a] && [scanner scanFloat:&b]
                       && [scanner scanFloat:&c] && [scanner scanFloat:&d]
                       && [scanner scanFloat:&e])
                    return [NSColor colorWithDeviceCyan:a magenta:b yellow:c black:d alpha:e];
            } else if ([colorSpaceName isEqual:NSDeviceWhiteColorSpace]) {
                if ([scanner scanFloat:&a] && [scanner scanFloat:&b])
                    return [NSColor colorWithDeviceWhite:a alpha:b];
            } else if ([colorSpaceName isEqual:NSCalibratedWhiteColorSpace]) {
                if ([scanner scanFloat:&a] && [scanner scanFloat:&b])
                    return [NSColor colorWithCalibratedWhite:a alpha:b];
            } else if ([colorSpaceName isEqual:NSDeviceRGBColorSpace]) {
                if (   [scanner scanFloat:&a] && [scanner scanFloat:&b]
                       && [scanner scanFloat:&c] && [scanner scanFloat:&d])
                    return [NSColor colorWithDeviceRed:a green:b blue:c alpha:d];
            } else if ([colorSpaceName isEqual:NSCalibratedRGBColorSpace]) {
                if (   [scanner scanFloat:&a] && [scanner scanFloat:&b]
                       && [scanner scanFloat:&c] && [scanner scanFloat:&d])
                    return [NSColor colorWithCalibratedRed:a green:b blue:c alpha:d];
            } else if ([colorSpaceName isEqual:NSNamedColorSpace]) {
                if (   [scanner scanUpToString:@" " intoString:&s1]
                       && [scanner scanUpToString:@" " intoString:&s2])
                    return [NSColor colorWithCatalogName:s1 colorName:s2];
            }
        }
    }
    return nil;
}

@end
#endif

@implementation NSUserDefaults (Colors)
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
@end

@implementation NSUserDefaults (ArchivedObjects)
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
