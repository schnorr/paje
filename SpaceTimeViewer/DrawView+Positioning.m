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
// DrawView+Positioning
// --------------
// methods for finding positions of entities in DrawView.

#include "STController.h"

@implementation STController (Positioning)

- (NSRect)calcRectOfInstance:(id)entity
          ofLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor
                        minY:(float)minY
{
    NSEnumerator *sublayoutEnum;
    STEntityTypeLayout *sublayout;
    NSRect rect = NSZeroRect;
    float containerStartX;
    float containerEndX;

    containerStartX = [drawView timeToX:[self startTimeForEntity:entity]];
    containerEndX = [drawView timeToX:[self endTimeForEntity:entity]];
    rect.origin.x = containerStartX;
    rect.size.width = containerEndX - containerStartX;

    sublayoutEnum = [[layoutDescriptor subtypes] objectEnumerator];
    while ((sublayout = [sublayoutEnum nextObject]) != nil) {
        if ([sublayout isContainer]) {
            continue;
        }
        rect.origin.y = minY + [sublayout offset];
        rect.size.height = [sublayout height];

        [sublayout setRect:rect inContainer:entity];
    }

    float separation = 0;
    
    rect.origin.y = minY;
    rect.size.height = [layoutDescriptor subcontainersOffset];
    
    sublayoutEnum = [[layoutDescriptor subtypes] objectEnumerator];
    while ((sublayout = [sublayoutEnum nextObject]) != nil) {
        NSRect r;
        float subtypeOffset;
        STContainerTypeLayout *layout;

        if (![sublayout isContainer]) {
            continue;
        }

        layout = (STContainerTypeLayout *)sublayout;
        subtypeOffset = NSMaxY(rect) + separation;
        r = [self calcRectOfAllInstancesOfLayoutDescriptor:layout
                                               inContainer:entity
                                                      minY:subtypeOffset];
        if (!NSIsEmptyRect(r)) {
            rect = NSUnionRect(rect, r);
            separation = [layoutDescriptor subtypeSeparation];
        }
    }
    [layoutDescriptor setRect:rect ofInstance:entity];
    return rect;
}

- (NSRect)calcRectOfAllInstancesOfLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor
                                       inContainer:(PajeContainer *)container
                                              minY:(float)minY
{
    NSRect rect = NSZeroRect;
    float containerStartX;
    float containerEndX;
    NSEnumerator *ienum;
    id instance;
    float separation = 0;

    containerStartX = [drawView timeToX:[self startTimeForEntity:container]];
    containerEndX = [drawView timeToX:[self endTimeForEntity:container]];
    rect.origin.x = containerStartX;
    rect.size.width = containerEndX - containerStartX;

    rect.origin.y = minY;
    rect.size.height = 0;
    
    // check all instances on this hierarchy
    ienum = [self enumeratorOfContainersTyped:[layoutDescriptor entityType]
                                  inContainer:container];
    while ((instance = [ienum nextObject]) != nil) {
        NSRect r;
        r = [self calcRectOfInstance:instance
                  ofLayoutDescriptor:layoutDescriptor
                                minY:NSMaxY(rect) + separation];
        if (!NSIsEmptyRect(r)) {
            if (NSIsEmptyRect(rect)) {
                rect = r;
                separation = [layoutDescriptor siblingSeparation];
            } else {
                rect = NSUnionRect(rect, r);
            }
        }
    }
    
    [layoutDescriptor setRect:rect inContainer:container];
    return rect;
}

@end
