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
#include "StatViewer.h"
#include "../General/Macros.h"
#include "../General/NSColor+Additions.h"
#include "../General/NSString+Additions.h"
#include <math.h>


@interface PieSlice : NSObject
{
    float initialAngle;
    float finalAngle;
    NSColor *color;
    NSBezierPath *path;
    NSString *name;
    NSString *complement;
    NSMutableString *label;
    NSPoint labelAnchorPosition;
    NSPoint labelPosition;
    BOOL rightSide;
    PieCell *cell;
}

+ (PieSlice *)sliceWithInitialAngle:(float)a1
                         finalAngle:(float)a2
                              color:(NSColor *)col
                               name:(NSString *)n
                         complement:(NSString *)n2
                               cell:(PieCell *)c;
- (id)initWithInitialAngle:(float)a1
                finalAngle:(float)a2
                     color:(NSColor *)col
                      name:(NSString *)n
                complement:(NSString *)n2
                      cell:(PieCell *)c;

- (void)makePath;
- (void)makeLabelPosition;
- (NSPoint)labelPosition;
- (void)setLabelPosition:(NSPoint)position
                   width:(float)width;
- (BOOL)rightSide;
- (float)midAngle;

- (void)draw;
- (void)drawLabel;
- (void)appendLabelLinesToPath:(NSBezierPath *)incompletePath;
- (void)appendDivisionLinesToPath:(NSBezierPath *)incompletePath;
- (BOOL)containsPoint:(NSPoint)point;
@end

@implementation PieSlice
+ (PieSlice *)sliceWithInitialAngle:(float)a1
                         finalAngle:(float)a2
                              color:(NSColor *)col
                               name:(NSString *)n
                         complement:(NSString *)n2
                               cell:(PieCell *)c
{
    return [[[self alloc] initWithInitialAngle:a1
                                    finalAngle:a2
                                         color:col
                                          name:n
                                    complement:n2
                                          cell:c] autorelease];
}

- (id)initWithInitialAngle:(float)a1
                finalAngle:(float)a2
                     color:(NSColor *)col
                      name:(NSString *)n
                complement:(NSString *)n2
                      cell:(PieCell *)c
{
    self = [super init];
    if (self != nil) {
        cell = c;
        initialAngle = a1;
        finalAngle = a2;
        Assign(color, col);
        Assign(name, n);
        Assign(complement, n2);
        label = [name mutableCopy];
        [self makePath];
        [self makeLabelPosition];
    }
    return self;
}

- (void)dealloc
{
    cell = nil;
    Assign(color, nil);
    Assign(path, nil);
    Assign(name, nil);
    Assign(complement, nil);
    Assign(label, nil);
    [super dealloc];
}

- (void)makePath
{
    NSPoint center = [cell center];
    float radius = [cell radius];

    Assign(path, [NSBezierPath bezierPath]);
    [path setLineWidth:2];
    [path setLineJoinStyle:NSRoundLineJoinStyle];

    [path appendBezierPathWithArcWithCenter:center
                                     radius:radius
                                 startAngle:initialAngle
                                   endAngle:finalAngle];
    [path appendBezierPathWithArcWithCenter:center
                                     radius:radius * .3
                                 startAngle:finalAngle
                                   endAngle:initialAngle
                                  clockwise:YES];
}

- (void)makeLabelPosition
{
    double radianAngle;
    float cosine;
    float sine;
    float r;
    NSPoint center = [cell center];
    float radius = [cell radius];

    radianAngle = [self midAngle] * M_PI / 180;
    cosine = cos(radianAngle);
    sine = sin(radianAngle);
    rightSide = (cosine >= 0);

    r = radius * .85;
    labelAnchorPosition = NSMakePoint(center.x + r * cosine,
                                      center.y + r * sine);
    r = radius + 6 + 4 * fabs(sine);
    if (rightSide) {
        labelPosition = NSMakePoint(center.x + r * cosine + 6,
                                    center.y + r * sine);
    } else {
        labelPosition = NSMakePoint(center.x + r * cosine - 6,
                                    center.y + r * sine);
    }
}

- (NSPoint)labelPosition
{
    return labelPosition;
}

- (void)setLabelPosition:(NSPoint)position
                   width:(float)width
{
    labelPosition = position;
    NSDictionary *labelAttributes = [cell labelAttributes];

    if (label != nil) [label release];
    label = [name mutableCopy];

    NSString *elipsis = [NSString stringWithCharacter:0x2026];
    while ([label sizeWithAttributes:labelAttributes].width > width) {
        int middle;
        middle = [label length] / 2;
        [label replaceCharactersInRange:NSMakeRange(middle, 2)
                             withString:elipsis];
    }
}

