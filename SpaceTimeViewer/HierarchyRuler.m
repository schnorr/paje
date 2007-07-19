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
#include "HierarchyRuler.h"
#include "../General/Macros.h"

#define SHOW_TYPES


#define CEIL(f) (1000-((int)(1000-(f))))
#define CEIL2(f) (1000-((int)(999.5-(f))))

@interface VCell : NSCell
@end
@implementation VCell
- (void) _drawAttributedText: (NSAttributedString*)aString 
		     inFrame: (NSRect)aRect
{
    NSSize titleSize;
    NSRect newRect;

    if (aString == nil || NSWidth(aRect) < 5 || NSHeight(aRect) < 5) {
        return;
    }

    titleSize = [aString size];

    if (NSWidth(aRect) > NSHeight(aRect)) {

        if (titleSize.width < aRect.size.width) {
            newRect.origin.x = NSMidX(aRect) - titleSize.width/2;
            newRect.origin.y = NSMidY(aRect) - titleSize.height/2;
            newRect.size = titleSize;
            //newRect.size.width = aRect.size.height;
        } else {
            newRect.origin.x = NSMinX(aRect);
            newRect.size.width = aRect.size.width + 1;
            newRect.size.height = titleSize.height 
                                * CEIL(titleSize.width / newRect.size.width);
            if (newRect.size.height > aRect.size.height) {
                newRect.size.height = aRect.size.height;
            }
            newRect.origin.y = NSMidY(aRect) - newRect.size.height/2;
        }
        [aString drawInRect: newRect];
  
    } else {
  
        if (titleSize.width < aRect.size.height) {
            newRect.origin.x = NSMidX(aRect) - titleSize.height/2;
            newRect.origin.y = NSMidY(aRect) + titleSize.width/2;
            newRect.size = titleSize;
            newRect.size.width += 6;
        } else {
            newRect.origin.y = NSMaxY(aRect);
            newRect.size.width = aRect.size.height + 1;
            newRect.size.height = titleSize.height 
                                * CEIL2(titleSize.width / newRect.size.width);
            if (newRect.size.height > aRect.size.width) {
                newRect.size.height = aRect.size.width;
            }
            newRect.origin.x = NSMidX(aRect) - newRect.size.height/2;
        }
        NSAffineTransform *transf;
        transf = [NSAffineTransform transform];
        [transf translateXBy: newRect.origin.x yBy: newRect.origin.y];
        [transf rotateByDegrees:-90];
        [transf concat];
        newRect.origin = NSMakePoint(0, 0);
        [aString drawInRect: newRect];
        [transf invert];
        [transf concat];

    }
}

- (void) drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView
{
    if ([controlView window] == nil) {
        return;
    }

    cellFrame = [self drawingRectForBounds: cellFrame];

    [self _drawAttributedText: [self attributedStringValue]
                      inFrame: cellFrame];
}
@end

@interface HierarchyRuler(Private)
- (id)instanceAtPoint:(NSPoint)point
               ofType:(PajeContainerType *)containerType
          inContainer:(PajeContainer *)container
                level:(int)level;
- (id)instanceAtPoint:(NSPoint)point
           inInstance:(id)instance
               ofType:(PajeContainerType *)containerType
                level:(int)level;
- (id)instanceAtPoint:(NSPoint)point;

- (void)drawContainer:(PajeContainer *)container
               layout:(STContainerTypeLayout *)layout
               inRect:(NSRect)drawRect
                level:(int)level
               offset:(float)offset;
- (void)drawContainerLayout:(STContainerTypeLayout *)layout
                inContainer:(PajeContainer *)container
                     inRect:(NSRect)drawRect
                      level:(int)level
                     offset:(float)offset;
@end


