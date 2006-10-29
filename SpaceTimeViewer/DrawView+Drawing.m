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
// DrawView+Drawing
// ----------------
// methods for drawing entities in DrawView.

#include "DrawView.h"
#ifdef GNUSTEP
#include <values.h>
#endif

#include "../General/Association.h"

@implementation DrawView (Drawing)

- (void)highlightPath:(NSBezierPath *)hp
{
    float originalLineWidth = [hp lineWidth];
///*
    //NSRect vr = NSInsetRect([hp bounds], -30, -30);
    NSRect vr = [self visibleRect];
    NSBezierPath *cp = [NSBezierPath bezierPath];

    [NSGraphicsContext saveGraphicsState];

    [cp setWindingRule:NSNonZeroWindingRule];
    [cp moveToPoint:NSMakePoint(NSMinX(vr), NSMinY(vr))];
    [cp lineToPoint:NSMakePoint(NSMinX(vr), NSMaxY(vr))];
    [cp lineToPoint:NSMakePoint(NSMaxX(vr), NSMaxY(vr))];
    [cp lineToPoint:NSMakePoint(NSMaxX(vr), NSMinY(vr))];
    [cp closePath];
    [cp appendBezierPath:hp];
    [cp addClip];

    [[NSColor colorWithCalibratedRed:1 green:0.4 blue:0 alpha:0.4] set];
    [hp setLineWidth:4];
    [hp stroke];
    //[hp setLineWidth:7];
    //[hp stroke];
    [hp setLineWidth:10];
    [hp stroke];
    //[[NSColor blackColor] set];
    //[hp setLineWidth:1];
    //[hp stroke];

    [NSGraphicsContext restoreGraphicsState];
//*/
/*
    [[[NSColor yellowColor] colorWithAlphaComponent:0.25] set];
            [hp setLineWidth:14];
            [hp stroke];
            [hp setLineWidth:17];
            [hp stroke];
            [hp setLineWidth:20];
            [hp stroke];
*/

    [hp setLineWidth:originalLineWidth];
}


