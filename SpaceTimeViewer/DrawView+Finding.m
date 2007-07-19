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
// DrawView+Finding
// --------------
// methods for finding entities in DrawView.

#include "DrawView.h"

#include <math.h>


// returns a rectangle that is the same as rect but has positive height and width
static NSRect positiveRect(NSRect rect)
{
    if (rect.size.height < 0) {
        rect.origin.y += rect.size.height;
        rect.size.height *= -1;
    }
    if (rect.size.width < 0) {
        rect.origin.x += rect.size.width;
        rect.size.width *= -1;
    }
    return rect;
}


@implementation DrawView (Finding)
/*
 * Finding Entities
 * ------------------------------------------------------------------------
 */

BOOL line_hit(double px, double py,
              double x1, double y1, double x2, double y2)
// returns YES if (px,py) lies over the line from (x1,y1) to (x2,y2)
{
    double dx = px - x1;
    double dy = py - y1;
    double w = x2 - x1;
    double h = y2 - y1;

    if (fabs(w) > fabs(h)) {
        // horizontal line
        double ny;
        if (((dx * w) < 0)
            || (fabs(dx) > fabs(w)))
            return NO;
        ny = dx / w * h;
        if (fabs(ny - dy) <= 1)
            return YES;
    } else {
        // vertical line
        double nx;
        if (((dy * h) < 0)
            || (fabs(dy) > fabs(h)))
            return NO;
        nx = dy / h * w;
        if (fabs(nx - dx) <= 1)
            return YES;
    }
    return NO;
}

- (BOOL)isPoint:(NSPoint)p insideEntity:(PajeEntity *)entity
// return YES if the pixel at point "p" would be painted by drawing "entity".
{
    NSRect r;
    int hit;
#ifndef GNUSTEP
#ifndef __APPLE__
    shapefunction *path;
    STEntityTypeLayout *entityDescriptor;
#endif
#endif
if (![entity isKindOfClass:[PajeEntity class]]) return YES;
    // couldn't make PSinfill work with an arrow...
    switch ([filter drawingTypeForEntity:entity]) {
        case PajeLinkDrawingType:
            r = [self rectForEntity:entity];
            hit = line_hit(p.x, p.y, NSMinX(r), NSMinY(r), NSMaxX(r), NSMaxY(r));
            break;
        case PajeVariableDrawingType:
            r = [self rectForEntity:entity];
            //hit = NSPointInRect(p, r);
            hit = p.x >= NSMinX(r) && p.x <= NSMaxX(r)
               && p.y >= NSMinY(r) && p.y <= NSMaxY(r);
            break;
        default:
            r = [self rectForEntity:entity];
#if defined(GNUSTEP) || defined(__APPLE__) // REVER ISSO
            hit = NSPointInRect(p, r);
#else
            // test insideness with x=y=0, because PostScript has a problem with
            // insideness testing in big coordinates (>~10000)
            entityDescriptor = [self descriptorForEntityType:
                                     [filter entityTypeForEntity:entity]];
            path = [[entityDescriptor shapeFunction] function];
            PSgsave();
            path(0, 0, NSWidth(r), NSHeight(r));
            PSinfill(p.x - NSMinX(r), p.y - NSMinY(r), &hit);
            PSgrestore();
#endif
    }

    return hit;
}


- (PajeEntity *)findEntityAtPoint:(NSPoint)point
// returns the entity that is drawn at "point", or nil if there isn't any.
// if there is more than one entity, returns the one that is on top (the
// last one to be drawn.
{
    id rootInstance;
    STContainerTypeLayout *rootLayout;
    
    rootInstance = [filter rootInstance];
    rootLayout = [controller rootLayout];
    
    return [self entityAtPoint:point
                    inInstance:rootInstance
            ofLayoutDescriptor:rootLayout];
}

- (PajeEntity *)entityAtPoint:(NSPoint)point
           inEntityDescriptor:(STEntityTypeLayout *)layoutDescriptor
                  inContainer:(PajeContainer *)container
{
    id findStartTime;
    id findEndTime;
    NSEnumerator *enumerator;
//    float closestDistance = MAXFLOAT;
    PajeEntity *closestEntity = nil;
    PajeEntity *entity;

    if ([layoutDescriptor drawingType] == PajeVariableDrawingType) {
//        return nil;
    }

    if (![layoutDescriptor isPoint:point inContainer:container]) {
        return nil;
    }

    float width;
    if ([layoutDescriptor drawingType] == PajeEventDrawingType) {
        width = [(STEventTypeLayout *)layoutDescriptor width];
    } else {
        width = 1;
    }
    findStartTime = XtoTIME(point.x - width);
    findEndTime   = XtoTIME(point.x + width);
    enumerator = [filter enumeratorOfEntitiesTyped:[layoutDescriptor entityType]
                                       inContainer:container
                                          fromTime:findStartTime
                                            toTime:findEndTime
                                       minDuration:SMALL_ENTITY_DURATION];
    while ((entity = [enumerator nextObject]) != nil) {
        if ([self isPoint:point insideEntity:entity]) {
            closestEntity = entity;
        }
    }
    return closestEntity;
}

