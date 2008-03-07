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
#ifndef _DataScanner_h_
#define _DataScanner_h_

//
// DataScanner
//
// scans an NSData
//

#include <Foundation/Foundation.h>
#include "Macros.h"

@interface DataScanner : NSObject
{
    NSData *data;
    int position;
}

+ (DataScanner *)scannerWithData:(NSData *)_data;
- (id)initWithData:(NSData *)_data;
- (NSData *)data;

- (unsigned)position;
- (void)setPosition:(unsigned)_position;

- (int)readChar;
- (NSNumber *)readIntNumber;
- (NSNumber *)readDoubleNumber;
- (double)readDouble;
- (NSString *)readString;

- (BOOL)isAtEnd;

@end

#endif
