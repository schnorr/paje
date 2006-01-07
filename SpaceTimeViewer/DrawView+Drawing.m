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

@implementation DrawView (Drawing)

- (void)drawEventsWithDescriptor:(STEventTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
                    drawFunction:(DrawFunction *)drawFunction
{
    shapefunction *path;
    drawfunction *draw;
    drawfunction *highlight;
    NSColor *color;
    NSColor *lastColor = nil;
    id entity;
    float x, y, w, h;
    BOOL drawNames;
    NSMutableAttributedString *name;
    NSDictionary *attributes;
    
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSFont systemFontOfSize:8], @"NSFontAttributeName",
                            nil];

    drawNames = [layout drawsName];
    if (drawNames) {
        name = [[NSMutableAttributedString alloc] 
                initWithString:@""
                    attributes:attributes];
    }
    
    y = [layout yInContainer:container];
    w = [layout width];
    h = [layout height];
    path = [[layout shapeFunction] function];
    draw = [drawFunction function];
    highlight = [[layout highlightFunction] function];
    PSgsave();

    while ((entity = [enumerator nextObject]) != nil) {
        x = TIMEtoX([filter timeForEntity:entity]);

        if ([filter isAggregateEntity:entity]) {
            float x2 = TIMEtoX([filter endTimeForEntity:entity]);
            int condensedEntitiesCount;
            unsigned i;
            unsigned count;
            float xi = x;
            float dx;
            int sup;

            PSgsave();
            condensedEntitiesCount = [entity condensedEntitiesCount];
            sup = [layout isSupEvent];

            count = [filter subCountForEntity:entity];
            for (i = 0; i < count; i++) {
                [[filter subColorAtIndex:i forEntity:entity] set];
                dx = (x2-x) * [filter subCountAtIndex:i forEntity:entity] 
                            / condensedEntitiesCount;
                NSRectFill(NSMakeRect(xi, y+(sup*(-h+8))+(!sup*(h-10)), dx, 3));
                xi += dx;
            }
            PSmoveto(x, y+2*sup-2*!sup);
            PSlineto(x, y-(h-7)*sup+(h-7)*!sup);
            PSlineto(x2, y-(h-7)*sup+(h-7)*!sup);
            PSlineto(x2, y+2*sup-2*!sup);
            if ([filter isSelectedEntity:entity]) {
                [[NSColor yellowColor] set];
            } else {
                [[NSColor blackColor] set];
            }
            PSstroke();

            [[NSString stringWithFormat:@"%d", condensedEntitiesCount]
                        drawAtPoint:NSMakePoint(x, y-(h+1)*sup+(h-8)*!sup)
                     withAttributes:attributes];
            PSgrestore();

        } else {

        color = [filter colorForEntity:entity];
        if (![color isEqual:lastColor]) {
            lastColor = color;
            [color set];
        }

        PSgsave();
        path(x, y, w, h);
        if ([filter isSelectedEntity:entity]) {
            highlight();
        } else {
            draw();
        }
        PSgrestore();
        if (drawNames) {
            PSgsave();
            [name replaceCharactersInRange:NSMakeRange(0, [name length])
                                withString:[filter nameForEntity:entity]];
            if ([layout isSupEvent]) {
                y = y - h;
                h = 12;
            }
            x -= w;
            NSRectFill(NSMakeRect(x, y, w * 2, h));
            if ([[color colorUsingColorSpaceName:NSCalibratedWhiteColorSpace
                                          device:nil] whiteComponent] > 0.5) {
                [[NSColor blackColor] set];
            } else {
                [[NSColor whiteColor] set];
            }
            [name drawInRect:NSMakeRect(x, y, w * 2, h)];
            PSgrestore();
        }
        }
    }
    PSgrestore();
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
                    drawFunction:(DrawFunction *)drawFunction
{
    float insetBy;
    NSColor *color;
    NSColor *lcolor = [NSColor blackColor];
    NSColor *hcolor = [NSColor yellowColor];;
    NSBezierPath *bp = [NSBezierPath bezierPath];
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
                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSFont systemFontOfSize:8], @"NSFontAttributeName",
                            nil]];
    }

    y = [layout yInContainer:container];
    h = [layout height];
    insetBy = [layout insetAmount];
    [bp setLineWidth:1.0];

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
        [bp removeAllPoints];
        [bp appendBezierPathWithRect:rect];
        if ([filter isAggregateEntity:entity]) {
            [bp moveToPoint:NSMakePoint(x, y)];
            [bp lineToPoint:NSMakePoint(x+w, y+newHeight)];
            float xi = x;
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
                [bp moveToPoint:NSMakePoint(rect.origin.x, y+newHeight)];
                [bp lineToPoint:NSMakePoint(x+w, y)];
            }
        } else {
            color = [filter colorForEntity:entity];
            [color set];
            NSRectFill(rect);
            //[bp fill];

            if (drawNames && ow > smallEntityWidth && newHeight > 8) {
                [name replaceCharactersInRange:NSMakeRange(0, [name length])
                                    withString:[filter nameForEntity:entity]];
                [name drawInRect:NSMakeRect(ox+2, y + newHeight - 10, ow, 10)];
            }
        }

        if ([filter isSelectedEntity:entity]) {
            [hcolor set];
        } else {
            [lcolor set];
        }
        [bp stroke];

    }

    if (firstUndrawnX != MAXFLOAT) {
        drawBlackRect(firstUndrawnX, lastUndrawnX,
                      NSMakeRect(x, y, w, undrawnHeight));
    }

    if (drawNames) {
        [name release];
    }
}

