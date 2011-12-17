/*
    Copyright (c) 2005 Benhur Stein
    
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
#include "NSColor+Additions.h"

@implementation NSColor (Additions1)
- (NSColor *)contrastingWhiteOrBlackColor
{
    NSColor *bw;
    float wc;
    NSColor *ret;

    bw = [self colorUsingColorSpaceName:NSCalibratedWhiteColorSpace];
    wc = [bw whiteComponent];
    if (wc > .5) {
        //ret = [NSColor blackColor];
        ret = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0];
    } else {
        //ret = [NSColor whiteColor];
        ret = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
    }
    return ret;
}
@end

#ifndef GNUSTEP
@implementation NSColor (Additions2)
+ (NSColor *)colorFromString:(NSString *)value
{
    if ([value isKindOfClass:[NSString class]]) {
        NSScanner *scanner = [NSScanner scannerWithString:value];
	float r, g, b;
	if ([scanner scanFloat: &r] &&
            [scanner scanFloat: &g] &&
            [scanner scanFloat: &b]){
		return [NSColor colorWithDeviceRed:r green:g blue:b alpha:1];
        }
    }
	NSLog (@"input=%@ output=%@", value, nil);
    return nil;
}
@end
#endif