- (PajeEntity *)entityAtPoint:(NSPoint)point
                   inInstance:(id)instance
           ofLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor
{
    NSEnumerator *sublayoutEnum;
    STEntityTypeLayout *sublayout;
    PajeEntity *entity;

    // search instances of each subhierarchy
    // (in reverse order, to find what's been drawn on top first)
    sublayoutEnum = [[layoutDescriptor subtypes] reverseObjectEnumerator];
    while ((sublayout = [sublayoutEnum nextObject]) != nil) {
        entity = [self entityAtPoint:point
                    layoutDescriptor:sublayout
                         inContainer:instance];
        if (entity != nil) {
            break;
        }
    }
    return entity;
}

- (PajeEntity *)entityAtPoint:(NSPoint)point
             layoutDescriptor:(STEntityTypeLayout *)layoutDescriptor
                  inContainer:(PajeContainer *)container
{
    PajeEntity *entity = nil;

    if (![layoutDescriptor isPoint:point inContainer:container]) {
        return nil;
    }

    if (![layoutDescriptor isContainer]) {
        entity = [self entityAtPoint:point
                  inEntityDescriptor:layoutDescriptor
                         inContainer:container];
    } else {
        id instance;
        STContainerTypeLayout *layout;
        
        layout = (STContainerTypeLayout *)layoutDescriptor;
        instance = [layout instanceWithPoint:point];
        if (instance != nil) {
            entity = [self entityAtPoint:point
                              inInstance:instance
                      ofLayoutDescriptor:layout];
        }
    }
    return entity;
}


- (NSArray *)findEntitiesAtPoint:(NSPoint)point
// returns the entities that are drawn at "point", or nil if there isn't any.
{
    id rootInstance;
    STContainerTypeLayout *rootLayout;
    
    rootInstance = [filter rootInstance];
    rootLayout = [controller rootLayout];
    
    return [self entitiesAtPoint:point
                      inInstance:rootInstance
              ofLayoutDescriptor:rootLayout];
}

- (NSArray *)entitiesAtPoint:(NSPoint)point
          inEntityDescriptor:(STEntityTypeLayout *)layoutDescriptor
                 inContainer:(PajeContainer *)container
{
    NSDate *findStartTime;
    NSDate *findEndTime;
    NSEnumerator *enumerator;
    PajeEntity *entity;
    NSMutableArray *array;

//    if ([layoutDescriptor drawingType] == PajeVariableDrawingType) {
//        return nil;
//    }

    if (![layoutDescriptor isPoint:point inContainer:container]) {
        return nil;
    }

    array = [NSMutableArray array];
    
    float width;
    if ([layoutDescriptor drawingType] == PajeEventDrawingType) {
        width = [(STEventTypeLayout *)layoutDescriptor width];
    } else {
        width = 0;
    }
    findStartTime = XtoTIME(point.x - width);
    findEndTime   = XtoTIME(point.x + width);
    enumerator = [filter enumeratorOfEntitiesTyped:[layoutDescriptor entityType]
                                       inContainer:container
                                          fromTime:findStartTime
                                            toTime:findEndTime
                                       minDuration:SMALL_ENTITY_DURATION];
    while ((entity = [enumerator nextObject]) != nil) {
        if ([self isPoint:point insideEntity:entity]) {
            [array addObject:entity];
        }
    }
    return array;
}

- (NSArray *)entitiesAtPoint:(NSPoint)point
                  inInstance:(id)instance
          ofLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor
{
    NSEnumerator *sublayoutEnum;
    STEntityTypeLayout *sublayout;
    NSArray *entities;
    NSMutableArray *array;

    array = [NSMutableArray array];
    // search instances of each subhierarchy
    // (in reverse order, to find what's been drawn on top first)
    sublayoutEnum = [[layoutDescriptor subtypes] reverseObjectEnumerator];
    while ((sublayout = [sublayoutEnum nextObject]) != nil) {
        entities = [self entitiesAtPoint:point
                        layoutDescriptor:sublayout
                             inContainer:instance];
        if (entities != nil) {
            [array addObjectsFromArray:entities];
        }
    }
    return array;
}

