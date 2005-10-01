/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
/* PieCell.m created by benhur on Wed 24-Sep-1997 */

#include "PieCell.h"
#include "../General/Macros.h"
#include "../General/NSColor+Additions.h"
#include <math.h>

static NSString *formatNumber(double n)
{
    static char *p = "TGMk munp";
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
        return [NSString stringWithFormat:@"%s%3.1f%c", neg?"-":"", n, p[i]];
    return [NSString stringWithFormat:@"%s%3d%c", neg?"-":"", (int)n, p[i]];
}


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


@implementation PieCell
// We do not retain our data provider, it retains us.
- (void)setDataProvider:(id)provider
{
    dataProvider = provider;
}

- (void)setData:(StatArray *)d
{
    Assign(data, d);
}

- (void)setInitialAngle:(NSNumber *)angle
{
    initialAngle = angle;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    //NSDrawGrayBezel(cellFrame, cellFrame);
    [[NSColor lightGrayColor] set];
    NSRectFill(cellFrame);
    [[NSColor blackColor] set];
    NSFrameRect(cellFrame);
    [super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawTitleWithFrame:(NSRect)cellFrame
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *paragraphStyle;
    NSFont *font;

    paragraphStyle = (NSMutableParagraphStyle *)
                     [NSMutableParagraphStyle defaultParagraphStyle];
    [paragraphStyle setAlignment:NSCenterTextAlignment];

    font = [[NSFontManager sharedFontManager] convertFont:[NSFont userFontOfSize:12] toHaveTrait:NSBoldFontMask];
    
    // write title
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:[NSColor blackColor]
                   forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraphStyle
                   forKey:NSParagraphStyleAttributeName];
    [[data name] drawInRect:cellFrame
                withAttributes:attributes];
    //[[data name] drawAtCTPoint:NSMakePoint(NSMidX(cellFrame),
    //                                       NSMinY(cellFrame)+20)
    //            withAttributes:attributes];
}

