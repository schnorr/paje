/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
#ifndef _NSUserDefaults_Additions_h_
#define _NSUserDefaults_Additions_h_

#include <AppKit/AppKit.h>

@interface NSUserDefaults (Additions)
- (void)setColor:(NSColor *)color forKey:(NSString *)key;
- (NSColor *)colorForKey:(NSString *)key;
- (void)setColorDictionary:(NSDictionary *)dict forKey:(NSString *)key;
- (NSDictionary *)colorDictionaryForKey:(NSString *)key;
- (void)setRect:(NSRect)rect forKey:(NSString *)key;
- (NSRect)rectForKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;

- (void)setArchivedObject:(id)anObject forKey:(NSString *)aKey;
- (id)unarchiveObjectForKey:(NSString *)aKey;
@end

#endif
