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
#include "NSString+Additions.h"

@implementation NSString (Additions)
+ (NSString *)stringWithCharacter:(unichar)c
{
    return [NSString stringWithCharacters:&c length:1];
}

+ (NSString *)stringWithFormattedNumber:(double)n
{
    static char *p = "TGMk m\xb5np";
    int i = 4;
    BOOL neg = (n < 0);

    if (neg)
        n = -n;
    if (n < 1e-12)
        return neg ? @"-0" : @"0";
    if (n > 999e12)
        return neg ? @"-Inf" : @"Inf";
    while (n < 1) {
        n *= 1000;
        i++;
    }
    while (n > 1000) {
        n /= 1000;
        i--;
    }
    if (n < 10)
        return [NSString stringWithFormat:@"%s%.1f%c", neg?"-":"", n, p[i]];
    return [NSString stringWithFormat:@"%s%d%c", neg?"-":"", (int)n, p[i]];
}



#define UNICHAR_BUFF_SIZE 1024

// Adapted from Mike Ferris' TextExtras
- (NSRange)rangeForLineNumber:(unsigned)lineNumber
{
    NSUInteger curLineNum = 1;
    NSUInteger startCharIndex = NSNotFound;
    unichar buff[UNICHAR_BUFF_SIZE];
    unsigned i = 0, buffCount = 0;
    NSRange searchRange = NSMakeRange(0, [self length]);
    
    // Returned range should start at beginning of lineNumber
    // and end at beginning of lineNumber+1.
    if (lineNumber < 1) lineNumber = 1;
    if (lineNumber == 1) startCharIndex = 0;
    while (searchRange.length > 0) {
        buffCount = MIN(searchRange.length, UNICHAR_BUFF_SIZE);
        [self getCharacters:buff
                      range:NSMakeRange(searchRange.location, buffCount)];
        // We're counting paragraph separators here.  We want to notice when
        // we hit lineNum and remember where the starting char index is.  We
        // also want to notice when we reach lineNum+1 and return the result.
        for (i=0; i < buffCount; i++) {
            if (buff[i] == '\n') {
                curLineNum++;
                if (curLineNum == lineNumber)
                    startCharIndex = searchRange.location + i + 1;
                else if (curLineNum == (lineNumber + 1)) {
                    unsigned charIndex = (searchRange.location + i + 1);
                    return NSMakeRange(startCharIndex,
                                       charIndex - startCharIndex);
                }
            }
        }
        // Skip the search range past the part we just did.
        searchRange.location += buffCount;
        searchRange.length -= buffCount;
    }
    
    // If we're here, we didn't find the end of the line number range.
    // searchRange.location == [string length] at this point.
    if (startCharIndex == NSNotFound) {
    // We didn't find the start of the line number range either, so return {EOT, 0}.
        return NSMakeRange(searchRange.location, 0);
    } else {
   // We found the start, so return from there to the end of the text.
        return NSMakeRange(startCharIndex, searchRange.location - startCharIndex);
    }
}

// Adapted from Mike Ferris' TextExtras
- (unsigned)lineNumberAtIndex:(unsigned)index
{
    unsigned lineNumber = 1;
    unichar buff[1024];
    unsigned i, buffCount;
    NSRange searchRange = NSMakeRange(0, MIN(index, [self length]));

    while (searchRange.length > 0) {
        buffCount = MIN(searchRange.length, UNICHAR_BUFF_SIZE);
        [self getCharacters:buff
                      range:NSMakeRange(searchRange.location, buffCount)];
        for (i=0; i < buffCount; i++) {
            if (buff[i] == '\n')
                lineNumber++;
        };
        // Skip the search range past the part we just did.
        searchRange.location += buffCount;
        searchRange.length -= buffCount;
    };

    return lineNumber;
}


- (NSRange)rangeValue
{
    return NSRangeFromString(self);
}

+ (NSString *)stringWithRange:(NSRange)range
{
    return NSStringFromRange(range);
}

- (NSString *)stringValue
{
    return self;
}
@end


@implementation NSString (PajeNSStringPositionDrawing)
- (void)drawAtLTPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    [self drawAtPoint:aPoint withAttributes:attributes];
}
- (void)drawAtLCPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x, aPoint.y - size.height/2);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtLBPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x, aPoint.y - size.height);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtCTPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x - size.width/2, aPoint.y);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtCCPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x - size.width/2, aPoint.y - size.height/2);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtCBPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x - size.width/2, aPoint.y - size.height);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtRTPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x - size.width, aPoint.y);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtRCPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x - size.width, aPoint.y - size.height/2);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
- (void)drawAtRBPoint:(NSPoint)aPoint withAttributes:(NSDictionary *)attributes
{
    NSSize size = [self sizeWithAttributes:attributes];
    NSPoint newPoint = NSMakePoint(aPoint.x - size.width, aPoint.y - size.height);
    [self drawAtPoint:newPoint withAttributes:attributes];
}
@end
