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
#ifndef _DrawView_h_
#define _DrawView_h_

/*
 * DrawView.h
 *
 * a View that knows how to draw lines
 *
 * 19960120 BS  creation
 * 19960212 BS  clean-up
 * 19980418 BS  major change in internal organization
 *              added description of entities, to ease the addition of
 *              new entity types.
 */

#include <AppKit/AppKit.h>
#include "STEntityTypeLayout.h"
#include "../General/Protocols.h"
#include "../General/PajeFilter.h"
#include "STController.h"

@class STController;

@interface DrawView: NSView
{
    IBOutlet NSTextField *cursorTimeField; // TextField to show the time where the cursor is
    NSString *cursorTimeFormat;
    IBOutlet NSTextField *entityNameField; // TextField for the name of the entity under cursor
    IBOutlet NSButton *doubleTimeScaleButton;
    IBOutlet NSButton *zoomToSelectionButton;

    PajeFilter *filter;        // The filter component connected to us
    
    IBOutlet STController *controller;

    double    pointsPerSecond; // current time scale
    double    timeUnitDivisor; // conversion between seconds and current time unit
    BOOL      hasZoomed;       // used internally during a time zoom

    NSDate   *startTime;       // time where trace starts
    NSDate   *endTime;         // time where trace ends
    NSDate   *oldMiddleTime;   // time at the middle of the scale before the zoom

    NSArray  *highlightedEntities; // entities highlighted by cursor position
    PajeEntity *cursorEntity;  // the entity under the cursor

    NSTrackingRectTag trackingRectTag; // the tag of the tracking rect (adjustSize)
    NSColor  *backgroundColor;
    NSColor  *selectedBackgroundColor;

    NSDate   *selectionAnchorTime;
    NSDate   *selectionStartTime;
    NSDate   *selectionEndTime;
    BOOL      isMakingSelection;
    BOOL      selectionExists;
    
    int       smallEntityWidth;
    
#ifdef GNUSTEP
    // GNUstep doesn't draw rectangles that are too big. They are intersected with this.
    NSRect    cutRect;
#endif

    NSDictionary *entityNameAttributes;
	
    NSImage *highlightImage;
    NSImage *highlightMask;
    NSAffineTransform *highlightTransform;
    NSColor *highlightColor;
}

/* instance methods */
- (void)setFilter:(PajeFilter *)newFilter;

- (IBAction)doubleTimeScale:sender;
- (IBAction)halveTimeScale:sender;
- (IBAction)zoomToSelection:sender;

- (IBAction)getSmallEntityWidthFrom:sender;

- (void)awakeFromNib;

- (void)adjustSize;

- (void)adjustTimeLimits;
- (void)saveMiddleTime;

- (void)setPointsPerSecond:(double)pps;
- (double)pointsPerSecond;
- (NSDate *)startTime;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)color;

- (void)drawRect:(NSRect)rect;

- (void)setCursorEntity:(PajeEntity *)entity;
- (void)setHighlightedEntities:(NSArray *)entities;
- (NSArray *)highlightedEntities;

- (void)changeSelectionWithPoint:(NSPoint)point;
- (void)setNeedsDisplayFromX:(double)x1 toX:(double)x2;
- (void)timeSelectionChanged;

- (PajeFilter *)filter;

- (double)timeToX:(NSDate *)t;
@end

@interface DrawView (Mouse)
- (BOOL)becomeFirstResponder;
- (BOOL)acceptsFirstMouse:(NSEvent *)event;
- (void)mouseEntered:(NSEvent *)event;
- (void)mouseExited:(NSEvent *)event;
- (void)mouseMoved:(NSEvent *)event;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)setCursorTime:(NSDate *)time;
@end

@interface DrawView (Drawing)

- (void)drawHighlight;

- (void)drawInstance:(id)entity
        ofDescriptor:(STContainerTypeLayout *)layoutDescriptor
              inRect:(NSRect)drawRect;

/* private methods */
- (void)drawAllInstancesOfDescriptor:(STContainerTypeLayout *)layoutDescriptor
                         inContainer:(PajeContainer *)container
                              inRect:(NSRect)drawRect;

- (void)drawEntitiesWithDescriptor:(STEntityTypeLayout *)layoutDescriptor
                       inContainer:(PajeContainer *)container
                        insideRect:(NSRect)drawRect;
- (void)drawEntitiesWithDescriptor:(STEntityTypeLayout *)layout
                       inContainer:(PajeContainer *)container
                    fromEnumerator:(NSEnumerator *)enumerator;
- (void)drawEventsWithDescriptor:(STEventTypeLayout *)layoutDescriptor
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator;
- (void)drawStatesWithDescriptor:(STStateTypeLayout *)layoutDescriptor
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator;
- (void)drawLinksWithDescriptor:(STLinkTypeLayout *)layoutDescriptor
                    inContainer:(PajeContainer *)container
                 fromEnumerator:(NSEnumerator *)enumerator;
- (void)drawValuesWithDescriptor:(STVariableTypeLayout *)layoutDescriptor
                     inContainer:(PajeContainer *)container
                  fromEnumerator:(NSEnumerator *)enumerator;
@end

@interface DrawView (Finding)
BOOL line_hit(double px, double py,
              double x1, double y1, double x2, double y2);
- (BOOL)isPoint:(NSPoint)p insideEntity:(PajeEntity *)entity;
- (PajeEntity *)findEntityAtPoint:(NSPoint)point;
- (NSArray *)findEntitiesAtPoint:(NSPoint)point;

/* private methods */
- (PajeEntity *)entityAtPoint:(NSPoint)point
           inEntityDescriptor:(STEntityTypeLayout *)layoutDescriptor
                  inContainer:(PajeContainer *)container;
- (PajeEntity *)entityAtPoint:(NSPoint)point
                   inInstance:(id)instance
           ofLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor;
- (PajeEntity *)entityAtPoint:(NSPoint)point
             layoutDescriptor:(STEntityTypeLayout *)layoutDescriptor
                  inContainer:(PajeContainer *)container;
- (NSArray *)entitiesAtPoint:(NSPoint)point
          inEntityDescriptor:(STEntityTypeLayout *)layoutDescriptor
                 inContainer:(PajeContainer *)container;
- (NSArray *)entitiesAtPoint:(NSPoint)point
                  inInstance:(id)instance
          ofLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor;
- (NSArray *)entitiesAtPoint:(NSPoint)point
            layoutDescriptor:(STEntityTypeLayout *)layoutDescriptor
                 inContainer:(PajeContainer *)container;

- (NSRect)rectForEntity:(PajeEntity *)entity;
- (NSRect)drawRectForEntity:(PajeEntity *)entity;
- (NSRect)highlightRectForEntity:(PajeEntity *)entity;
@end

#define TIMEtoX(time) (startTime?[time timeIntervalSinceDate:startTime] * pointsPerSecond:0)
#define XtoTIME(x) [startTime addTimeInterval:(x) / pointsPerSecond]
//#define TIMEtoX(time) ([time timeIntervalSinceReferenceDate] * pointsPerSecond)
//#define XtoTIME(x) [NSDate dateWithTimeIntervalSinceReferenceDate:(x) / pointsPerSecond]
#define SMALL_ENTITY_DURATION (smallEntityWidth / pointsPerSecond)

#endif