@implementation HierarchyRuler
- (id)initWithScrollView:(NSScrollView *)scrollView
              controller:(STController *)c;
{
    int i;
    
    self = [super initWithScrollView:scrollView orientation:NSVerticalRuler];
    if (self == nil)
        return self;

    controller = c;

    thicknesses = [[[NSUserDefaults standardUserDefaults]
                              arrayForKey:@"HierarchyRulerThicknesses"]
                              mutableCopy];
    if (thicknesses == nil) {
        thicknesses = [[NSMutableArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.],
                           [NSNumber numberWithFloat:40.],
                           [NSNumber numberWithFloat:60.],
                           nil] retain];
    }
    for (i = 0; i < [thicknesses count]; i++) {
        id obj;
        obj = [thicknesses objectAtIndex:i];
        if (![obj isKindOfClass:[NSNumber class]]) {
            obj = [NSNumber numberWithFloat:[obj floatValue]];
            [thicknesses replaceObjectAtIndex:i withObject:obj];
        }
    }

    cell = [[VCell alloc] initTextCell:@""];
    [cell setWraps:YES];
    [cell setBordered:YES];
    [cell setFont:[NSFont systemFontOfSize:10.0]];
    vcell = [[VCell alloc] initTextCell:@""];
    [vcell setWraps:YES];
    [vcell setBordered:YES];
    [vcell setFont:[NSFont systemFontOfSize:10.0]];
    
    return self;
}

- (void)dealloc
{
    [thicknesses release];
    [cell release];
    [super dealloc];
}

- (void)setWidth:(float)width forLevel:(int)level
{
    if (width < 0.0) width = 0.0;
    
    while (level > [thicknesses count]-1) {
        [thicknesses addObject:[NSNumber numberWithFloat:50.0]];
    }
    [thicknesses replaceObjectAtIndex:level
                           withObject:[NSNumber numberWithFloat:width]];
    [[NSUserDefaults standardUserDefaults]
                             setObject:thicknesses
                                forKey:@"HierarchyRulerThicknesses"];
}

- (float)widthForLevel:(int)level
{
    if (level > maxLevel) maxLevel = level;
    if (level >= [thicknesses count]) {
        [self setWidth:50 forLevel:level];
    }
    return [[thicknesses objectAtIndex:level] floatValue];
}

- (float)positionForLevel:(int)level
{
    int i;
    float pos = 0.0;
    
    for (i=0; i<level; i++) {
        pos += [self widthForLevel:i];
    }
    return pos;
}

- (int)indexForPosition:(float)position
{
    int i = 0;
    float pos = 0.0;
    int index = -1;

    do {
        pos += [self widthForLevel:i];
        i = i + 1;
        if (position > pos-2 && position < pos+2) {
            index = i;
        }
    } while (pos < position+3);
    return index;
}

- (int)levelForPosition:(float)position
{
    int i = 0;
    float pos = 0.0;

    do {
        pos += [self widthForLevel:i];
        i = i + 1;
    } while (pos < position);
    return i-1;
}

- (hierarchyRulerPart)hitPart:(NSPoint)position
{
    int i = 0;
    float pos = 0.0;

    do {
        pos += [self widthForLevel:i];
        i = i + 1;
        if (position.x > pos-2 && position.x < pos+2) {
            return hierarchyRulerVerticalDivider;
        }
        if (position.x < pos) {
            return hierarchyRulerBox;
        }
    } while (pos < position.x+3);
    return hierarchyRulerNone;
}