- (void)drawValuesWithDescriptor:(STVariableTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
                    drawFunction:(DrawFunction *)drawFunction
{
    NSBezierPath *path;
    NSColor *color;
    id <PajeState>entity;
    float yMin;
    float yMax;
    float yScale;
    float yOffset;
    float off3d;
    float xOld;
    float yOld;
    float yvMin;
    float yvMax;
    BOOL first = YES;
    PajeEntityType *entityType;
    
    entityType = [layout entityType];

    yMin = [layout minValue];
    yMax = [layout maxValue];
    if (yMax <= yMin) {
        yMin = [[filter minValueForEntityType:entityType] floatValue];
        yMax = [[filter maxValueForEntityType:entityType] floatValue];
    }

    if (yMin != yMax) {
        yScale = -([layout height] - 4) / (yMax - yMin);
    } else {
        yScale = 1;
    }

    off3d = [layout threeD] ? -1 : 0;
    yOffset = [layout yInContainer:container] + 2 - (yMax * yScale) + off3d;

    path = [[NSBezierPath alloc] init];
    [path setLineJoinStyle: NSBevelLineJoinStyle];

    while ((entity = [enumerator nextObject]) != nil) {
        float x;
        float y;

        x = TIMEtoX([filter startTimeForEntity:entity]) + off3d;
        y = [[filter valueForEntity:entity] doubleValue] * yScale + yOffset;

        // do not draw if on same column; get max & min y values
        if (!first && (xOld - x) < 1) {
            if (y < yvMin) yvMin = y;
            if (y > yvMax) yvMax = y;
            continue;
        }
#ifdef GNUSTEP
        // Very big lines are not drawn in GNUstep 
        if (x < NSMinX(cutRect)) x = NSMinX(cutRect);
#endif
        if (first) {
            [path moveToPoint: NSMakePoint(NSMaxX(cutRect), y)];
            [path lineToPoint: NSMakePoint(x, y)];
        } else {
            if (yvMin != yOld && yvMin != y) {
                [path lineToPoint: NSMakePoint(xOld, yvMin)];
                yOld = yvMin;
            }
            if (yvMax != yOld) {
                [path lineToPoint: NSMakePoint(xOld, yvMax)];
                yOld = yvMax;
            }
            if (y != yOld) {
                [path lineToPoint: NSMakePoint(xOld, y)];
            }
            [path lineToPoint: NSMakePoint(x, y)];
        }
        xOld = x;
        yvMin = yvMax = yOld = y;
        first = NO;
    }

    color = [filter colorForEntityType:entityType];

    if ([layout threeD]) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [path setLineWidth:[layout lineWidth] - 2];
        [[color highlightWithLevel:0.3] set];
        [path stroke];
        [transform translateXBy: 2.0 yBy: 2.0];
        [path transformUsingAffineTransform: transform];
        [[color shadowWithLevel:0.3] set];
        [path stroke];
        [transform translateXBy: -3.0 yBy: -3.0];
        [path transformUsingAffineTransform: transform];
        [color set];
        [path stroke];
    } else {
        [path setLineWidth:[layout lineWidth]];
        [color set];
        [path stroke];
    }

    [path release];
}