- (BOOL)rightSide
{
    return rightSide;
}

- (float)midAngle
{
    return (initialAngle + finalAngle) / 2;
}

- (void)draw
{
    [color set];
    [path fill];
}

- (void)drawLabel
{
    NSPoint lpoint;
    NSPoint cpoint;
    NSDictionary *labelAttributes = [cell labelAttributes];
    NSDictionary *complementAttributes = [cell complementAttributes];

    if (rightSide) {
        lpoint = NSMakePoint(labelPosition.x + 2,
                             labelPosition.y - 3);
        cpoint = NSMakePoint(labelPosition.x + 2,
                             labelPosition.y + 5);

        [label drawAtLCPoint:lpoint withAttributes:labelAttributes];
        [complement drawAtLCPoint:cpoint withAttributes:complementAttributes];
    } else {
        lpoint = NSMakePoint(labelPosition.x - 2,
                             labelPosition.y - 3);
        cpoint = NSMakePoint(labelPosition.x - 2,
                             labelPosition.y + 5);

        [label drawAtRCPoint:lpoint withAttributes:labelAttributes];
        [complement drawAtRCPoint:cpoint withAttributes:complementAttributes];
    }
}

- (void)appendLabelLinesToPath:(NSBezierPath *)incompletePath
{
    [incompletePath moveToPoint:labelPosition];
    [incompletePath relativeMoveToPoint:NSMakePoint(0, 8)];
    [incompletePath relativeLineToPoint:NSMakePoint(0, -15)];
    [incompletePath moveToPoint:labelPosition];
    if (rightSide) {
        [incompletePath relativeLineToPoint:NSMakePoint(-6, 0)];
    } else {
        [incompletePath relativeLineToPoint:NSMakePoint(6, 0)];
    }
    [incompletePath lineToPoint:labelAnchorPosition];
    [incompletePath appendBezierPathWithArcWithCenter:labelAnchorPosition
                                               radius:1.0
                                           startAngle:0
                                             endAngle:360];
}
    
- (void)appendDivisionLinesToPath:(NSBezierPath *)incompletePath
{
    NSPoint center = [cell center];
    float radius = [cell radius];

    if (finalAngle - initialAngle < 359.99) {
        double radianAngle;
        radianAngle = initialAngle * M_PI / 180;
        [incompletePath moveToPoint:
                             NSMakePoint(center.x+radius*.3*cos(radianAngle),
                                         center.y+radius*.3*sin(radianAngle))];
        [incompletePath lineToPoint:
                             NSMakePoint(center.x+radius*cos(radianAngle),
                                         center.y+radius*sin(radianAngle))];
    }
}

- (BOOL)containsPoint:(NSPoint)point
{
    return [path containsPoint:point];
}

@end



@implementation PieCell

- (void)_init
{
    data = nil;
    slices = nil;
    divisionsPath = nil;
    labelLinesPath = nil;
    // set atributes for slice labels and complement
    labelAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSFont systemFontOfSize:10], NSFontAttributeName,
            [NSColor blackColor], NSForegroundColorAttributeName,
            nil];
    complementAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSFont systemFontOfSize:8], NSFontAttributeName,
            [NSColor colorWithCalibratedWhite:0.1 alpha:1.0],
                NSForegroundColorAttributeName,
            nil];
}

- (id)copyWithZone:(NSZone *)z
{
    self = [super copyWithZone:z];
    [self _init];
    return self;
}

- (id)initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    [self _init];
    return self;
}

- (id)initTextCell:(NSString *)text
{
    self = [super initTextCell:text];
    [self _init];
    return self;
}

- (void)dealloc
{
    dataProvider = nil;
    Assign(data, nil);
    Assign(slices, nil);
    Assign(divisionsPath, nil);
    Assign(labelLinesPath, nil);
    Assign(labelAttributes, nil);
    Assign(complementAttributes, nil);

    [super dealloc];
}

// The data provider retains the cells, so they cannot retain it.
- (void)setDataProvider:(id)provider
{
    dataProvider = provider;
}

- (void)setData:(StatArray *)d
{
    Assign(data, d);
    [self discardCache];
}

- (void)discardCache
{
    Assign(slices, nil);
    Assign(divisionsPath, nil);
    Assign(labelLinesPath, nil);
}

- (void)setInitialAngle:(NSNumber *)angle
{
    initialAngle = angle;
}