- (void)refreshSizes
{
if (maxLevel == 0) maxLevel = 1;
    [self setRuleThickness:[self positionForLevel:maxLevel+1]];//[thicknesses count]/* - 1*/]];
    [[self enclosingScrollView] tile];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)drawRect
                   forVariableLayout:(STVariableTypeLayout *)layout
{
    float vMin;
    float vMax;
    float yScale;
    float yOffset;
    PajeEntityType *entityType;
    
    entityType = [layout entityType];

    vMin = [layout minValue];
    vMax = [layout maxValue];
    if (vMax <= vMin) {
        vMin = [controller minValueForEntityType:entityType];
        vMax = [controller maxValueForEntityType:entityType];
    }

    if (vMin != vMax) {
        yScale = -([layout height] - 4) / (vMax - vMin);
    } else {
        yScale = 1;
    }

    yOffset = NSMinY(drawRect) + 2 - (vMax * yScale);

    //y = [filter valueForEntity:entity] * yScale + yOffset;
    [[NSColor controlColor] set];
    //NSRectFill(drawRect);
    NSBezierPath *path;
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(NSMaxX(drawRect), NSMinY(drawRect) + 2)];
    [path lineToPoint:NSMakePoint(NSMaxX(drawRect), NSMaxY(drawRect) - 2)];
    
    NSFont *font = [NSFont systemFontOfSize: [NSFont smallSystemFontSize]];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                               font, NSFontAttributeName,
                               [NSColor blackColor], NSForegroundColorAttributeName,
                               nil];

    NSEnumerator *en = [[layout hashMarkValues] objectEnumerator];
    NSNumber *n;
    while ((n = [en nextObject]) != nil) {
        NSSize size;
        NSString *str;
        NSString *hashValueFormat = [layout hashValueFormat];
        float v = [n floatValue];
        float y = v * yScale + yOffset;
        float x;
        [path moveToPoint:NSMakePoint(NSMaxX(drawRect) - 4, y)];
        [path lineToPoint:NSMakePoint(NSMaxX(drawRect), y)];
        str = [NSString stringWithFormat:hashValueFormat, v];
        size = [str sizeWithAttributes:attr];
        x = NSMaxX(drawRect) - size.width;
        if (y > NSMinY(drawRect) + size.height + 1) {
            [str drawAtPoint:NSMakePoint(x, y - size.height + 2)
              withAttributes:attr];
        } else {
            [str drawAtPoint:NSMakePoint(x, y + 1)
              withAttributes:attr];
        }
    }
    [[NSColor blackColor] set];
    [path stroke];
    [attr release];
}
- (void)drawHashMarksAndLabelsInRect:(NSRect)drawRect
                  forContainerLayout:(STContainerTypeLayout *)layout
{
    float vMin;
    float vMax;
    float yScale;
    float yOffset;
    PajeEntityType *entityType;
    
    entityType = [layout entityType];

    vMin = [layout minValue];
    vMax = [layout maxValue];
    if (vMax <= vMin) {
        return;
    }

    yScale = -([layout heightForVariables] - 4) / (vMax - vMin);

    yOffset = NSMinY(drawRect) + 2 - (vMax * yScale)
+ [layout variablesOffset] ;
    //y = [filter valueForEntity:entity] * yScale + yOffset;
    [[NSColor controlColor] set];
    //NSRectFill(drawRect);
    NSBezierPath *path;
    path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(NSMaxX(drawRect), NSMinY(drawRect) + 2)];
    [path lineToPoint:NSMakePoint(NSMaxX(drawRect), NSMaxY(drawRect) - 2)];
    
    NSFont *font = [NSFont systemFontOfSize: [NSFont smallSystemFontSize]];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                               font, NSFontAttributeName,
                               [NSColor blackColor], NSForegroundColorAttributeName,
                               nil];

    NSEnumerator *en = [[layout hashMarkValues] objectEnumerator];
    NSNumber *n;
    while ((n = [en nextObject]) != nil) {
        NSSize size;
        NSString *str;
        NSString *hashValueFormat = [layout hashValueFormat];
        float v = [n floatValue];
        float y = v * yScale + yOffset;
        float x;
        [path moveToPoint:NSMakePoint(NSMaxX(drawRect) - 4, y)];
        [path lineToPoint:NSMakePoint(NSMaxX(drawRect), y)];
        str = [NSString stringWithFormat:hashValueFormat, v];
        size = [str sizeWithAttributes:attr];
        x = NSMaxX(drawRect) - size.width;
        if (y > NSMinY(drawRect) + size.height + 1) {
            [str drawAtPoint:NSMakePoint(x, y - size.height + 2)
              withAttributes:attr];
        } else {
            [str drawAtPoint:NSMakePoint(x, y + 1)
              withAttributes:attr];
        }
    }
    [[NSColor blackColor] set];
    [path stroke];
    [attr release];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)drawRect
{
int x;
x = maxLevel;//[thicknesses count];
maxLevel = 0;
    [self drawContainer:[controller rootInstance]
                 layout:[controller rootLayout]
                 inRect:drawRect
                  level:0
                 offset:NSMinY([[self clientView] visibleRect])];
if (x != maxLevel/*[thicknesses count]*/) {
 [self performSelector:@selector(refreshSizes) withObject:nil afterDelay:0.0];
} 
}