- (void)drawLinksWithDescriptor:(STLinkTypeLayout *)layout
                    inContainer:(PajeContainer *)container
                 fromEnumerator:(NSEnumerator *)enumerator
                   drawFunction:(DrawFunction *)drawFunction
{
    shapefunction *path;
    drawfunction *draw;
    drawfunction *highlight;
    NSColor *color;
    NSColor *lastColor = nil;
    id <PajeLink>entity;
    float x1, x2, y1, y2;

    path = [[layout shapeFunction] function];
    draw = [drawFunction function];
    highlight = [[layout highlightFunction] function];

    PSgsave();
    PSsetlinewidth([layout lineWidth]);

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

        color = [filter colorForEntity:entity];
        //color = [color colorWithAlphaComponent:0.5];
        if (![color isEqual:lastColor]) {
            lastColor = color;
            [color set];
        }

        //if (sourceContainer && destContainer) {
        PSgsave();
        if (sourceContainer == nil) {
            shapefunction PSIn;
            PSIn(x2, y2, 8, 8);
        } else if (destContainer == nil) {
            shapefunction PSOut;
            PSOut(x1, y1, 8, 8);
        } else {
            path(x1, y1, x2-x1, y2-y1);
        }
        if ([filter isSelectedEntity:entity]) {
            highlight();
        } else {
            draw();
        }
        PSgrestore();
    }
    PSgrestore();
}

- (void)drawEntitiesWithDescriptor:(STEntityTypeLayout *)layoutDescriptor
                       inContainer:(PajeContainer *)container
                        insideRect:(NSRect)drawRect
{
    NSDate *drawStartTime;
    NSDate *drawEndTime;
    NSEnumerator *enumerator;
    NSRect rect;
    PajeDrawingType drawingType;

    rect = [layoutDescriptor rectInContainer:container];
    drawingType = [layoutDescriptor drawingType];

/*
    if (drawingType != PajeLinkDrawingType) {
        NSRect r = rect;
        r.origin.x = drawRect.origin.x;
        r.size.width = drawRect.size.width;
        if (NSIsEmptyRect(NSIntersectionRect(r, drawRect)))
            return;
    }
*/
    if (![layoutDescriptor intersectsRect:drawRect inContainer:container]) {
        return;
    }

    float width;
    if (drawingType == PajeEventDrawingType) {
        width = [(STEventTypeLayout *)layoutDescriptor width];
    } else {
        width = 1;
    }
    drawStartTime = XtoTIME(NSMinX(drawRect) - width);
    drawEndTime   = XtoTIME(NSMaxX(drawRect) + width);
    enumerator = [filter enumeratorOfEntitiesTyped:[layoutDescriptor entityType]
                                       inContainer:container
                                          fromTime:drawStartTime
                                            toTime:drawEndTime
                                       minDuration:SMALL_ENTITY_DURATION];

    switch (drawingType) {
        case PajeEventDrawingType:
            [self drawEventsWithDescriptor:(STEventTypeLayout *)layoutDescriptor
                               inContainer:container
                            fromEnumerator:enumerator
                              drawFunction:[layoutDescriptor drawFunction]];
            break;
        case PajeStateDrawingType:
            [self drawStatesWithDescriptor:(STStateTypeLayout *)layoutDescriptor
                               inContainer:container
                            fromEnumerator:enumerator
                              drawFunction:[layoutDescriptor drawFunction]];
            break;
        case PajeLinkDrawingType:
            [self drawLinksWithDescriptor:(STLinkTypeLayout *)layoutDescriptor
                              inContainer:container
                           fromEnumerator:enumerator
                             drawFunction:[layoutDescriptor drawFunction]];
            break;
        case PajeVariableDrawingType:
            [self drawValuesWithDescriptor:(STVariableTypeLayout *)
                                                           layoutDescriptor
                               inContainer:container
                            fromEnumerator:enumerator
                              drawFunction:[layoutDescriptor drawFunction]];
            break;
        case PajeContainerDrawingType:
            break;
        default:
            NSAssert1(0, @"Invalid drawing type %d", drawingType);
    }

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
        
    if ([[filter selectedContainers] containsObject:entity]) {
        [[NSColor whiteColor] set];
        NSRectFill([layoutDescriptor rectOfInstance:entity]);
    }

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
