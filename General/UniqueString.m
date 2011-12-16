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
#include "UniqueString.h"
#include <Foundation/NSSet.h>
#include <Foundation/NSCoder.h>
#include <Foundation/NSInvocation.h>
#include <Foundation/NSEnumerator.h>

@implementation UniqueString

NSMutableSet *TheUniqueStringsSet;

+ (void)initialize
{
    if (!TheUniqueStringsSet) {
#ifdef GNUSTEP
       TheUniqueStringsSet = [[NSMutableSet alloc] init];
#else
       TheUniqueStringsSet = [[NSMutableSet allocWithZone:NSCreateZone(0, NSPageSize(), NO)] init];
#endif
    }
}

+ (UniqueString *)stringWithString:(NSString *)s;
{
    UniqueString *uniquestring = [TheUniqueStringsSet member:s];
    if (!uniquestring) {
        uniquestring = (id)s;//[[UniqueString allocWithZone:[TheUniqueStringsSet zone]] initWithString:s];
        [TheUniqueStringsSet addObject:uniquestring];
        //[uniquestring autorelease];
    }
    return uniquestring;
}

- (id)initWithString:(NSString *)s
{
//#ifndef GNUSTEP
    self = [super init];
//#endif
    if (self) {
        string = [s copyWithZone:[self zone]];
    }
    return self;
}

// primitive methods
//- (unsigned int)length;
//{
//    return [string length];
//}

#ifdef GNUSTEP
// GNUstep expects cStringLength to be defined
//- (unsigned int)cStringLength
//{
//    return [string cStringLength];
//}
#endif


//- (unichar)characterAtIndex:(unsigned)index;
//{
//    return [string characterAtIndex:index];
//}

int C1, C2, C3, C4;
+ (void)printCs {
    NSLog(@"%d %d %d %d", C1, C2, C3, C4);
}

- (NSString *)description
{
    return [string description];
}

// NSObject protocol
- (BOOL)isEqual:(id)object;
{
    C1++;
    if (self == object) return YES;
    C2++;
    if ([object class] == [UniqueString class]) return NO;
    C3++;
    return [string isEqual:object];
}

- (unsigned)hash;
{
    return [string hash];
}

// UniqueStrings are unique and are never released
- (id)retain { return self; }
- (oneway void)release { }
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return 1; }

- (id)copyWithZone:(NSZone *)z { C4++; return self; }

// NSCoding Protocol
- (Class)classForCoder
{
    return [UniqueString class];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:string];
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSString *s;
    UniqueString *uniquestring;
    s = [coder decodeObject];
    uniquestring = [UniqueString stringWithString:s];
    [super release];
    return uniquestring;
}

//
// Forwards other messages to uniqued object
//

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [string respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:string];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [string methodSignatureForSelector:sel];
}

@end

@implementation NSString (UnifyStrings)
- (id)unifyStrings
{
//NSLog(@"Str %@", self);
    return U(self);
}
@end

@implementation NSArray (UnifyStrings)
- (id)unifyStrings
{
    NSMutableArray *unified;
    int i;
    int count;

//NSLog(@"Arr");
    count = [self count];
    unified = [NSMutableArray arrayWithCapacity:count];

    for (i = 0; i < count; i++) {
//    NSLog(@"  %d %@", i, [self objectAtIndex:i]);
        [unified addObject:[[self objectAtIndex:i] unifyStrings]];
    }

    return unified;
}
@end

@implementation NSDictionary (UnifyStrings)
- (id)unifyStrings
{
    NSMutableDictionary *unified;
    NSEnumerator *keyEnum;
    id key;
    id value;
//    NSLog(@"Dic");

    unified = [NSMutableDictionary dictionaryWithCapacity:[self count]];

    keyEnum = [self keyEnumerator];
    while ((key = [keyEnum nextObject]) != nil) {
        value = [self objectForKey:key];
//    NSLog(@"  %@ -> %@", key, value);
	[unified setObject:[value unifyStrings] forKey:[key unifyStrings]];
    }

    return unified;
}
@end