- (void)drawInteriorWithFrameVBar:(NSRect)cellFrame inView:(NSView *)controlView
{
    StatValue *value;
    NSEnumerator *valEnum;
    float x, y, h, hmax, w, wmax;
    float val, total, max, min, cnt;
    float fontHeight = 0;
    NSFont *font = nil;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    if (nil == data) {
        [dataProvider provideDataForCell:self];
        if (nil == data)
            return;
    }

    // take totalizers
    total = [data sum];
    max = [data maxValue];
    min = [data minValue];
    cnt = [data count];

    PSsetlinewidth(1);

    if (!simple) {
        // calculate sizes, with space for title and names
        hmax = NSHeight(cellFrame) - 4 - 35;
        wmax = NSWidth(cellFrame) - 4 - 30;
        y = NSMaxY(cellFrame) - 2 - 35;
        w = wmax / cnt;
        x = NSMaxX(cellFrame) - 2 - wmax;

        font = [NSFont userFontOfSize:10];
        [attributes setObject:font
                       forKey:NSFontAttributeName];
        [attributes setObject:[NSColor blackColor]
                       forKey:NSForegroundColorAttributeName];
        fontHeight = [font ascender] - [font descender];

        // draw scale
        PSmoveto(x-2, y);
        PSrlineto(-3, 0);
        PSmoveto(x-2, y-hmax);
        PSrlineto(-3, 0);
        PSstroke();
        [@"0" drawAtRCPoint:NSMakePoint(x - 7, y) withAttributes:attributes];
        [formatNumber(max) drawAtRCPoint:NSMakePoint(x - 7, y - hmax)
                          withAttributes:attributes];
   } else {
       // calculate sizes, without space for title and names
        hmax = NSHeight(cellFrame) - 4;
        wmax = NSWidth(cellFrame) - 4;
        y = NSMaxY(cellFrame) - 2;
        w = wmax / cnt;
        x = NSMaxX(cellFrame) - 2 - wmax;
    }

    valEnum = [data objectEnumerator];
    while ((value = [valEnum nextObject]) != nil) {
        val = [value doubleValue];

        // draw bar
        [[value color] set];
        h = hmax * val / max;
        PSrectfill(x, y, w, -h);
        [[NSColor blackColor] set];
        PSrectstroke(x, y, w, -h);

        if (!simple) {
            NSString *valueString;
            [attributes setObject:[NSColor blackColor]
                           forKey:NSForegroundColorAttributeName];
            // draw name under bar
            PSgsave();
            if (w > fontHeight) {
                double angle;
                angle = atan(fontHeight / sqrt(w*w + fontHeight*fontHeight));
                PStranslate(x + 0.9*w - fontHeight * sin(angle), y);
                PSrotate(-angle * 180 / M_PI);
            } else {
                PStranslate(x + w/2 - fontHeight/2, y);
                PSrotate(-90);
            }
            [[value name] drawAtRTPoint:NSMakePoint(0, 0)
                         withAttributes:attributes];
            PSgrestore();
            
            // draw value over bar
            if (showPercent) {
                valueString = [NSString stringWithFormat:@"%.1f%%",
                                                         100*val/total];
            } else {
                valueString = formatNumber(val);
            }

            if ((hmax - h) >= fontHeight) {
                [valueString drawAtCBPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
            } else {
                [attributes setObject:[[value color] contrastingWhiteOrBlackColor]
                               forKey:NSForegroundColorAttributeName];
                [valueString drawAtCTPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
            }
        }

        x += w;
    }
}


- (void)drawInteriorWithFramePie:(NSRect)cellFrame inView:(NSView *)controlView
{
    StatValue *value;
    NSEnumerator *valEnum;
    float radius, angle1, angle2, mid_angle;
    NSPoint center;
    float val, total;
    float others = 0;
    float fontHeight = 0;
    NSFont *font = nil;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    if (nil == data) {
        [dataProvider provideDataForCell:self];
        if (nil == data)
            return;
    }

    // take totalizers
    total = [data sum];
    if (total == 0)
        return;

    if (!simple) {
        // set font for slice names
        font = [NSFont userFontOfSize:10];
        [attributes setObject:font
                       forKey:NSFontAttributeName];
        fontHeight = [font ascender] - [font descender];
    }

    // calculate center, radius of pie circle
    center = NSMakePoint(NSMidX(cellFrame), NSMidY(cellFrame));
    radius = MIN(NSWidth(cellFrame) * .5 - 20,
                 NSHeight(cellFrame) * .5 - fontHeight - 4);

    // Fill pie slices
    angle1 = (initialAngle != nil) ? [initialAngle floatValue] : 0;
    valEnum = [data objectEnumerator];
    while (value = [valEnum nextObject]) {
        val = [value doubleValue];
        if ((val/total) < .05) {
            others += val;
            continue;
        }

        angle2 = angle1 + 360 * val / total;

        // draw the pie segment and border
        PSnewpath();
        PSmoveto(center.x, center.y);
        PSarc(center.x, center.y, radius, angle1, angle2);
        PSclosepath();
        [[value color] set];
        PSfill();

        // next segment starts where this one ends
        angle1 = angle2;
    }

    // draw slices' separators
    PSnewpath();
    angle1 = (initialAngle != nil) ? [initialAngle floatValue] : 0;
    valEnum = [data objectEnumerator];
    while (value = [valEnum nextObject]) {
        val = [value doubleValue];
        if ((val/total) < .05) continue;

        angle2 = angle1 + 360 * val / total;

        PSmoveto(center.x, center.y);
        PSarc(center.x, center.y, radius, angle1, angle2);

        // next segment starts where this one ends
        angle1 = angle2;
    }
    if (others > 0) {
        angle2 = angle1 + 360 * others / total;

        PSmoveto(center.x, center.y);
        PSarc(center.x, center.y, radius, angle1, angle2);
    }
    PSclosepath();
    [[NSColor blackColor] set];
    PSsetlinewidth(2);
    PSsetlinejoin(1); // rounded

    PSstroke();

    if (!simple) {
        NSString *valueString;
        NSColor *sliceTextColor;
        NSPoint sliceCenter;

        // draw lines from slices to where text will be
        angle1 = (initialAngle != nil) ? [initialAngle floatValue] : 0;
        valEnum = [data objectEnumerator];
        while (value = [valEnum nextObject]) {
            val = [value doubleValue];
            if ((val/total) < .05) continue;

            angle2 = angle1 + 360 * val / total;

            // angle in the middle of the slice (in radians)
            mid_angle = (angle1 + angle2) / 2;
            if (mid_angle > 360) mid_angle -= 360;
            // convert to radians
            mid_angle = M_PI * mid_angle / 180;

            PSmoveto(center.x+(radius*1.05)*cos(mid_angle),
                     center.y+(radius*1.05)*sin(mid_angle));
            PSlineto(center.x+(radius*1.15)*cos(mid_angle),
                     center.y+(radius*1.15)*sin(mid_angle));
            if (mid_angle > M_PI_2 && mid_angle < 3 * M_PI_2) {
                PSrlineto(-10, 0);
            } else {
                PSrlineto(10, 0);
            }

            // next segment starts where this one ends
            angle1 = angle2;
        }
        PSsetlinewidth(1);
        PSstroke();

        // draw slice value inside and name outside
        angle1 = (initialAngle != nil) ? [initialAngle floatValue] : 0;
        valEnum = [data objectEnumerator];
        while (value = [valEnum nextObject]) {
            val = [value doubleValue];
            if ((val/total) < .05) continue;

            angle2 = angle1 + 360 * val / total;

            // angle in the middle of the slice (in radians)
            mid_angle = (angle1 + angle2) / 2;
            if (mid_angle > 360) mid_angle -= 360;
            // convert to radians
            mid_angle = M_PI * mid_angle / 180;

            // write value inside slice
            // what to write
            if (showPercent) {
                valueString = [NSString stringWithFormat:@"%.1f%%",
                                                         100*val/total];
            } else {
                valueString = formatNumber(val);
                //valueString = [NSString stringWithFormat:@"%.2f", val];
            }
            // color to write (black or white, the one with better contrast)
            sliceTextColor = [[value color] contrastingWhiteOrBlackColor];

            [attributes setObject:sliceTextColor
                           forKey:NSForegroundColorAttributeName];
            // where to write
            sliceCenter = NSMakePoint(center.x+(radius*.7)*cos(mid_angle),
                                      center.y+(radius*.7)*sin(mid_angle));
            [valueString drawAtCCPoint:sliceCenter withAttributes:attributes];

            // draw the name of the slice
            [attributes setObject:[NSColor blackColor]
                           forKey:NSForegroundColorAttributeName];

            if (mid_angle > M_PI_2 && mid_angle < 3 * M_PI_2) {
                NSPoint point;
                point = NSMakePoint(center.x+(radius*1.15)*cos(mid_angle) - 12,
                                    center.y+(radius*1.15)*sin(mid_angle));
                [[value name] drawAtRCPoint:point withAttributes:attributes];
            } else {
                NSPoint point;
                point = NSMakePoint(center.x+(radius*1.15)*cos(mid_angle) + 12,
                                    center.y+(radius*1.15)*sin(mid_angle));
                [[value name] drawAtLCPoint:point withAttributes:attributes];
            }

            // next segment starts where this one ends
            angle1 = angle2;
        }

    }
}


- (void)setGraphType:(int)t
{
    type = t;
}

- (void)setShowPercent:(BOOL)yn
{
    showPercent = yn;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self drawTitleWithFrame:cellFrame];
    cellFrame.origin.y += 15;
    cellFrame.size.height -= 15;
    switch(type) {
        case 0: [self drawInteriorWithFramePie:cellFrame inView:controlView];
            break;
        case 1: [self drawInteriorWithFrameVBar:cellFrame inView:controlView];
            break;
        case 2: [self drawInteriorWithFrameVBar:cellFrame inView:controlView];
            break;
    }
}

@end