- (NSArray *)entitiesAtPoint:(NSPoint)point
            layoutDescriptor:(STEntityTypeLayout *)layoutDescriptor
                 inContainer:(PajeContainer *)container
{
    NSArray *entities = nil;

    if (![layoutDescriptor isPoint:point inContainer:container]) {
        return nil;
    }

    if (![layoutDescriptor isContainer]) {
        entities = [self entitiesAtPoint:point
                      inEntityDescriptor:layoutDescriptor
                             inContainer:container];
    } else {
        id instance;
        STContainerTypeLayout *layout;
        
        layout = (STContainerTypeLayout *)layoutDescriptor;
        instance = [layout instanceWithPoint:point];
        if (instance != nil) {
            entities = [self entitiesAtPoint:point
                                  inInstance:instance
                          ofLayoutDescriptor:layout];
        }
    }
    return entities;
}

- (NSRect)rectForEntity:(PajeEntity *)entity
{
    float x1, x2, y1, y2, min, max, scale, offset;
    NSRect rect, rect1, rect2;
    id entityType;
    int imbricationLevel;
    float newHeight;
    STEntityTypeLayout *layoutDescriptor;

    id <PajeLink> link;
    PajeContainer *sourceContainer;
    PajeContainer *destContainer;
    STContainerTypeLayout *containerDescriptor;

    if (entity == nil) return NSZeroRect;

    entityType = [filter entityTypeForEntity:entity];
    layoutDescriptor = [controller descriptorForEntityType:entityType];
    switch ([layoutDescriptor drawingType]) {
        case PajeEventDrawingType:
            rect = [layoutDescriptor rectInContainer:
                                        [filter containerForEntity:entity]];
            rect.origin.x = TIMEtoX([filter timeForEntity:entity]);
            //rect.size.height = [layoutDescriptor height];
            rect.size.width = [(STEventTypeLayout *)layoutDescriptor width];
            rect.origin.x -= rect.size.width
                      * (1 - [[layoutDescriptor shapeFunction] rightExtension]);
            //rect.origin.y -= rect.size.height
            //          * ([[layoutDescriptor shapeFunction] topExtension]);
            break;
        case PajeStateDrawingType:
            rect.origin.y = [layoutDescriptor yInContainer:[filter containerForEntity:entity]];
            rect.size.height = [layoutDescriptor height];
            x1 = TIMEtoX([filter startTimeForEntity:entity]);
            x2 = TIMEtoX([filter endTimeForEntity:entity]);
            rect.origin.x = x1;
            rect.size.width = (x2 - x1);
            imbricationLevel = [filter imbricationLevelForEntity:entity];
            newHeight = rect.size.height - [(STStateTypeLayout *)layoutDescriptor insetAmount] * imbricationLevel;
            if (newHeight < 2)
                newHeight = 2;
            if (newHeight < rect.size.height)
                rect.size.height = newHeight;
            break;
        case PajeVariableDrawingType:
            x1 = TIMEtoX([filter startTimeForEntity:entity]);
            x2 = TIMEtoX([filter endTimeForEntity:entity]);
            min = [filter minValueForEntityType:entityType];
            max = [filter maxValueForEntityType:entityType];

            if (min != max) {
                scale = -([layoutDescriptor height] - 4) / (max - min);
            } else {
                scale = 1;
            }
            offset = [layoutDescriptor yInContainer:[filter containerForEntity:entity]] + 2 - max * scale;
            y1 = [filter doubleValueForEntity:entity] * scale + offset;
            y2 = min * scale + offset;
            rect.origin.x = x1;
            rect.size.width = (x2 - x1);
            rect.origin.y = y1;
            rect.size.height = y2 - y1;
            break;
        case PajeLinkDrawingType:
            link = (id <PajeLink>)entity;
            sourceContainer = [filter sourceContainerForEntity:link];
            destContainer = [filter destContainerForEntity:link];
            containerDescriptor = (STContainerTypeLayout *)[controller descriptorForEntityType:[filter sourceEntityTypeForEntity:link]];
            rect1 = [containerDescriptor rectOfInstance:sourceContainer];
            x1 = TIMEtoX([filter startTimeForEntity:link]);
            y1 = NSMinY(rect1) + [containerDescriptor linkOffset];

            containerDescriptor = (STContainerTypeLayout *)[controller descriptorForEntityType:[filter destEntityTypeForEntity:link]];
            rect2 = [containerDescriptor rectOfInstance:destContainer];
            x2 = TIMEtoX([filter endTimeForEntity:link]);
            y2 = NSMinY(rect2) + [containerDescriptor linkOffset];

            rect.origin.x = x1;
            rect.size.width = (x2 - x1);
            rect.origin.y = y1;
            rect.size.height = (y2 - y1);
            break;
        default:
            rect = NSZeroRect;
    }

    return rect;
}

- (NSRect)drawRectForEntity:(PajeEntity *)entity
{
    NSRect rect;
    rect = positiveRect([self rectForEntity:entity]);
    
    return rect;
}

- (NSRect)highlightRectForEntity:(PajeEntity *)entity
{
    NSRect rect;
    rect = positiveRect([self rectForEntity:entity]);
    rect = NSInsetRect(rect, -10, -10);
    return rect;
}
@end