- (void)drawContainer:(PajeContainer *)container
               layout:(STContainerTypeLayout *)layout
               inRect:(NSRect)drawRect
                level:(int)level
               offset:(float)offset
{
    NSEnumerator *sublayoutEnum;
    STContainerTypeLayout *sublayout;

if ([layout heightForVariables] > 10) {
NSRect r = [layout rectOfInstance:container];
r.origin.x = NSMinX(drawRect);
r.origin.y -= offset;
r.size.width = NSMaxX([self bounds]) - r.origin.x - 1;
[self drawHashMarksAndLabelsInRect:r forContainerLayout:layout];
}
    sublayoutEnum = [[layout subtypes] objectEnumerator];
    while ((sublayout = [sublayoutEnum nextObject]) != nil) {
        [self drawContainerLayout:sublayout
                      inContainer:container
                           inRect:drawRect
                            level:level
                           offset:offset];
    }
}

- (void)drawContainerLayout:(STContainerTypeLayout *)layout
                inContainer:(PajeContainer *)container
                     inRect:(NSRect)drawRect
                      level:(int)level
                     offset:(float)offset
{
    NSRect r;
    
#ifndef SHOW_TYPES
    if (![layout isContainer]) {
        return;
    }
#endif

    r = [layout rectInContainer:container];

    r.origin.y -= offset;
    //r.size.height += 1;
    r.origin.x = drawRect.origin.x;
    r.size.width = drawRect.size.width;
    if (!NSIsEmptyRect(r /*NSIntersectionRect(r, drawRect)*/)) {
        NSEnumerator *ienum;
        id instance;

#ifdef SHOW_TYPES
        if (r.size.width > 2 && [layout drawingType] != PajeLinkDrawingType
                             && [layout drawingType] != PajeVariableDrawingType) {
            [vcell setStringValue:[layout description]];
            r.origin.x = [self positionForLevel:level] - 1;
            if ([layout isContainer]) {
                r.size.width = [self widthForLevel:level] /*+ 1*/;
            } else {
[self widthForLevel:level];
                r.size.width = NSMaxX([self bounds]) - r.origin.x - 1;
            }
            [vcell drawWithFrame:NSInsetRect(r, -.5, -.5) inView:self];
        }
        if (r.size.width > 2 && [layout drawingType] == PajeVariableDrawingType) {
            [self widthForLevel:level];
//r.size.width = NSMaxX([self bounds]) - r.origin.x - 1;
//[self drawHashMarksAndLabelsInRect:r forVariableLayout:layout];
        }
        if (![layout isContainer]) return;
        level++;
#endif

        // check all instances on this hierarchy
        ienum = [controller enumeratorOfContainersTyped:[layout entityType]
                                            inContainer:container];
        while ((instance = [ienum nextObject]) != nil) {
            r = [layout rectOfInstance:instance];

            r.origin.y -= offset;
            //r.size.height += 1;
            r.origin.x = [self positionForLevel:level] - 1;
            r.size.width = [self widthForLevel:level] /*+ 1*/;
            if (!NSIsEmptyRect(r /*NSIntersectionRect(r, drawRect)*/)) {
                if (r.size.width > 2) {
                    if (containerBeingDragged != nil 
                        && [instance isEqual:containerBeingDragged]) {
                        NSDrawWhiteBezel(NSInsetRect(r, -.5, -.5),
                                         NSInsetRect(r, -.5, -.5));
                    } else if ([[controller selectedContainers]
                                                     containsObject:instance]) {
                        [[NSColor whiteColor] set];
                        NSRectFill(r);
                    }
                    [cell setStringValue:[instance description]];
                    [cell drawWithFrame:NSInsetRect(r, -.5, -.5) inView:self];
                }
            }

            [self drawContainer:instance
                         layout:layout
                         inRect:drawRect
                          level:level+1
                         offset:offset];
        }
    }
}

