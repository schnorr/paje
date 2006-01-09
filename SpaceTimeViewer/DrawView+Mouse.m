/*
    Copyright (c) 1998--2005 Benhur Stein
    
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
// DrawView+Mouse
// --------------
// mouse-related methods in DrawView.
// all these methods are overriding methods defined in NSView.

#include "DrawView.h"
#include "../General/Macros.h"

@implementation DrawView (Mouse)

/*
 * Mouse control
 * ------------------------------------------------------------------------
 */

#ifdef GNUSTEP
- (BOOL)acceptsFirstResponder
{
    return YES;
}
#endif


- (BOOL)becomeFirstResponder
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    return YES;
}


// when the user clicks over this view, we want it to react, even
// if the window wasn't selected
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)mouseEntered:(NSEvent *)event
{
    [[self window] setAcceptsMouseMovedEvents: YES];
    [[self window] makeFirstResponder:self];
}

- (void)mouseExited:(NSEvent *)event
{
    [[self window] setAcceptsMouseMovedEvents:NO];
    [[self window] discardEventsMatchingMask:NSMouseMovedMask beforeEvent:event];
//    [cursorTimeField setStringValue:@""];
    [self setHighlightedEntity:nil];
    [[self window] discardCachedImage];
}

- (void)mouseMoved:(NSEvent *)event
{
    NSPoint point;
    PajeEntity *entityUnderCursor;

    point = [[self window] mouseLocationOutsideOfEventStream];
    point = [self convertPoint:[event locationInWindow] fromView:nil];

    if (!NSMouseInRect(point, [self visibleRect], [self isFlipped])) {
        return;
    }

    if ([event modifierFlags] & NSShiftKeyMask) {
        [self highlightEntities:[self findEntitiesAtPoint:point]];
    } else {
        entityUnderCursor = [self findEntityAtPoint:point];
        [self setHighlightedEntity:entityUnderCursor];
    }

    [self setCursorTime:XtoTIME(point.x)];
}

- (void)setCursorTime:(NSDate *)time
{
#ifdef GNUSTEP
    [cursorTimeField setStringValue:[NSString stringWithFormat:@"%.6f",
                [time timeIntervalSinceReferenceDate] * timeUnitDivisor]];
#else
    [cursorTimeField setDoubleValue:
                [time timeIntervalSinceReferenceDate] * timeUnitDivisor];
#endif
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint cursorPoint;
    NSDate *cursorTime;
    
    if (highlightedEntity && ![highlightedEntity isContainer]) {
        return;
    }
    [self setHighlightedEntity:nil];

    cursorPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    cursorTime = XtoTIME(cursorPoint.x);

    isMakingSelection = YES;
    
    // if there is a selection and the shift key is pressed, the
    // previous selection is changed.
    if (selectionExists && ([event modifierFlags] & NSShiftKeyMask)) {
        // Move the selection anchor to the side most distant from the cursor.
        double selectionStartX;
        double selectionEndX;
        selectionStartX = TIMEtoX(selectionStartTime);
        selectionEndX = TIMEtoX(selectionEndTime);
        if (ABS([cursorTime timeIntervalSinceDate:selectionEndTime])
            > ABS([cursorTime timeIntervalSinceDate:selectionStartTime])) {
            Assign(selectionAnchorTime, selectionEndTime);
        } else {
            Assign(selectionAnchorTime, selectionStartTime);
        }
    } else {
        // current selection will be forgotten; start new selection
        Assign(selectionAnchorTime, cursorTime);
    }
    [self changeSelectionWithPoint:cursorPoint];
}

- (void)mouseDragged:(NSEvent *)event
{
    NSPoint cursorPoint;
    
    if (!isMakingSelection)
        return [self mouseMoved:event];

    cursorPoint = [self convertPoint:[event locationInWindow] fromView:nil];

    [self changeSelectionWithPoint:cursorPoint];
}

- (void)mouseUp:(NSEvent *)event
{
    if (highlightedEntity != nil) {
        [filter inspectEntity:highlightedEntity];
    }

    isMakingSelection = NO;
}

- (void)keyDown:(NSEvent *)event
{
    int up;
    NSArray *entities;
    NSEnumerator *entitiesEnum;
    id entity;
    int imbricationLevel;

    if ([[event characters] isEqualToString:@"l"]) {
        NSPoint p;
        p = [(NSClipView *)[self superview] documentVisibleRect].origin;
        p.x -= 50;
        [self scrollPoint:p];
       // [[self enclosingScrollView] reflectScrolledClipView:[self superview]];
        return;
    }
    if ([[event characters] isEqualToString:@"r"]) {
        NSPoint p;
        p = [(NSClipView *)[self superview] documentVisibleRect].origin;
        p.x += 50;
        [self scrollPoint:p];
        //[[self enclosingScrollView] reflectScrolledClipView:[self superview]];
        return;
    }
    
    if (highlightedEntity == nil)
        return;
    if ([[event characters] isEqualToString:@"c"]) {
        [filter inspectEntity:highlightedEntity];
        return;
    }
    
    if (![highlightedEntity respondsToSelector:@selector(imbricationLevel)])
        return;

    if ([[event characters] isEqualToString:[NSString stringWithCharacter:0xf701]]
        || [[event characters] isEqualToString:@"d"])
        up = 1;
    else if ([[event characters] isEqualToString:[NSString stringWithCharacter:0xf700]]
             || [[event characters] isEqualToString:@"u"])
        up = -1;
    else
        return;

    imbricationLevel = [highlightedEntity imbricationLevel] - up;
    entities = [self findEntitiesAtPoint:[self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil]];
    entitiesEnum = [entities objectEnumerator];
    while ((entity = [entitiesEnum nextObject]) != nil) {
        if ([entity respondsToSelector:@selector(imbricationLevel)]
            && [entity imbricationLevel] == imbricationLevel) {
            [self setHighlightedEntity:entity];
            return;
        }
    }
}

- (float) rulerView: (NSRulerView *)aRulerView
     willMoveMarker:(NSRulerMarker *)marker
         toLocation: (float)location
{
    NSLog(@"moving marker %@ to location %f", marker, location);
    return ((int)location/5) * 5;
}

- (void) rulerView: (NSRulerView *)aRulerView 
   handleMouseDown: (NSEvent *)theEvent
{
    NSPoint cursorPoint;
    NSRulerMarker *newMarker;
    cursorPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if ([aRulerView orientation] == NSHorizontalRuler)
    newMarker = [[NSRulerMarker alloc] initWithRulerView:aRulerView markerLocation: cursorPoint.x image:[NSImage imageNamed:@"GNUstep"] imageOrigin:NSMakePoint(5, 10)];
    else
    newMarker = [[NSRulerMarker alloc] initWithRulerView:aRulerView markerLocation: cursorPoint.y image:[NSImage imageNamed:@"GNUstep"] imageOrigin:NSMakePoint(5, 10)];
    [newMarker setRemovable:YES];
    [newMarker autorelease];
    [aRulerView trackMarker:newMarker withMouseEvent:theEvent];
}
@end