- (NSPoint)center
{
    return center;
}

- (float)radius
{
    return radius;
}

- (NSDictionary *)labelAttributes
{
    return labelAttributes;
}

- (NSDictionary *)complementAttributes
{
    return complementAttributes;
}




- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [[NSColor lightGrayColor] set];
    NSRectFill(cellFrame);
    [[NSColor blackColor] set];
    NSFrameRect(cellFrame);
    [super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawTitleWithFrame:(NSRect)cellFrame
{
    NSDictionary *attributes;

    if (nil == data) {
        [dataProvider provideDataForCell:self];
        if (nil == data)
            return;
    }
    
    attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSFont boldSystemFontOfSize:12], NSFontAttributeName,
            [NSColor blackColor], NSForegroundColorAttributeName,
            nil];
    [[data name] drawAtCTPoint:NSMakePoint(NSMidX(cellFrame), NSMinY(cellFrame))
                withAttributes:attributes];
}

- (void)drawInteriorWithFrameVBar:(NSRect)cellFrame inView:(NSView *)controlView
{
#ifdef VBARSUPPORT
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
    total = [data totalValue];
    max = total;//[data maxValue];
    min = 0;//[data minValue];
    cnt = [data subCount];
    if (cnt>10) cnt=10;

    PSsetlinewidth(1);

    if (!simple) {
        // calculate sizes, with space for title and names
        hmax = NSHeight(cellFrame) - 4 - 35;
        if (initialAngle != nil) {
            hmax = NSHeight(cellFrame) * [initialAngle floatValue] / 380;
        }
        wmax = NSWidth(cellFrame) - 4 - 35;
        y = NSMinY(cellFrame)+20+hmax;//NSMaxY(cellFrame) - 2 - 35;
        w = wmax / cnt;
        x = NSMaxX(cellFrame) - 2 - wmax;

        font = [NSFont systemFontOfSize:10];
        [attributes setObject:font
                       forKey:NSFontAttributeName];
        [attributes setObject:[NSColor blackColor]
                       forKey:NSForegroundColorAttributeName];
        fontHeight = [font ascender] - [font descender];

        // draw scale
        PSmoveto(x-2, y);
        //PSrlineto(-3, 0);
        PSrlineto(2, 0);
        PSrlineto(wmax, 0);

        PSmoveto(x-2, y-hmax/2);
        PSrlineto(2, 0);
        PSrlineto(wmax, 0);

        PSmoveto(x-2, y-hmax);
        //PSrlineto(-3, 0);
        PSrlineto(2, 0);
        PSrlineto(wmax, 0);
        [[NSColor darkGrayColor] set];
    PSgsave();
    float dash[] = {1, 2};
    PSsetdash(dash, 2, 0);
        PSstroke();
    PSgrestore();
        //[@"0" drawAtRCPoint:NSMakePoint(x - 7, y) withAttributes:attributes];
        [[NSString stringWithFormattedNumber:min]
                           drawAtRCPoint:NSMakePoint(x - 7, y)
                          withAttributes:attributes];
        [[NSString stringWithFormattedNumber:max]
                           drawAtRCPoint:NSMakePoint(x - 7, y - hmax)
                          withAttributes:attributes];
    } else {
        // calculate sizes, without space for title and names
        hmax = NSHeight(cellFrame) - 4;
        wmax = NSWidth(cellFrame) - 4;
        y = NSMaxY(cellFrame) - 2;
        w = wmax / cnt;
        x = NSMaxX(cellFrame) - 2 - wmax;
    }

    unsigned index;
    unsigned count = [data subCount];
    for (index = 0; index < count && index < 10; index++) {
        val = [data subDoubleValueAtIndex:index];

        // draw bar
        [[data subColorAtIndex:index] set];
        h = hmax * val / max;
        PSrectfill(x, y, w, -h);
        [[NSColor blackColor] set];
        PSrectstroke(x, y, w, -h);

        if (!simple) {
            NSString *valueString;
            NSString *percentString;
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
            [attributes setObject:[NSColor blackColor]
                           forKey:NSForegroundColorAttributeName];
            [[data subValueAtIndex:index] drawAtRTPoint:NSMakePoint(0, 0)
                         withAttributes:attributes];
            PSgrestore();
            
            // draw value over bar
            valueString = [NSString stringWithFormattedNumber:val];
            percentString = [NSString stringWithFormat:@"%.1f%%",
                            100 * val / total];

            if ((hmax - h) >= fontHeight && h >= fontHeight) {
                [valueString drawAtCBPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
                [attributes setObject:[[data subColorAtIndex:index] contrastingWhiteOrBlackColor]
                               forKey:NSForegroundColorAttributeName];
                [percentString drawAtCTPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
            } else if ((hmax - h) >= fontHeight * 1.9) {
                [valueString drawAtCBPoint:NSMakePoint(x+w/2, y-h - .9*fontHeight)
                            withAttributes:attributes];
                [percentString drawAtCBPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
            } else if (h >= fontHeight * 1.9) {
                [attributes setObject:[[data subColorAtIndex:index] contrastingWhiteOrBlackColor]
                               forKey:NSForegroundColorAttributeName];
                [valueString drawAtCTPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
                [percentString drawAtCTPoint:NSMakePoint(x+w/2, y-h + .9*fontHeight)
                            withAttributes:attributes];
            } else if ((hmax - h) >= fontHeight) {
                [valueString drawAtCBPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
            } else if (h >= fontHeight) {
                [attributes setObject:[[data subColorAtIndex:index] contrastingWhiteOrBlackColor]
                               forKey:NSForegroundColorAttributeName];
                [valueString drawAtCTPoint:NSMakePoint(x+w/2, y-h)
                            withAttributes:attributes];
            }
        }

        x += w;
    }
#endif
}

- (void)addPieSliceWithName:(NSString *)sliceName
               initialAngle:(float)angle1
                      color:(NSColor *)color
                      value:(float)val
                 totalValue:(float)total
{
    float angle2;
    float midangle;
    float fraction;
    PieSlice *slice;
    NSString *complement;
    
    fraction = val / total;
    angle2 = angle1 + 360 * fraction;
    midangle = (angle1 + angle2) / 2;

    complement = [NSString stringWithFormat:@"%@s, %.1f%%",
                    [NSString stringWithFormattedNumber:val], 100 * fraction];
    slice = [PieSlice sliceWithInitialAngle:angle1
                                 finalAngle:angle2
                                      color:color
                                       name:sliceName
                                 complement:complement
                                       cell:self];
    [slices addObject:slice];
}

- (NSArray *)slicesFromAngle:(float)a1 toAngle:(float)a2
{
    unsigned index;
    unsigned count;
    float midAngle;
    float lastAngle;
    PieSlice *slice;
    NSMutableArray *selectedSlices;
    BOOL firstPass;
    unsigned secondPassIndex;

    lastAngle = -HUGE_VAL;
    firstPass = YES;
    secondPassIndex = 0;
    selectedSlices = [NSMutableArray array];
    count = [slices count];
    for (index = 0; index < count; index++) {
        slice = [slices objectAtIndex:index];
        midAngle = [slice midAngle];
        if (midAngle >= 360) midAngle -= 360;
        if (midAngle >= a2) continue;
        if (midAngle < a1) continue;
        if (firstPass && (midAngle < lastAngle)) {
            firstPass = NO;
        }
        if (firstPass) {
            [selectedSlices addObject:slice];
            lastAngle = midAngle;
        } else {
            [selectedSlices insertObject:slice atIndex:secondPassIndex++];
        }
    }
    return selectedSlices;
}

// Adjust the positions of labels so that they do not intersect.
// can be made better, with a left adjusting and a right adjusting function,
// and by allowing labels to use more vertical space, maybe passing
// multiple times by the slices.
- (void)adjustSlicesFromAngle:(float)a1
                      toAngle:(float)a2
                     quadrant:(int)quadrant
                         xRef:(float)xref
{
    float ypos;
    NSEnumerator *eachSlice;
    PieSlice *slice;
    float vsignal;
    float hsignal;
    float midAngle;
    NSPoint pos;
    NSArray *selectedSlices;

    selectedSlices = [self slicesFromAngle:a1 toAngle:a2];
    if (quadrant == 1 || quadrant == 3) {
        eachSlice = [selectedSlices reverseObjectEnumerator];
    } else {
        eachSlice = [selectedSlices objectEnumerator];
    }
    
    if (quadrant == 1 || quadrant == 2) {
        vsignal = -1;
    } else {
        vsignal = 1;
    }
    
    if (quadrant == 1 || quadrant == 4) {
        hsignal = 1;
    } else {
        hsignal = -1;
    }

    ypos = -HUGE_VAL * vsignal;
    while ((slice = [eachSlice nextObject]) != nil) {
        midAngle = [slice midAngle];
        pos = [slice labelPosition];
        ypos += vsignal * 17;
        if (vsignal * (pos.y - ypos) >= 0) {
            ypos = pos.y;
        } else {
            pos.x += hsignal * sin(midAngle*M_PI/180) * (pos.y - ypos);
            pos.y = ypos;
        }
        [slice setLabelPosition:pos width:xref - hsignal * pos.x];
    }
}

- (void)adjustLabelPositionsInFrame:(NSRect)cellFrame
{
    float minX;
    float maxX;
    minX = -5;
    maxX = NSMaxX(cellFrame) - 5;
    [self adjustSlicesFromAngle:0   toAngle:90  quadrant:1 xRef:maxX];
    [self adjustSlicesFromAngle:90  toAngle:150 quadrant:2 xRef:minX];
    [self adjustSlicesFromAngle:150 toAngle:270 quadrant:3 xRef:minX];
    [self adjustSlicesFromAngle:270 toAngle:360 quadrant:4 xRef:maxX];
}

- (void)makeLabelLinesPath
{
    Assign(labelLinesPath, [NSBezierPath bezierPath]);
    [labelLinesPath setLineWidth:1];
    [labelLinesPath setLineJoinStyle:NSRoundLineJoinStyle];
    [slices makeObjectsPerformSelector:@selector(appendLabelLinesToPath:)
                            withObject:labelLinesPath];
}

- (void)makeDivisionsPath
{
    Assign(divisionsPath, [NSBezierPath bezierPath]);
    [divisionsPath setLineWidth:2];
    [divisionsPath setLineJoinStyle:NSRoundLineJoinStyle];
    [divisionsPath appendBezierPathWithArcWithCenter:center
                                              radius:radius
                                          startAngle:0
                                            endAngle:360];
    [divisionsPath moveToPoint:NSMakePoint(center.x + radius * .3, center.y)];
    [divisionsPath appendBezierPathWithArcWithCenter:center
                                              radius:radius * .3
                                          startAngle:0
                                            endAngle:360];
    [slices makeObjectsPerformSelector:@selector(appendDivisionLinesToPath:)
                            withObject:divisionsPath];
}

- (void)makeSlicesWithFrame:(NSRect)cellFrame
{
    int index;
    int count;
    float angle0;
    float angle;
    float val;
    float total;
    float others = 0;
    int nothers = 0;

    Assign(slices, [NSMutableArray array]);

    // take totalizers
    total = [data totalValue];
    if (total == 0)
        return;

    // calculate center, radius of pie circle
    center = NSMakePoint(NSMidX(cellFrame), NSMidY(cellFrame) - 3);
    radius = MIN(NSWidth(cellFrame) * .5 - 20,
                 NSHeight(cellFrame) * .5 - 17);

    // Make pie slices
    angle0 = (initialAngle != nil) ? [initialAngle floatValue] : 0;
    angle = angle0;
    count = [data subCount];
    for (index = 0; index < count; index++) {
        val = [data subDoubleValueAtIndex:index];
        if ((val/total) < .05 && (nothers > 0 || index < (count-1))) {
            others += val;
            nothers++;
            continue;
        }

        [self addPieSliceWithName:[data subValueAtIndex:index]
                     initialAngle:angle
                            color:[data subColorAtIndex:index]
                            value:val
                       totalValue:total];

        // next segment starts where this one ends
        angle +=  360 * val / total;
    }
    if (nothers > 0) {
        NSString *sliceName;
        sliceName = [NSString stringWithFormat:@"%d Others", nothers];
        [self addPieSliceWithName:sliceName
                     initialAngle:angle
                            color:[NSColor controlColor]
                            value:others
                       totalValue:total];
        angle += 360 * others / total;
    }
    float unusedAngle;
    unusedAngle = angle0+360 - angle;
    if (unusedAngle > .1) {
        val = unusedAngle/360 * total;
        [self addPieSliceWithName:@"None"
                     initialAngle:angle
                            color:[NSColor controlColor]
                            value:val
                       totalValue:total];
    }

    [self adjustLabelPositionsInFrame:cellFrame];
    [self makeLabelLinesPath];
    [self makeDivisionsPath];
}

- (void)drawInteriorWithFramePie:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (nil == data) {
        [dataProvider provideDataForCell:self];
        if (nil == data)
            return;
    }
    if (nil == slices) {
        [self makeSlicesWithFrame:cellFrame];
    }

    [slices makeObjectsPerformSelector:@selector(draw)];
    [slices makeObjectsPerformSelector:@selector(drawLabel)];

    [[NSColor blackColor] set];
    [divisionsPath stroke];
    [labelLinesPath stroke];
}


- (void)setGraphType:(int)t
{
    type = t;
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
