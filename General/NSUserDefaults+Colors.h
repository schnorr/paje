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
#ifndef _NSUserDefaults_Colors_h_
#define _NSUserDefaults_Colors_h_

#include <AppKit/AppKit.h>

// GNUstep implements this but does not declares publically
@interface NSColor (Additions)
+ (NSColor *)colorFromString:(NSString *)value;
@end


@interface NSUserDefaults (Colors)
- (void)setColor:(NSColor *)color forKey:(NSString *)key;
- (NSColor *)colorForKey:(NSString *)key;
- (void)setColorDictionary:(NSDictionary *)dict forKey:(NSString *)key;
- (NSDictionary *)colorDictionaryForKey:(NSString *)key;
- (void)setRect:(NSRect)rect forKey:(NSString *)key;
- (NSRect)rectForKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
@end

@interface NSUserDefaults (ArchivedObjects)
- (void)setArchivedObject:(id)anObject forKey:(NSString *)aKey;
- (id)unarchiveObjectForKey:(NSString *)aKey;
@end

#endif