- (id)instanceAtPoint:(NSPoint)point
               ofType:(PajeContainerType *)containerType
          inContainer:(PajeContainer *)container
                level:(int)level
{
    STEntityTypeLayout *layoutDescriptor;
    NSRect r;
    float position = [self positionForLevel:level];
    float width = [self widthForLevel:level];
    
    if (point.x < position) {
        return nil;
    }
    
    layoutDescriptor = [controller descriptorForEntityType:containerType];

    if (![layoutDescriptor isContainer]) {
        return nil;
    }

    r = [layoutDescriptor rectInContainer:container];

    if (point.y >= NSMinY(r) && point.y <= NSMaxY(r)) {
        NSEnumerator *ienum;
        id instance;

        // check all instances on this hierarchy
        ienum = [controller enumeratorOfContainersTyped:containerType
                                            inContainer:container];
        while ((instance = [ienum nextObject]) != nil) {
            if (point.x < position+width) {
                r = [(STContainerTypeLayout *)layoutDescriptor rectOfInstance:instance];

                //r.size.height += 1;
                r.origin.x = position - 1;
                r.size.width = width /*+ 1*/;
                if (NSMouseInRect(point, r, [self isFlipped])) {
                    return instance;
                }
            } else {
                id subinstance;
                subinstance = [self instanceAtPoint:point
                                         inInstance:instance
                                             ofType:containerType
                                              level:level+1];
                if (subinstance != nil)
                    return subinstance;
            }
        }
    }
    return nil;
}

- (id)instanceAtPoint:(NSPoint)point
           inInstance:(id)instance
               ofType:(PajeContainerType *)containerType
                level:(int)level
{
    NSArray *subtypes;
    NSEnumerator *subtypeEnum;
    PajeContainerType *subtype;
    id foundInstance = nil;

    subtypes = [controller containedTypesForContainerType:containerType];
    subtypeEnum = [subtypes objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        foundInstance = [self instanceAtPoint:point
                                       ofType:subtype
                                  inContainer:instance
#ifdef SHOW_TYPES
                                        level:level+1];
#else
                                        level:level];
#endif
        if (foundInstance != nil) {
            break;
        }
    }
    return foundInstance;
}
- (id)instanceAtPoint:(NSPoint)point
{
    float offset;
    PajeContainer *root;
    PajeContainerType *rootType;
    
    offset = NSMinY([[self clientView] visibleRect]);
    point.y += offset;
    root = [controller rootInstance];
    rootType = (PajeContainerType *)[controller entityTypeForEntity:root];
    return [self instanceAtPoint:point
                      inInstance:root
                          ofType:rootType
                           level:0];
}

- (void)trackVerticalDivider:(NSEvent *)event
{
    NSPoint mouseDownLocation;
    NSPoint currentMouseLocation;
    int mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;
    
    int indexBeingDragged;
    int deltaPosition;
    int originalWidth;
    int currentWidth;
    
    mouseDownLocation = [self convertPoint:[event locationInWindow]
                                  fromView:nil];
    
    indexBeingDragged = [self indexForPosition:mouseDownLocation.x];
    if (indexBeingDragged == -1) {
        return;
    }
    
    originalWidth = [self widthForLevel:indexBeingDragged - 1];
    
    [self lockFocus];
    
    do {
        event = [NSApp nextEventMatchingMask: mask
                                   untilDate: [NSDate distantFuture]
                                      inMode: NSEventTrackingRunLoopMode
                                     dequeue: YES];
        currentMouseLocation = [self convertPoint:[event locationInWindow]
                                         fromView:nil];
                                         
        deltaPosition = currentMouseLocation.x - mouseDownLocation.x;
        currentWidth = originalWidth + deltaPosition;
        if (currentWidth < 0) currentWidth = 0;
        
        [self setWidth:currentWidth
              forLevel:indexBeingDragged - 1];
        [self refreshSizes];
    } while ([event type] != NSLeftMouseUp);

    [self unlockFocus];
}

- (void)trackHorizontalDivider:(NSEvent *)event
{
}

/** scroll client view if necessary, to make r visible.
 *  r has x coordinates in ruler, y in client view.
 *  return YES if scroll was made, NO if rect was already visible
 */
