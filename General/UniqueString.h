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
#ifndef _UniqueString_h_
#define _UniqueString_h_

// UniqueString.h
//
// Strings of this class are uniqued, all equal instances are the same object.
//

#include <Foundation/NSObject.h>

#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>

#define U(s) [UniqueString stringWithString:s]

@interface UniqueString : NSObject
{
    NSObject *string;
}

+ (UniqueString *)stringWithString:(NSString *)s;

// primitive methods
//- (unsigned int)length;			
//- (unichar)characterAtIndex:(unsigned)index;

// NSObject protocol
- (BOOL)isEqual:(id)object;
- (unsigned)hash;
@end

@interface NSString (UnifyStrings)
- (id)unifyStrings;
@end

@interface NSArray (UnifyStrings)
- (id)unifyStrings;
@end

@interface NSDictionary (UnifyStrings)
- (id)unifyStrings;
@end

#endif
