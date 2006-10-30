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
#ifndef _NSString_Additions_h_
#define _NSString_Additions_h_

#include <Foundation/NSString.h>

@interface NSString (Additions)
+ (NSString *)stringWithCharacter:(unichar)c;
+ (NSString *)stringWithFormattedNumber:(double)n;
- (NSRange)rangeForLineNumber:(unsigned)lineNumber;
- (unsigned)lineNumberAtIndex:(unsigned)index;
- (NSRange)rangeValue;
+ (NSString *)stringWithRange:(NSRange)range;
- (NSString *)stringValue;
@end


#include <AppKit/NSStringDrawing.h>

@interface NSString (PajeNSStringPositionDrawing)
// additions to NSString to support drawing them in many positions
// relative to a given point. Uses NSStringAdditions methods to do this.
// Should not be called if the focus is not locked to some view.
// All methods are of the form: drawAtXYPoint: ...,
// where X can be L, C or R, meaning that the x coordinate of aPoint
// should be at the left, center or right of the string, and
// Y can be B, C or T (bottom, center or top)
- (void)drawAtLTPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtLCPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtLBPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtCTPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtCCPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtCBPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtRTPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtRCPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
- (void)drawAtRBPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes;
@end


#endif
