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

@implementation NSColor (Additions)
#ifndef GNUSTEP
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
#endif

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
