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

    drawNames = [layout drawsName];
    if (drawNames) {
        name = [[NSMutableAttributedString alloc] init];
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
            /*NSLog(@"br=%f", [[color colorUsingColorSpaceName:NSCalibratedWhiteColorSpace
                                          device:nil] whiteComponent]);*/
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
    PSgrestore();
}

#define drawBlackRect(x1, x2, r) \
do { \
    lastColor = [NSColor darkGrayColor]; \
    [lastColor set]; \
    /*NSRectFill(NSMakeRect(x1, NSMinY(r), x2 - x1, NSHeight(r)));*/ \
    /*NSFrameRect(NSMakeRect(x1, NSMinY(r), x2 - x1, NSHeight(r)));*/ \
    NSFrameRect(NSMakeRect(x1, NSMinY(r)+NSHeight(r)/4, x2 - x1 + 1, NSHeight(r)/2)); \
} while (0)

- (void)drawStatesWithDescriptor:(STStateTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
                    drawFunction:(DrawFunction *)drawFunction
{
    shapefunction *path;
    drawfunction *draw;
    drawfunction *highlight;
    float insetBy;
    NSColor *color;
    NSColor *lastColor = nil;
    id <PajeState>entity;
    float firstUndrawnX = MAXFLOAT;
    float lastUndrawnX = MAXFLOAT;
    float undrawnHeight = 0;
    float x, y, w, h;
    BOOL drawNames;
    NSMutableAttributedString *name;

    drawNames = [layout drawsName];
    if (drawNames) {
        name = [[NSMutableAttributedString alloc] init];
    }

    y = [layout yInContainer:container];
    h = [layout height];
    path = [[layout shapeFunction] function];
    draw = [drawFunction function];
    highlight = [[layout highlightFunction] function];
    insetBy = [layout insetAmount];
    PSgsave();
    PSsetlinewidth(1.0);

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
        //rect = NSIntersectionRect(rect, cutRect);
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
#if 0
            if ((firstUndrawnX != MAXFLOAT) && (x > lastUndrawnX)) {
                drawBlackRect(firstUndrawnX, lastUndrawnX, NSMakeRect(x,y,w,undrawnHeight));
                undrawnHeight = 0;
                firstUndrawnX = x;
            }
            if (firstUndrawnX == MAXFLOAT) {
                firstUndrawnX = x;
            }
            if (lastUndrawnX < x2) {
                lastUndrawnX = x2;
            }
            if (newHeight > undrawnHeight) {
                undrawnHeight = newHeight;
            }
            continue;
#else
            if ((lastUndrawnX != MAXFLOAT) && (x2 < firstUndrawnX)) {
                drawBlackRect(firstUndrawnX, lastUndrawnX, NSMakeRect(x,y,w,undrawnHeight));
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
#endif
        }

        if (firstUndrawnX != MAXFLOAT) {
            drawBlackRect(firstUndrawnX, lastUndrawnX, NSMakeRect(x,y,w,undrawnHeight));
            firstUndrawnX = lastUndrawnX = MAXFLOAT;
            undrawnHeight = 0;
        }

        color = [filter colorForEntity:entity];
        if (![color isEqual:lastColor]) {
            lastColor = color;
            [color set];
        }

        PSgsave();
        path(x, y, w, newHeight);
        if ([filter isSelectedEntity:entity]) {
            highlight();
        } else {
            draw();
        }
        if (drawNames && ow>10) {
            [name replaceCharactersInRange:NSMakeRange(0, [name length])
                                withString:[filter nameForEntity:entity]];
            [name drawInRect:NSMakeRect(ox+3, y, ow, newHeight)];
        }
	PSgrestore();
    }

    if (firstUndrawnX != MAXFLOAT) {
        drawBlackRect(firstUndrawnX, lastUndrawnX, NSMakeRect(x, y, w, undrawnHeight));
    }
    PSgrestore();

    if (drawNames) {
        [name release];
    }
}