- (BOOL)_makeRectVisible:(NSRect) r
{
    id drawView = [self clientView];
    NSRect visible = [drawView visibleRect];
    
    r.origin.x = NSMinX(visible);
    r.size.width = 1;
    if (!NSEqualRects(visible, NSUnionRect(visible, r))) {
        [drawView scrollRectToVisible:r];
        [self displayIfNeeded];
        return YES;
    }
    return NO;
}

- (NSImage *)_getImageInRect:(NSRect)rect
{
    NSCachedImageRep *imageRep;
    NSImage *image;
    NSRect imageRect;
    NSRect windowRect;
    
    imageRect.origin = NSZeroPoint;
    imageRect.size = rect.size;
    imageRep = [[NSCachedImageRep alloc] initWithWindow:nil rect:imageRect];
    [[[imageRep window] contentView] lockFocus];
    windowRect = rect;
    windowRect.origin.y -= NSMinY([[self clientView] visibleRect]);
    windowRect = [self convertRect:windowRect toView:nil];
    NSCopyBits([[self window] gState], windowRect, NSZeroPoint);
    [[[imageRep window] contentView] unlockFocus];
    image = [[NSImage alloc] initWithSize:rect.size];
    [image lockFocus];
    [imageRep draw];
    [image unlockFocus];
    [imageRep release];
    return [image autorelease];
}