- (void)drawEventsWithDescriptor:(STEventTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
{
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSBezierPath *path;
    NSColor *color;
    id entity;
    float x, y, w, h;
    BOOL drawNames;
    BOOL sup;
    NSMutableAttributedString *name;

    drawNames = [layout drawsName];
    if (drawNames) {
        name = [[NSMutableAttributedString alloc] 
                initWithString:@""
                    attributes:entityNameAttributes];
    }
    sup = [layout isSupEvent];

    y = [layout yInContainer:container];
    w = [layout width];
    h = [layout height];
    pathFunction = [[layout shapeFunction] function];
    drawFunction = [[layout drawFunction] function];

    path = [NSBezierPath bezierPath];

    while ((entity = [enumerator nextObject]) != nil) {
        x = TIMEtoX([filter timeForEntity:entity]);

        [path removeAllPoints];

        if ([filter isAggregateEntity:entity]) {
            float x2 = TIMEtoX([filter endTimeForEntity:entity]);
            int condensedEntitiesCount;
            unsigned i;
            unsigned count;
            float xi = x;
            float dx;

            condensedEntitiesCount = [entity condensedEntitiesCount];

            count = [filter subCountForEntity:entity];
            for (i = 0; i < count; i++) {
                [[filter subColorAtIndex:i forEntity:entity] set];
                dx = (x2-x) * [filter subCountAtIndex:i forEntity:entity] 
                            / condensedEntitiesCount;
                if (sup) {
                    NSRectFill(NSMakeRect(xi, y-(h-9), dx, 3));
                } else {
                    NSRectFill(NSMakeRect(xi, y+(h-11), dx, 3));
                }
                xi += dx;
            }
            if (sup) {
                [[NSString stringWithFormat:@"%d", condensedEntitiesCount]
                                        drawAtPoint:NSMakePoint(x-5, y-(h-8)-9)
                                     withAttributes:entityNameAttributes];
                [path moveToPoint:NSMakePoint(x2, y+2)];
                [path lineToPoint:NSMakePoint(x2, y-(h-8))];
                [path lineToPoint:NSMakePoint(x, y-(h-8))];
                [path lineToPoint:NSMakePoint(x, y+2)];
            } else {
                [[NSString stringWithFormat:@"%d", condensedEntitiesCount]
                                        drawAtPoint:NSMakePoint(x-5, y+(h-8))
                                     withAttributes:entityNameAttributes];
                [path moveToPoint:NSMakePoint(x, y-2)];
                [path lineToPoint:NSMakePoint(x, y+(h-8))];
                [path lineToPoint:NSMakePoint(x2, y+(h-8))];
                [path lineToPoint:NSMakePoint(x2, y-2)];
            }

            if ([filter isSelectedEntity:entity]) {
                [self highlightPath:path];
            }
            [[NSColor blackColor] set];
            [path stroke];

        } else { // not aggregate

            color = [filter colorForEntity:entity];

            pathFunction(path, NSMakeRect(x, y, w, h));
            if ([filter isSelectedEntity:entity]) {
                [self highlightPath:path];
            }
            drawFunction(path, color);

            if (drawNames) {
                float yt;
                [name replaceCharactersInRange:NSMakeRange(0, [name length])
                                    withString:[[filter valueForEntity:entity] stringValue]];
                if (sup) {
                    yt = y - (h - 2 - w/2 + 5);
                } else {
                    yt = y + (h - 2 - w/2 + 5) - 9;
                }
                //NSRectFill(NSMakeRect(x - w, yt, w * 2, 12));
                if ([[color colorUsingColorSpaceName:NSCalibratedWhiteColorSpace
                                            device:nil] whiteComponent] > 0.5) {
                    [[NSColor blackColor] set];
                } else {
                    [[NSColor whiteColor] set];
                }
                [name drawInRect:NSMakeRect(x - w, yt, w * 2, 12)];
            }

        }

    }
}

#define drawBlackRect(x1, x2, r) \
do { \
    [[NSColor darkGrayColor] set]; \
    NSFrameRect(NSMakeRect(x1, NSMinY(r) + NSHeight(r) / 4, \
                           x2 - x1 + 1, NSHeight(r) / 2)); \
} while (0)

- (void)drawStatesWithDescriptor:(STStateTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
{
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    float insetBy;
    NSColor *color;
    NSBezierPath *path = [NSBezierPath bezierPath];
    id <PajeState>entity;
    float firstUndrawnX = MAXFLOAT;
    float lastUndrawnX = MAXFLOAT;
    float undrawnHeight = 0;
    float x, y, w, h;
    BOOL drawNames;
    NSMutableAttributedString *name;

    drawNames = [layout drawsName];
    if (drawNames) {
        name = [[NSMutableAttributedString alloc] 
                initWithString:@""
                    attributes:entityNameAttributes];
    }

    y = [layout yInContainer:container];
    h = [layout height];
    insetBy = [layout insetAmount];
    [path setLineWidth:1.0];
    pathFunction = [[layout shapeFunction] function];
    drawFunction = [[layout drawFunction] function];

    while ((entity = [enumerator nextObject]) != nil) {
        int imbricationLevel;
        float newHeight;
        float x2;
        float ox, ow;

        x = TIMEtoX([filter startTimeForEntity:entity]);
        x2 = TIMEtoX([filter endTimeForEntity:entity]);
        ox = x;
        ow = x2 - x;
#ifdef GNUSTEP
        // Very big rectangles are not drawn in GNUstep 
        if (x < NSMinX(cutRect)) x = NSMinX(cutRect);
        if (x2 > NSMaxX(cutRect)) x2 = NSMaxX(cutRect);
#endif
        w = x2 - x;
        imbricationLevel = [filter imbricationLevelForEntity:entity];
        newHeight = h - insetBy * imbricationLevel;
        if (newHeight < 2) {
            newHeight = 2;
        }
        if (newHeight > h) {
            newHeight = h;
        }
        
        if (w < 2) {
            if ((lastUndrawnX != MAXFLOAT) && (x2 < firstUndrawnX)) {
                drawBlackRect(firstUndrawnX, lastUndrawnX,
                              NSMakeRect(x, y, w, undrawnHeight));
                undrawnHeight = 0;
                lastUndrawnX = x2;
            }
            if (lastUndrawnX == MAXFLOAT) {
                lastUndrawnX = x2;
            }
            if (firstUndrawnX > x) {
                firstUndrawnX = x;
            }
            if (newHeight > undrawnHeight) {
                undrawnHeight = newHeight;
            }
            continue;
        }

        if (firstUndrawnX != MAXFLOAT) {
            drawBlackRect(firstUndrawnX, lastUndrawnX,
                          NSMakeRect(x, y, w, undrawnHeight));
            firstUndrawnX = lastUndrawnX = MAXFLOAT;
            undrawnHeight = 0;
        }

        NSRect rect;

        rect = NSMakeRect(x, y, w, newHeight);
        [path removeAllPoints];
        pathFunction(path, rect);

        if ([filter isAggregateEntity:entity]) {
            [path moveToPoint:NSMakePoint(x, y)];
            [path lineToPoint:NSMakePoint(x+w, y+newHeight)];
            unsigned i;
            unsigned count = [filter subCountForEntity:entity];
            for (i = 0; i < count; i++) {
                float dx;
                [[filter subColorAtIndex:i forEntity:entity] set];
                dx = [filter subDurationAtIndex:i forEntity:entity]
                   * pointsPerSecond;
                rect.size.width = dx;
                NSRectFill(rect);
                rect.origin.x += dx;
            }
            if (rect.origin.x <= (x + w - 1)) {
                [path moveToPoint:NSMakePoint(rect.origin.x, y+newHeight)];
                [path lineToPoint:NSMakePoint(x+w, y)];
            }
            if ([filter isSelectedEntity:entity]) {
                [self highlightPath:path];
            }
            drawFunction(path, nil);// REVER
        } else { // !aggregate
            color = [filter colorForEntity:entity];

            if ([filter isSelectedEntity:entity]) {
                [self highlightPath:path];
            }
            drawFunction(path, color);
            if (drawNames && ow > smallEntityWidth && newHeight > 8) {
                [name replaceCharactersInRange:NSMakeRange(0, [name length])
                                    withString:[[filter valueForEntity:entity] stringValue]];
                [name drawInRect:NSMakeRect(ox+2, y + newHeight - 10, ow, 10)];
            }
        }

    }

    if (firstUndrawnX != MAXFLOAT) {
        drawBlackRect(firstUndrawnX, lastUndrawnX,
                      NSMakeRect(x, y, w, undrawnHeight));
    }

    if (drawNames) {
        [name release];
    }
}

// helper function for drawing variables.
// adds min max traits to a path.
static void addToMinMaxPath(NSBezierPath *path,
                     float xMin, float xMax,
                     float yAvg, float yMin, float yMax)
{
    if (yMax == yMin) {
//        return;
    }
    float xAvg = (xMin + xMax) / 2;

    //[path moveToPoint:NSMakePoint(xMin, yAvg)];
    //[path lineToPoint:NSMakePoint(xMax, yAvg)];
    //[path moveToPoint:NSMakePoint(xAvg, yMin)];
    //[path lineToPoint:NSMakePoint(xAvg, yMax)];
    [path moveToPoint:NSMakePoint(xAvg-5, yMin)];
    [path lineToPoint:NSMakePoint(xAvg+5, yMin)];
    [path moveToPoint:NSMakePoint(xAvg-5, yMax)];
    [path lineToPoint:NSMakePoint(xAvg+5, yMax)];
}

- (void)drawValuesWithDescriptor:(STVariableTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
{
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSBezierPath *valuePath;
    NSBezierPath *selectedPath;
    NSBezierPath *minMaxPath;
    BOOL showMinMax;
    NSColor *color;
    id <PajeState>entity;
    float yMin;
    float yMax;
    float yScale;
    float yOffset;
    float yOld;
    float yvMin;
    float yvMax;
    BOOL first = YES;
    BOOL hasHighlight = NO;
    PajeEntityType *entityType;
    
    entityType = [layout entityType];

    yMin = [layout minValue];
    yMax = [layout maxValue];
    if (yMax <= yMin) {
        yMin = [filter minValueForEntityType:entityType];
        yMax = [filter maxValueForEntityType:entityType];
    }
    pathFunction = [[layout shapeFunction] function];
    drawFunction = [[layout drawFunction] function];

    if (yMin != yMax) {
        yScale = -([layout height] - 4) / (yMax - yMin);
    } else {
        yScale = 1;
    }

    yOffset = [layout yInContainer:container] + 2 - (yMax * yScale);

    valuePath = [[NSBezierPath alloc] init];
    [valuePath setLineJoinStyle: NSBevelLineJoinStyle];
    selectedPath = [[NSBezierPath alloc] init];
    [selectedPath setLineJoinStyle: NSBevelLineJoinStyle];

    showMinMax = [layout showMinMax];
    if (showMinMax) {
        minMaxPath = [[NSBezierPath alloc] init];
    }

    while ((entity = [enumerator nextObject]) != nil) {
        float xStart;
        float xEnd;
        float y;

        xStart = TIMEtoX([filter startTimeForEntity:entity]);
        xEnd = TIMEtoX([filter endTimeForEntity:entity]);
        y = [filter doubleValueForEntity:entity] * yScale + yOffset;
        yvMin = [filter minValueForEntity:entity] * yScale + yOffset;
        yvMax = [filter maxValueForEntity:entity] * yScale + yOffset;

        if (first) {
            [valuePath moveToPoint:NSMakePoint(xEnd, y)];
            first = NO;
        } else {
            pathFunction(valuePath, NSMakeRect(xStart, y, xEnd-xStart, 0));
        }
        if ([filter isSelectedEntity:entity]) {
            [selectedPath moveToPoint:NSMakePoint(xEnd, yOld)];
            pathFunction(selectedPath, NSMakeRect(xStart, y, xEnd-xStart, 0));
            hasHighlight = YES;
        }
        yOld = y;
        if (showMinMax) {
            addToMinMaxPath(minMaxPath, xStart, xEnd, y, yvMin, yvMax);
        }
    }

    if (showMinMax) {
        [[NSColor blackColor] set];
        [minMaxPath stroke];
        [minMaxPath release];
    }

    if (hasHighlight) {
        [self highlightPath:selectedPath];
    }
    color = [filter colorForEntityType:entityType];
    [valuePath setLineWidth:[layout lineWidth]];
    drawFunction(valuePath, color);

    [valuePath release];
    [selectedPath release];
}

- (void)drawLinksWithDescriptor:(STLinkTypeLayout *)layout
                    inContainer:(PajeContainer *)container
                 fromEnumerator:(NSEnumerator *)enumerator
{
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSColor *color;
    id <PajeLink>entity;
    float x1, x2, y1, y2;
    NSBezierPath *path;

    pathFunction = [[layout shapeFunction] function];
    drawFunction = [[layout drawFunction] function];

    path = [NSBezierPath bezierPath];

    [path setLineWidth:[layout lineWidth]];

    while ((entity = [enumerator nextObject]) != nil) {
        PajeContainer *sourceContainer;
        PajeContainer *destContainer;

        sourceContainer = [filter sourceContainerForEntity:entity];
        if (sourceContainer != nil) {
            PajeEntityType *eType;
            STContainerTypeLayout *cDesc;
            NSRect rect;

            eType = [filter sourceEntityTypeForEntity:entity];
            cDesc = (STContainerTypeLayout *)[controller descriptorForEntityType:eType];
            rect = [cDesc rectOfInstance:sourceContainer];
            y1 = NSMinY(rect) + [cDesc linkOffset];
            x1 = TIMEtoX([filter startTimeForEntity:entity]);
        }
        destContainer = [filter destContainerForEntity:entity];
        if (destContainer != nil) {
            PajeEntityType *eType;
            STContainerTypeLayout *cDesc;
            NSRect rect;

            eType = [filter destEntityTypeForEntity:entity];
            cDesc = (STContainerTypeLayout *)[controller descriptorForEntityType:eType];
            rect = [cDesc rectOfInstance:destContainer];
            y2 = NSMinY(rect) + [cDesc linkOffset];
            x2 = TIMEtoX([filter endTimeForEntity:entity]);
        }

        [path removeAllPoints];

        color = [filter colorForEntity:entity];

        //if (sourceContainer && destContainer) {
        if (sourceContainer == nil) {
            shapefunction PSIn;
            PSIn(path, NSMakeRect(x2, y2, 8, 8));
        } else if (destContainer == nil) {
            shapefunction PSOut;
            PSOut(path, NSMakeRect(x1, y1, 8, 8));
        } else {
            pathFunction(path, NSMakeRect(x1, y1, x2-x1, y2-y1));
        }
        if ([filter isSelectedEntity:entity]) {
            [self highlightPath:path];
        }
        drawFunction(path, color);
    }
}

- (void)drawBackgroundForContainer:(PajeContainer *)container
                        descriptor:(STContainerTypeLayout *)layout
                        insideRect:(NSRect)drawRect
{

    if ([[filter selectedContainers] containsObject:container]) {
        [[NSColor whiteColor] set];
        NSRectFill([layout rectOfInstance:container]);
    }

    float yScale;
    float yOffset;
    float yMin;
    float yMax;

    yMin = [layout minValue];
    yMax = [layout maxValue];

    if (yMin >= yMax) {
        return;
    }

    yScale = -([layout heightForVariables] - 4) / (yMax - yMin);

    yOffset = NSMinY([layout rectOfInstance:container]) 
            + [layout variablesOffset] + 2 - (yMax * yScale);
    NSBezierPath *hashMarkPath;
    hashMarkPath = [[NSBezierPath alloc] init];
    NSEnumerator *en = [[layout hashMarkValues] objectEnumerator];
    NSNumber *n;
    while ((n = [en nextObject]) != nil) {
        float v = [n floatValue];
        float y = v * yScale + yOffset;
        [hashMarkPath moveToPoint:NSMakePoint(NSMinX(drawRect), y)];
        [hashMarkPath lineToPoint:NSMakePoint(NSMaxX(drawRect), y)];
    }
    [[NSColor gridColor] set];
    [hashMarkPath stroke];
    [hashMarkPath release];

    double dt;
    // calculate dv, delta time for at least 70 px between hash marks
    dt = 70 / pointsPerSecond;

    int i = 0;
    while (dt < .5) {
        dt *= 10;
        i--;
    }
    while (dt >= 5) {
        dt /= 10;
        i++;
    }

    if (dt > 2) dt = 5;
    else if (dt > 1) dt = 2;
    else dt = 1;

    while (i > 0) {
        dt *= 10;
        i--;
    }
    while (i < 0) {
        dt /= 10;
        i++;
    }
        
    hashMarkPath = [[NSBezierPath alloc] init];

    double t;
    double minT;
    double maxT;
    minT = [XtoTIME(NSMinX(drawRect)) timeIntervalSinceReferenceDate];
    maxT = [XtoTIME(NSMaxX(drawRect)) timeIntervalSinceReferenceDate];
    for (t = (int)(minT/dt) * dt; t <= maxT; t += dt) {
        float x = TIMEtoX([NSDate dateWithTimeIntervalSinceReferenceDate:t]);
        [hashMarkPath moveToPoint:NSMakePoint(x, yMin * yScale + yOffset)];
        [hashMarkPath lineToPoint:NSMakePoint(x, yMax * yScale + yOffset)];
    }
    //[[NSColor whiteColor] set];
    [hashMarkPath stroke];
    [hashMarkPath release];

}

- (void)drawEntitiesWithDescriptor:(STEntityTypeLayout *)layoutDescriptor
                       inContainer:(PajeContainer *)container
                    fromEnumerator:(NSEnumerator *)enumerator
{
    switch ([layoutDescriptor drawingType]) {
    case PajeEventDrawingType:
        [self drawEventsWithDescriptor:(STEventTypeLayout *)layoutDescriptor
                           inContainer:container
                        fromEnumerator:enumerator];
        break;
    case PajeStateDrawingType:
        [self drawStatesWithDescriptor:(STStateTypeLayout *)layoutDescriptor
                           inContainer:container
                        fromEnumerator:enumerator];
        break;
    case PajeLinkDrawingType:
        [self drawLinksWithDescriptor:(STLinkTypeLayout *)layoutDescriptor
                          inContainer:container
                       fromEnumerator:enumerator];
        break;
    case PajeVariableDrawingType:
        [self drawValuesWithDescriptor:(STVariableTypeLayout *)layoutDescriptor
                           inContainer:container
                        fromEnumerator:enumerator];
        break;
    case PajeContainerDrawingType:
        break;
    default:
        NSAssert1(0, @"Invalid drawing type %d", [layoutDescriptor drawingType]);
    }
}

- (void)drawEntitiesWithDescriptor:(STEntityTypeLayout *)layoutDescriptor
                       inContainer:(PajeContainer *)container
                        insideRect:(NSRect)drawRect
{
    NSDate *drawStartTime;
    NSDate *drawEndTime;
    NSEnumerator *enumerator;
    NSRect rect;
    PajeEntityType *entityType;
    PajeDrawingType drawingType;

    rect = [layoutDescriptor rectInContainer:container];

    if (![layoutDescriptor intersectsRect:drawRect inContainer:container]) {
        return;
    }
    drawingType = [layoutDescriptor drawingType];
    entityType = [layoutDescriptor entityType];

    float width;
    if (drawingType == PajeEventDrawingType) {
        width = [(STEventTypeLayout *)layoutDescriptor width];
    } else {
        width = 1;
    }
    drawStartTime = XtoTIME(NSMinX(drawRect) - width);
    drawEndTime   = XtoTIME(NSMaxX(drawRect) + width);
    if (drawingType == PajeVariableDrawingType) {
NSLog(@"a %@ - %@", drawStartTime, drawEndTime);
        // make sure that mid x point of first and last values are inside rect
        // (some ways of drawing variables do not draw after/before mid point
        PajeEntity *entity;
        enumerator = [filter enumeratorOfEntitiesTyped:entityType
                                           inContainer:container
                                              fromTime:drawEndTime
                                                toTime:drawEndTime
                                           minDuration:SMALL_ENTITY_DURATION];
        entity = [enumerator nextObject];
        if (entity != nil) {
            NSDate *entityEndTime;
            entityEndTime = [filter endTimeForEntity:entity];
            if ([entityEndTime isLaterThanDate:drawEndTime]) {
                drawEndTime = XtoTIME(TIMEtoX(entityEndTime)+1);
            }
        }
        enumerator = [filter enumeratorOfEntitiesTyped:entityType
                                           inContainer:container
                                              fromTime:drawStartTime
                                                toTime:drawStartTime
                                           minDuration:SMALL_ENTITY_DURATION];
ali:
        entity = [enumerator nextObject];
        if (entity != nil) {
            NSDate *entityStartTime;
            entityStartTime = [filter startTimeForEntity:entity];
            NSLog(@"e %@", entityStartTime);
            if ([entityStartTime isEarlierThanDate:drawStartTime]) {
                drawStartTime = XtoTIME(TIMEtoX(entityStartTime)-1);
            } else {
                goto ali;
            }
        }
NSLog(@"d %@ - %@", drawStartTime, drawEndTime);
    }
    enumerator = [filter enumeratorOfEntitiesTyped:entityType
                                       inContainer:container
                                          fromTime:drawStartTime
                                            toTime:drawEndTime
                                       minDuration:SMALL_ENTITY_DURATION];

    [self drawEntitiesWithDescriptor:layoutDescriptor
                         inContainer:container
                      fromEnumerator:enumerator];
}

- (void)drawInstance:(id)entity
        ofDescriptor:(STContainerTypeLayout *)layoutDescriptor
              inRect:(NSRect)drawRect
{
    NSEnumerator *sublayoutEnum;
    STEntityTypeLayout *sublayout;

    if (![layoutDescriptor isInstance:entity inRect:drawRect]) {
        return;
    }
        
    // draw background of container
    [self drawBackgroundForContainer:entity
                          descriptor:layoutDescriptor
                           insideRect:drawRect];

    // draw all subtypes in this container
    sublayoutEnum = [[layoutDescriptor subtypes] objectEnumerator];
    while ((sublayout = [sublayoutEnum nextObject]) != nil) {
        if (![sublayout isContainer]) {
            [self drawEntitiesWithDescriptor:sublayout
                                 inContainer:entity
                                  insideRect:drawRect];
        } else {
            STContainerTypeLayout *subcontainerLayout;
            subcontainerLayout = (STContainerTypeLayout *)sublayout;
            [self drawAllInstancesOfDescriptor:subcontainerLayout
                                   inContainer:entity
                                        inRect:drawRect];
        }
    }
}

- (void)drawAllInstancesOfDescriptor:(STContainerTypeLayout *)layoutDescriptor
                         inContainer:(PajeContainer *)container
                              inRect:(NSRect)drawRect
{
    if (/*container == nil
        || */[layoutDescriptor intersectsRect:drawRect inContainer:container]) {
        NSEnumerator *ienum;
        id instance;
        PajeEntityType *entityType;
        NSAutoreleasePool *pool;
        
        pool = [NSAutoreleasePool new];
        entityType = [layoutDescriptor entityType];
        ienum = [filter enumeratorOfContainersTyped:entityType
                                        inContainer:container];
        while ((instance = [ienum nextObject]) != nil) {
            [self drawInstance:instance
                  ofDescriptor:layoutDescriptor
                        inRect:drawRect];
        }
        [pool release];
    }
    
}



@end
