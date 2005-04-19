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
#ifndef _COMPARING_H_
#define _COMPARING_H_

/* Comparing.h created by benhur on Thu 21-Aug-1997 */

#include <AppKit/AppKit.h>

@protocol Comparing
- (NSComparisonResult)compare:other;
@end

@interface NSDate (C)<Comparing>
@end

@interface NSNumber(Comparing)
- (BOOL) isDifferent:(id) obj;
- (BOOL) isGreaterThan:(id) obj;
- (BOOL) isLessThan:(id) obj;
- (BOOL) isGreaterOrEqual:(id) obj;
- (BOOL) isLessOrEqual:(id) obj;
@end

#endif                          // Comparing.h created by benhur on Thu 21-Aug-1997 */