- (void)trackBox:(NSEvent *)event
{
    NSPoint mouseDownLocation;
    float mouseDownYInView;
    float currentMouseYInView;
    NSRect limitRect;
    NSRect instanceRect;
    NSRect currentRect;
    STEntityTypeLayout *layoutDescriptor;
    DrawView *drawView;
    //PajeFilter *filter;
    PajeEntityType *entityType;
    PajeContainer *container;
    float minX;
    float width;
    float minY;
    float maxY;
    int indexBeingDragged;
    id clickedContainer;
    PajeContainer *droppedInstance;
    NSImage *dragImage;
    
    /* coordinate conversion here is a bit hard:
     * y ruler coordinates start from 0 independent of view position.
     * must always convert to view coordinates to know where we are.
     */
    
    mouseDownLocation = [self convertPoint:[event locationInWindow]
                                  fromView:nil];
    
    clickedContainer = [self instanceAtPoint:mouseDownLocation];

    if (clickedContainer == nil || ![clickedContainer isContainer]) {
        return;
    }
    
    drawView = (DrawView *)[self clientView];
    //filter = [drawView filter];

    entityType = [controller entityTypeForEntity:clickedContainer];
    layoutDescriptor = [controller descriptorForEntityType:entityType];
    container = [controller containerForEntity:clickedContainer];

    limitRect = [layoutDescriptor rectInContainer:container];
    instanceRect = [(STContainerTypeLayout *)layoutDescriptor rectOfInstance:clickedContainer];
    instanceRect.size.height += 1;
    instanceRect.size.width += 1;
    
    minY = NSMinY(limitRect);
    maxY = NSMaxY(limitRect) - NSHeight(instanceRect) + 1;

    indexBeingDragged = [self levelForPosition:mouseDownLocation.x];
    if (indexBeingDragged == -1) {
        return;
    }
    minX = [self positionForLevel:indexBeingDragged];
    width = [self widthForLevel:indexBeingDragged];

    limitRect.origin.x = instanceRect.origin.x = minX - 1;
    limitRect.size.width = instanceRect.size.width = width + 1;

    [self _makeRectVisible:instanceRect];

    mouseDownYInView = [drawView convertPoint:[event locationInWindow]
                                     fromView:nil].y;
    currentMouseYInView = mouseDownYInView;
    Assign(containerBeingDragged, clickedContainer);

    dragImage = [[self _getImageInRect:instanceRect] retain];

    [self lockFocus];
    
    [[self window] disableFlushWindow];
    
    currentRect = instanceRect;
    currentRect.origin.y -= NSMinY([drawView visibleRect]);
    
    [self setNeedsDisplayInRect:currentRect];
    [self displayIfNeeded];
    
    [[self window] cacheImageInRect:[self convertRect:currentRect toView:nil]];
    [dragImage dissolveToPoint:NSMakePoint(NSMinX(currentRect),
                                           NSMaxY(currentRect))
                      fraction:(float)0.7];
    
    [[self window] enableFlushWindow];
    [[self window] flushWindow];

    do {
        float newYInView;
        float deltaY;
        int mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;
    
        event = [NSApp nextEventMatchingMask: mask
                                   untilDate: [NSDate distantFuture]
                                      inMode: NSEventTrackingRunLoopMode
                                     dequeue: YES];
        newYInView = [drawView convertPoint:[[self window]
                                              mouseLocationOutsideOfEventStream]
                                   fromView:nil].y;
        if (newYInView == currentMouseYInView) continue;
        currentMouseYInView = newYInView;
                                         
        deltaY = currentMouseYInView - mouseDownYInView;
        
        currentRect.origin.y = instanceRect.origin.y + deltaY;
        if (currentRect.origin.y < minY) currentRect.origin.y = minY;
        if (currentRect.origin.y > maxY) currentRect.origin.y = maxY;

        [[self window] disableFlushWindow];
        
        if ([self _makeRectVisible:currentRect]) {
            [[self window] discardCachedImage];
        } else {
            [[self window] restoreCachedImage];
        }
                    
        currentRect.origin.y -= NSMinY([drawView visibleRect]);
        [[self window] cacheImageInRect:[self convertRect:currentRect
                                                   toView:nil]];
        [dragImage dissolveToPoint:NSMakePoint(NSMinX(currentRect),
                                               NSMaxY(currentRect))
                          fraction:(float)0.7];

        [[self window] enableFlushWindow];
        [[self window] flushWindow];
    } while ([event type] != NSLeftMouseUp);

    [self unlockFocus];
    [[self window] discardCachedImage];
    [dragImage release];
    
    droppedInstance = [self instanceAtPoint:NSMakePoint(NSMidX(currentRect),
                                                        NSMidY(currentRect))];
    if ([droppedInstance isEqual:containerBeingDragged]) {
        NSMutableSet *containers;
        containers = [[controller selectedContainers] mutableCopy];
        if ([containers containsObject:containerBeingDragged]) {
            [containers removeObject:containerBeingDragged];
        } else {
            [containers addObject:containerBeingDragged];
        }
            
        [controller setSelectedContainers:containers];
        [containers release];
    } else if (droppedInstance != nil) {
        NSMutableArray *order;
        NSEnumerator *contEnum;
        PajeContainer *orgContainer;
        BOOL before;
        float droppedCenter = NSMidY([(STContainerTypeLayout *)layoutDescriptor rectOfInstance:droppedInstance]);
        float currentCenter = NSMidY(currentRect) - 0.5
                            + NSMinY([drawView visibleRect]) - 0.5;
        
        before = (currentCenter < droppedCenter)
                 || ((currentCenter == droppedCenter) 
                     && (currentMouseYInView < mouseDownYInView));
        order = [NSMutableArray array];
        contEnum = [controller enumeratorOfContainersTyped:entityType
                                               inContainer:container];
        while ((orgContainer = [contEnum nextObject]) != nil) {
            if ([orgContainer isEqual:containerBeingDragged]) {
                continue;
            } else if ([orgContainer isEqual:droppedInstance]) {                                 if (!before) [order addObject:orgContainer];
                [order addObject:containerBeingDragged];
                if (before) [order addObject:orgContainer];
            } else {
                [order addObject:orgContainer];
            }
        }
        [controller setOrder:order
       ofContainersTyped:entityType
             inContainer:container];
    } else {
        [self setNeedsDisplay:YES];
    }
    Assign(containerBeingDragged, nil);
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint mouseDownLocation;
    hierarchyRulerPart hitPart;
    
    mouseDownLocation = [self convertPoint:[event locationInWindow]
                                  fromView:nil];
    
    hitPart = [self hitPart:mouseDownLocation];
    switch (hitPart) {
    case hierarchyRulerVerticalDivider:
        [self trackVerticalDivider:event];
        break;
    case hierarchyRulerHorizontalDivider:
        [self trackHorizontalDivider:event];
        break;
    case hierarchyRulerBox:
        [self trackBox:event];
        break;
    case hierarchyRulerNone:
        break;
    default:
        NSAssert(NO, @"Invalid hit part in HierarchyRuler");
    }
}

@end
