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

@interface VCell : NSCell
@end
@implementation VCell
- (void) _drawAttributedText: (NSAttributedString*)aString 
		     inFrame: (NSRect)aRect
{
  NSSize titleSize;
  NSRect newRect;

  if (aString == nil)
    return;

/*
[aString drawInRect:aRect];
return;

  if (NSWidth(aRect) > NSHeight(aRect)) {
    [super _drawAttributedText: aString inFrame:aRect];
    return;
  }
//*/

  titleSize = [aString size];

  /** Important: text should always be vertically centered without
   * considering descender [as if descender did not exist].
   * This is particularly important for single line texts.
   * Please make sure the output remains always correct.
   */
//  aRect.origin.y = NSMidY (aRect) - titleSize.height/2; 
//  aRect.size.height = titleSize.height;
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
                        * (1000-(int)(1000-(titleSize.width / newRect.size.width)));
    if (newRect.size.height > aRect.size.height) {
        newRect.size.height = aRect.size.height;
    }
    newRect.origin.y = NSMidY(aRect) - newRect.size.height/2;
  }
  //PSgsave();
  //PStranslate(newRect.origin.x, newRect.origin.y);
  //newRect.origin = NSMakePoint(0, 0);
  //PSrotate(-90);
  [aString drawInRect: newRect];
  //PSgrestore();
  
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
                        * (1000-(int)(999.5-(titleSize.width / newRect.size.width)));
    if (newRect.size.height > aRect.size.width) {
        newRect.size.height = aRect.size.width;
    }
    newRect.origin.x = NSMidX(aRect) - newRect.size.height/2;
  }
  PSgsave();
  PStranslate(newRect.origin.x, newRect.origin.y);
  newRect.origin = NSMakePoint(0, 0);
  PSrotate(-90);
  [aString drawInRect: newRect];
  PSgrestore();

  }
}
- (void) drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView
{
  if (![controlView window])
    return;

  cellFrame = [self drawingRectForBounds: cellFrame];

  //FIXME: Check if this is also neccessary for images,
  // Add spacing between border and inside 
  if (_cell.is_bordered || _cell.is_bezeled)
    {
      cellFrame.origin.x += 3;
      cellFrame.size.width -= 6;
      cellFrame.origin.y += 1;
      cellFrame.size.height -= 2;
    }

  switch (_cell.type)
    {
      case NSTextCellType:
        {
	  [self _drawAttributedText: [self attributedStringValue]
		inFrame: cellFrame];
	}
	break;

      case NSImageCellType:
	if (_cell_image)
	  {
	    NSSize size;
	    NSPoint position;

	    size = [_cell_image size];
	    position.x = MAX(NSMidX(cellFrame) - (size.width/2.),0.);
	    position.y = MAX(NSMidY(cellFrame) - (size.height/2.),0.);
	    /*
	     * Images are always drawn with their bottom-left corner
	     * at the origin so we must adjust the position to take
	     * account of a flipped view.
	     */
	    if ([controlView isFlipped])
	      position.y += size.height;
	    [_cell_image compositeToPoint: position operation: NSCompositeSourceOver];
	  }
	 break;

      case NSNullCellType:
         break;
    }

  if (_cell.shows_first_responder)
    NSDottedFrameRect(cellFrame);

  // NB: We don't do any highlighting to make it easier for subclasses
  // to reuse this code while doing their own custom highlighting and
  // prettyfying
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
        if (r.size.width > 2 && [layout drawingType] != PajeLinkDrawingType) {
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