- (void)drawValuesWithDescriptor:(STVariableTypeLayout *)layout
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator
                    drawFunction:(DrawFunction *)drawFunction
{
    shapefunction *path;
    drawfunction *draw;
    NSColor *color;
    id <PajeState>entity;
    BOOL first = YES;
    float min;
    float max;
    float scale;
    float offset;
    float oldx2 = -1e6;
    PajeEntityType *entityType;
    NSColor *lastColor = nil;
    
    entityType = [layout entityType];
    
    min = [layout minValue];
    max = [layout maxValue];
    if (max <= min) {
        min = [[filter minValueForEntityType:entityType] floatValue];
        max = [[filter maxValueForEntityType:entityType] floatValue];
    }

    if (min != max) {
        scale = -([layout height] - 4) / (max - min);
    } else {
        scale = 1;
    }
    offset = [layout yInContainer:container] + 2 - (max * scale);

    path = [[layout shapeFunction] function];
    draw = [drawFunction function];
    color = [filter colorForEntityType:entityType];

#define VARIABLES_3D
#ifdef VARIABLES_3D
    NSArray *todos = [enumerator allObjects];

    first = YES;
    PSsetlinejoin(2);
    float off2=1;
    [[color highlightWithLevel:0.3] set];
    enumerator = [todos objectEnumerator];
    while ((entity = [enumerator nextObject]) != nil) {
        float x1 = TIMEtoX([filter startTimeForEntity:entity]) - off2;
        float x2 = TIMEtoX([filter endTimeForEntity:entity]) - off2;
        float y = [[filter valueForEntity:entity] doubleValue] * scale + offset;
        y -= off2;
        if (first) {
            first = NO;
            PSgsave();
            PSsetlinewidth([layout lineWidth]);
            PSmoveto(x1, y);
        }

#ifdef GNUSTEP
        // Very big lines are not drawn in GNUstep 
        if (x1 < NSMinX(cutRect)) x1 = NSMinX(cutRect);
        if (x2 > NSMaxX(cutRect)) x2 = NSMaxX(cutRect);
#endif

        if (!first && x1 == oldx2) {
            PSlineto(x1, y);
        } else {
            PSmoveto(x1, y);
        }

        PSlineto(x2, y);
        oldx2 = x2;
    }
    if (!first) {
        PSstroke();
        PSgrestore();
    }
    first = YES;
    [[color shadowWithLevel:0.3] set];
    enumerator = [todos objectEnumerator];
    while ((entity = [enumerator nextObject]) != nil) {
        float x1 = TIMEtoX([filter startTimeForEntity:entity]) + off2;
        float x2 = TIMEtoX([filter endTimeForEntity:entity]) + off2;
        float y = [[filter valueForEntity:entity] doubleValue] * scale + offset;
        y += off2;
        if (first) {
            first = NO;
            PSgsave();
            PSsetlinewidth([layout lineWidth]);
            PSmoveto(x1, y);
        }

#ifdef GNUSTEP
        // Very big lines are not drawn in GNUstep 
        if (x1 < NSMinX(cutRect)) x1 = NSMinX(cutRect);
        if (x2 > NSMaxX(cutRect)) x2 = NSMaxX(cutRect);
#endif

        if (!first && x1 == oldx2) {
            PSlineto(x1, y);
        } else {
            PSmoveto(x1, y);
        }

        PSlineto(x2, y);
        oldx2 = x2;
    }
    if (!first) {
        PSstroke();
        PSgrestore();
    }
    enumerator = [todos objectEnumerator];
    first=YES;
#endif
    [color set];

    while ((entity = [enumerator nextObject]) != nil) {
        float x1 = TIMEtoX([filter startTimeForEntity:entity]);
        float x2 = TIMEtoX([filter endTimeForEntity:entity]);
        float y = [[filter valueForEntity:entity] doubleValue] * scale + offset;
        if (first) {
            first = NO;
            PSgsave();
            PSsetlinewidth([layout lineWidth] - 2);
            PSmoveto(x1, y);
        }

#ifdef GNUSTEP
        // Very big lines are not drawn in GNUstep 
        if (x1 < NSMinX(cutRect)) x1 = NSMinX(cutRect);
        if (x2 > NSMaxX(cutRect)) x2 = NSMaxX(cutRect);
#endif

        if (!first && x1 == oldx2) {
            PSlineto(x1, y);
        } else {
            PSmoveto(x1, y);
        }

/*
        color = [filter colorForEntity:entity];
        if (![color isEqual:lastColor]) {
            if (lastColor != nil) {
                PSstroke();
                PSmoveto(x1, y);
            }
            lastColor = color;
            [color set];
        }
*/
        PSlineto(x2, y);
        oldx2 = x2;
    }
    if (!first) {
        PSstroke();
        PSgrestore();
    }

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
    id drawStartTime;
    id drawEndTime;
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
        width = 0;
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
            // States are ordered by endTime, inset states come first and 
            // should be drawn last -- reverse the enumeration
            enumerator = [[enumerator allObjects] reverseObjectEnumerator];
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
            [self drawValuesWithDescriptor:(STVariableTypeLayout *)layoutDescriptor
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
