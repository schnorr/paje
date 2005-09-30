/*
    Copyright (c) 1998-2005 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
/*
 * DrawView.m
 *
 * a View that draws lines
 *
 * 19960115 BS  creation
 * 19960212 BS  clean-up
 */

#include "DrawView.h"
#include "STController.h"

#ifdef GNUSTEP
#include <AppKit/PSOperators.h>
#endif
#ifdef __APPLE__
#include "PSOperators.h"
#endif
#if defined(NEXT)
#import <AppKit/psopsOpenStep.h>	// For PS and DPS function prototypes
#import "drawline.h"
#endif

#include "../General/NSUserDefaults+Additions.h"
#include "../General/Macros.h"

#if defined(GNUSTEP) || defined(__APPLE__)
void PSInit(void){}
#endif

#define DefaultsPrefix NSStringFromClass([self class])
#define DefaultsKey(name) [DefaultsPrefix stringByAppendingString:name]

@implementation DrawView

- (void)dealloc
{
    Assign(startTime, nil);
    Assign(endTime, nil);
    Assign(backgroundColor, nil);
    Assign(selectedBackgroundColor, nil);
    [super dealloc];
}

- (NSColor *)backgroundColor
{
    return backgroundColor;
}

- (NSColor *)selectedBackgroundColor
{
    return selectedBackgroundColor;
}

- (void)setBackgroundColor:(NSColor *)color
{
    Assign(backgroundColor, color);
    [[NSUserDefaults standardUserDefaults]
              setColor:backgroundColor
                forKey:DefaultsKey(@"BackgroundColor")];
    [self setNeedsDisplay:YES];
}

- (void)setSelectedBackgroundColor:(NSColor *)color
{
    Assign(selectedBackgroundColor, color);
    [[NSUserDefaults standardUserDefaults]
              setColor:selectedBackgroundColor
                forKey:DefaultsKey(@"SelectedBackgroundColor")];
    [self setNeedsDisplay:YES];
}

- (void)setFilter:(PajeFilter *)newFilter
{
    filter = newFilter;
}

- (PajeFilter *)filter
{
    return filter;
}

- (void)setController:(STController *)c
{
    controller = c;
}

- (void)hierarchyChanged
{
    Assign(startTime, [filter startTime]);
    Assign(endTime, [filter endTime]);
    NSDebugMLLog(@"tim", @"Hier changed. times=[%@ %@]", startTime, endTime);

    if (startTime != nil && endTime != nil) {
        [self adjustSize];
    }
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    [self adjustSize];
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    [self setNeedsDisplay:YES];
}

- (void)orderChangedForContainerType:(PajeContainerType *)containerType
{
    [self adjustSize];
}

- (void)awakeFromNib
{
    NSCursor *cursor;
    NSImage *cursorImage;
    NSString *cursorPath;
    
    // initialize postscript functions.
    PSInit();

    // initialize instance variables

    pointsPerSecond = [[NSUserDefaults standardUserDefaults]
                                doubleForKey:DefaultsKey(@"PointsPerSecond")];
    if (pointsPerSecond == 0) {
        pointsPerSecond = 10000;
    }
    smallEntityWidth = [[NSUserDefaults standardUserDefaults]
                              integerForKey:DefaultsKey(@"SmallEntityWidth")];
    hasZoomed = NO;
    filter = nil;
    trackingRectTag = 0;
    timeUnitDivisor = 1;
    [timeUnitField setStringValue:@"s"];
    [cursorTimeField setFloatingPointFormat:NO left:6 right:6];

    [zoomToSelectionButton setEnabled:NO];

//    [[self window] setBackingType:NSBackingStoreNonretained];

    // get background color from defaults
    Assign(backgroundColor, [[NSUserDefaults standardUserDefaults]
                                colorForKey:DefaultsKey(@"BackgroundColor")]);
    if (backgroundColor == nil) {
        Assign(backgroundColor, [NSColor controlBackgroundColor]);
    }
    Assign(selectedBackgroundColor, [[NSUserDefaults standardUserDefaults]
                         colorForKey:DefaultsKey(@"SelectedBackgroundColor")]);
    if (selectedBackgroundColor == nil) {
        Assign(selectedBackgroundColor, [NSColor controlLightHighlightColor]);
    }

    // initialize the cursor
    cursorPath = [[NSBundle bundleForClass:[self class]]
                     pathForImageResource:@"crosscursor"];
    cursorImage = [[NSImage alloc] initWithContentsOfFile:cursorPath];
    cursor = [[NSCursor alloc] initWithImage:cursorImage hotSpot:NSMakePoint(7,9)];
    [cursorImage release];
    if (cursor != nil) {
        [[self enclosingScrollView] setDocumentCursor:cursor];
        [cursor release];
    }

#ifdef GNUSTEP
[[cursorTimeField window] performSelector:@selector(makeKeyAndOrderFront:) withObject:self afterDelay:0];
#endif

    // register to receive color drag-and-drops
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];

//    [[EntityTypeInspector alloc] initWithDelegate:self];

    [[self enclosingScrollView] setHasHorizontalRuler:YES];
    [[[self enclosingScrollView] horizontalRulerView] setReservedThicknessForMarkers:0.0];
    [[self enclosingScrollView] setBackgroundColor:[self backgroundColor]/*[NSColor whiteColor]*/];
    [[self enclosingScrollView] setDrawsBackground:YES/*NO*/];

    //TODO: should register as tool
}



- (NSRect)adjustScroll:(NSRect)newVisible
{
    if (hasZoomed) {
        float lastX = TIMEtoX(endTime);
        float newX = TIMEtoX(oldMiddleTime) - NSWidth(newVisible) / 2;
        if ( (newX + NSWidth(newVisible)) > lastX )
            newX = lastX - NSWidth(newVisible);
        if (newX < 0) newX = 0;
        newVisible.origin.x = newX;
        hasZoomed = NO;
        Assign(oldMiddleTime, nil);
    }
    return newVisible;
}

- (void)windowDidResize:(NSNotification *)aNotification
{
    [self adjustSize];
}

- (void)setRulerUnit
{
    NSRulerView *ruler = [[self enclosingScrollView] horizontalRulerView];

    if (ruler) {
        // sets ruler scale
        NSArray *upArray;
        NSArray *downArray;
        unichar microsecond[] = {0x00b5, 's'};

        upArray = [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:5.0], [NSNumber numberWithFloat:2.0], nil];
        downArray = [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:0.2], nil];
        if (pointsPerSecond > 300000000) {
            timeUnitDivisor = 1000000000;
            [cursorTimeField setFloatingPointFormat:NO left:12 right:0];
            [timeUnitField setStringValue:@"ns"];
            [NSRulerView registerUnitWithName:@"nanoseconds"
                                 abbreviation:@"ns"
                 unitToPointsConversionFactor:pointsPerSecond/1000000000.0
                                  stepUpCycle:upArray
                                stepDownCycle:downArray];
            [ruler setMeasurementUnits: @"nanoseconds"];
        } else if (pointsPerSecond > 300000) {
            timeUnitDivisor = 1000000;
            [cursorTimeField setFloatingPointFormat:NO left:12 right:0];
            [timeUnitField setStringValue:[NSString stringWithCharacters:microsecond length:2]]; //@"us";
            [NSRulerView registerUnitWithName:@"microseconds"
                                 abbreviation:@"us"
                 unitToPointsConversionFactor:pointsPerSecond/1000000.0
                                  stepUpCycle:upArray
                                stepDownCycle:downArray];
            [ruler setMeasurementUnits: @"microseconds"];
        } else if (pointsPerSecond > 300) {
            timeUnitDivisor = 1000;
            [cursorTimeField setFloatingPointFormat:NO left:9 right:3];

            [timeUnitField setStringValue:@"ms"];
            [NSRulerView registerUnitWithName:@"milliseconds"
                                 abbreviation:@"ms"
                 unitToPointsConversionFactor:pointsPerSecond/1000.0
                                  stepUpCycle:upArray
                                stepDownCycle:downArray];
            [ruler setMeasurementUnits: @"milliseconds"];
        } else if (pointsPerSecond > 0.1) {
            timeUnitDivisor = 1;
            [cursorTimeField setFloatingPointFormat:NO left:6 right:6];
            [timeUnitField setStringValue:@"s"];
            [NSRulerView registerUnitWithName:@"seconds"
                                 abbreviation:@"s"
                 unitToPointsConversionFactor:pointsPerSecond
                                  stepUpCycle:upArray
                                stepDownCycle:downArray];
            [ruler setMeasurementUnits: @"seconds"];
        } else if (pointsPerSecond > .001) {
            timeUnitDivisor = 1.0/3600.0;
            [cursorTimeField setFloatingPointFormat:NO left:6 right:6];
            [timeUnitField setStringValue:@"h"];
            [NSRulerView registerUnitWithName:@"hours"
                                 abbreviation:@"h"
                 unitToPointsConversionFactor:pointsPerSecond*3600.0
                                  stepUpCycle:upArray
                                stepDownCycle:downArray];
            [ruler setMeasurementUnits: @"hours"];
        } else {
            timeUnitDivisor = 1.0/3600.0/24.0;
            [cursorTimeField setFloatingPointFormat:NO left:6 right:6];
            [timeUnitField setStringValue:@"d"];
            [NSRulerView registerUnitWithName:@"days"
                                 abbreviation:@"d"
                 unitToPointsConversionFactor:pointsPerSecond*3600.0*24.0
                                  stepUpCycle:upArray
                                stepDownCycle:downArray];
            [ruler setMeasurementUnits: @"days"];
        }
    }
}

#ifdef GNUSTEP
// to workaround a probable bug in GNUstep
// ([NSScrollView tile] is changing our frame size)
- (void)setFrame:(NSRect)r
{
    [super setFrame:r];
    // I know better what my size should be. set it.
    [self setFrameSize:size];
}
#endif

- (void)removeFromSuperview
{
    if (trackingRectTag != 0) {
        [self removeTrackingRect:trackingRectTag];
    }
    [super removeFromSuperview];
}

- (void)adjustSize
{
    NSRect newBounds;
    NSScrollView *scrollView = [self enclosingScrollView];
    NSRulerView *ruler = [scrollView horizontalRulerView];
    id rootInstance = [filter rootInstance];

    [self setRulerUnit];

    [self performSelector:@selector(verifyTimes:)
               withObject:self
               afterDelay:0.0];

    if (rootInstance != nil) {
        newBounds = [[controller rootLayout] rectOfInstance:rootInstance];

        newBounds.origin.x = TIMEtoX(startTime);
        newBounds.size.width = TIMEtoX(endTime) - newBounds.origin.x + 3;
        newBounds.size.height += 1;
        [self setBoundsOrigin:newBounds.origin];
        [self setFrameSize:newBounds.size];

#ifdef GNUSTEP
        // to workaround a probable bug in GNUstep
        // ([NSScrollView tile] is changing our frame size)
        // (see setFrame: above)
        size = newBounds.size;
#endif

        [ruler setOriginOffset:
                    TIMEtoX([NSDate dateWithTimeIntervalSinceReferenceDate:0])];
        [scrollView tile];
        
        // change mouse tracking rect
        if (trackingRectTag != 0) {
            [self removeTrackingRect:trackingRectTag];
        }
        trackingRectTag = [self addTrackingRect:[self visibleRect] owner:self
                                       userData:NULL assumeInside:NO];
    }
}

- (void)verifyTimes:sender
{
    //FIXME: shouldn't be necessary; encapsulator should be more intelligent
    NSScrollView *scrollView = [self enclosingScrollView];
    [filter verifyStartTime:/*startTime*/XtoTIME(NSMinX([self convertRect:[scrollView frame]
                                                    fromView:scrollView]))
                    endTime:XtoTIME(NSMaxX([self convertRect:[scrollView frame]
                                                    fromView:scrollView]))];
}

/*
 * Changing scales
 * ------------------------------------------------------------------------
 */

- (void)adjustTimeLimits
{
    NSDate *startTimeLimit;
    NSDate *endTimeLimit;
    NSDate *traceStartTime;
    NSDate *traceEndTime;

    traceStartTime = [controller startTime];
    traceEndTime = [controller endTime];
    if (oldMiddleTime != nil) {
        startTimeLimit = XtoTIME(TIMEtoX(oldMiddleTime) - 20000);
    } else {
        startTimeLimit = traceStartTime;
    }
    if ([startTimeLimit isEarlierThanDate:traceStartTime]) {
        startTimeLimit = traceStartTime;
        endTimeLimit = XtoTIME(TIMEtoX(startTimeLimit) + 40000);
        if ([endTimeLimit isLaterThanDate:traceEndTime]) {
            endTimeLimit = traceEndTime;
        }
    } else {
        endTimeLimit = XtoTIME(TIMEtoX(startTimeLimit) + 40000);
        if ([endTimeLimit isLaterThanDate:traceEndTime]) {
            endTimeLimit = traceEndTime;
            startTimeLimit = XtoTIME(TIMEtoX(endTimeLimit) - 40000);
            if ([startTimeLimit isEarlierThanDate:traceStartTime]) {
                startTimeLimit = traceStartTime;
            }
        }
    }
    Assign(startTime, startTimeLimit);
    Assign(endTime, endTimeLimit);
    NSDebugMLLog(@"tim", @"times=[%@ %@] trace=[%@ %@]", startTime, endTime, traceStartTime, traceEndTime);
}

- (void)setPointsPerSecond:(double)pps
{
    pointsPerSecond = pps;
    
    [[NSUserDefaults standardUserDefaults]
                                setDouble:pointsPerSecond
                                   forKey:DefaultsKey(@"PointsPerSecond")];
    hasZoomed = YES;

    [self adjustTimeLimits];

    [controller changedTimeScale];
}

- (void)saveMiddleTime
{
    if (startTime != nil) {
        Assign(oldMiddleTime, XtoTIME(NSMidX([self visibleRect])));
    }
}

- (void)doubleTimeScale:sender
{
    Assign(oldMiddleTime, XtoTIME(NSMidX([self visibleRect])));
    [self setPointsPerSecond:pointsPerSecond * 2];
}

- (void)halveTimeScale:sender
{
    Assign(oldMiddleTime, XtoTIME(NSMidX([self visibleRect])));
    [self setPointsPerSecond:pointsPerSecond / 2];
}

- (void)zoomToSelection:sender
{
    NSRect visible;

    if (!selectionExists) {
        return;
    }

    visible = [[self superview] frame];
    Assign(oldMiddleTime, XtoTIME((TIMEtoX(selectionStartTime)
                                   + TIMEtoX(selectionEndTime)) / 2));
    [self setPointsPerSecond: NSWidth(visible)
                 / [selectionEndTime timeIntervalSinceDate:selectionStartTime]];
}

- (double)pointsPerSecond
{
    return pointsPerSecond;
}

- (NSDate *)startTime
{
    return startTime;
}

- (double)timeToX:(NSDate *)t
{
    if (startTime == nil) return 0;
    return TIMEtoX(t);
}


/*
 * Drawing
 * ------------------------------------------------------------------------
 */

- (BOOL)isFlipped
// y-axis is inverted (y-coords augment from top to bottom)
{
    return YES;
}

- (BOOL)isOpaque
// this view draws every pixel it owns
{
    return YES;
}



- (void)highlightEntity:(PajeEntity *)entity
{
    NSColor *color;
    NSRect rect;
    STEntityTypeLayout *layoutDescriptor;
    shapefunction *path;
    drawfunction *highlight;
    PajeEntityType *entityType;

    rect = [self rectForEntity:entity];

    if (NSEqualRects(rect, NSZeroRect))
        return;
    
    color = [filter colorForEntity:entity];
    color = [color highlightWithLevel:.2];

    entityType = [filter entityTypeForEntity:entity];
    layoutDescriptor = [controller descriptorForEntityType:entityType];

    if ([layoutDescriptor drawingType] == PajeEventDrawingType) {
            [self drawEventsWithDescriptor:(STEventTypeLayout *)layoutDescriptor
                               inContainer:[filter containerForEntity:entity]
                            fromEnumerator:[[NSArray arrayWithObject:entity] objectEnumerator]
                              drawFunction:[layoutDescriptor highlightFunction]];
            return;
    }

    path = [[layoutDescriptor shapeFunction] function];
    highlight = [[layoutDescriptor highlightFunction] function];

    [color set];
#ifdef GNUSTEP
    // big rectangles are not drawn in GNUstep. cut them
    // BUG: only things displayed as rectangles should be cut this way. (links won't work).
    if ([layoutDescriptor drawingType] == PajeStateDrawingType) {
        rect = NSIntersectionRect(rect, cutRect);
    }
#endif
    PSgsave();
    path(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
    highlight();
    PSgrestore();
}

- (void)highlightEntities:(NSArray *)entities
{
    id eEnum, entity;

    if (entities != nil) {
        [self lockFocus];
        
        eEnum = [entities objectEnumerator];
        while ((entity = [eEnum nextObject]) != nil) {
            if ([filter canHighlightEntity:entity]) {
                [self highlightEntity:entity];
            }
        }
        
        [self unlockFocus];
    }
}

- (void)setHighlightedEntity:(PajeEntity *)entity
// highlights entity (and related entities), taking care of unhighlighting previous
{
    if (entity) {
        if (highlightedEntity != entity) {
            if (highlightedEntity) {
                [highlightedEntity release];
                [[self window] restoreCachedImage];
            } else
                [[self window] cacheImageInRect:
                    [self convertRect:[self visibleRect] toView:nil]];
            highlightedEntity = [entity retain];

            [entityNameField setStringValue:[filter descriptionForEntity:highlightedEntity]];

            [self highlightEntities:[[filter relatedEntitiesForEntity:entity] arrayByAddingObject:highlightedEntity]];

            [[self window] flushWindowIfNeeded];
        }
    } else {
        if (highlightedEntity) {
            [highlightedEntity release];
            highlightedEntity = nil;
            [[self window] restoreCachedImage];
            [[self window] flushWindowIfNeeded];
        }
        [entityNameField setStringValue:@""];
    }
}


- (void)drawBackgroundInRect:(NSRect)rect
// draws the background
{
    // draw background
    [backgroundColor set];
    NSRectFill(rect);

    // draw selection background
    if (selectionExists) {
        float selectionStart = TIMEtoX(selectionStartTime);
        float selectionWidth = TIMEtoX(selectionEndTime) - selectionStart;
        NSRect selectionRect = NSMakeRect(selectionStart, NSMinY(rect),
                                          selectionWidth, NSMaxY(rect));
#ifdef GNUSTEP
        // GNUstep can't draw big rects.
        selectionRect = NSIntersectionRect(selectionRect, cutRect);
#endif

        [selectedBackgroundColor set];
        NSRectFill(selectionRect);
        
        /*
        [[NSColor darkGrayColor] set];
        PSmoveto(NSMinX(selectionRect), NSMinY(selectionRect));
        PSlineto(NSMinX(selectionRect), NSMaxY(selectionRect));
        PSmoveto(NSMaxX(selectionRect), NSMinY(selectionRect));
        PSlineto(NSMaxX(selectionRect), NSMaxY(selectionRect));
        PSstroke();
        */
    }
}

void PSStrokeLine(float x, float y, float w, float h);

int CiTR;
BOOL dontdraw;

- (void)drawRect:(NSRect)rect
{
    NSDate *drawStartTime;
    NSDate *drawEndTime;

    if (startTime == nil) return;

[self verifyTimes:self];
    // draws some more pixels, for the graphs that expand their limits (events)
    drawStartTime = XtoTIME(NSMinX(rect) - 5);
    drawEndTime   = XtoTIME(NSMaxX(rect) + 5);

#ifdef GNUSTEP
    // Big rectangles are not drawn by GNUstep. Cut them with cutRect.
    cutRect = NSInsetRect([self visibleRect], -2.0, -2.0);
#endif
    
    NS_DURING

        // set blackground
        [self drawBackgroundInRect:rect];
        
        PSsetlinewidth(1);

        [self drawInstance:[controller rootInstance]
              ofDescriptor:[controller rootLayout]
                    inRect:rect];
    NS_HANDLER
        NSLog(@"Ignoring exception caught inside drawRect: %@", localException);
    NS_ENDHANDLER
}






/*
 * Selection control
 * ------------------------------------------------------------------------
 */

- (BOOL)isPointInSelection:(NSPoint)point
{
    NSDate *pointInTime;
    
    if (!selectionExists) {
        return NO;
    }
    
    pointInTime = XtoTIME(point.x);
    return [pointInTime isLaterThanDate:selectionStartTime]
           && [pointInTime isEarlierThanDate:selectionEndTime];
}

- (void)changeSelectionWithPoint:(NSPoint)point
{
    NSRect redisplayRect;
    NSDate *cursorTime;
    NSRect frameRect = [self frame];

//NSLog(@"sel-last:%@ pt=%@", NSStringFromPoint(selectionLastPoint), //NSStringFromPoint(point));
//NSLog(@"frame=%@", NSStringFromRect(frameRect));
    if (point.x < NSMinX(frameRect)) point.x = NSMinX(frameRect);
    if (point.x > NSMaxX(frameRect)) point.x = NSMaxX(frameRect);
//NSLog(@"pt=%@", NSStringFromPoint(point));

    if (point.x == selectionLastPoint.x)
        return;

    cursorTime = XtoTIME(point.x);
    //[cursorTimeField setDoubleValue:[cursorTime timeIntervalSinceDate:startTime] * timeUnitDivisor];
    [cursorTimeField setDoubleValue:[cursorTime timeIntervalSinceReferenceDate] * timeUnitDivisor];

    redisplayRect = [self visibleRect];
    if (point.x < selectionLastPoint.x) {
        redisplayRect.origin.x = point.x;
        redisplayRect.size.width = selectionLastPoint.x - redisplayRect.origin.x + 1;
    } else {
        redisplayRect.origin.x = selectionLastPoint.x - 2;
        redisplayRect.size.width = point.x - redisplayRect.origin.x + 1;
    }

    [selectionStartTime release];
    [selectionEndTime release];
    if (point.x < selectionAnchorPoint.x) {
        selectionStartTime = [cursorTime retain];
        selectionEndTime = [XtoTIME(selectionAnchorPoint.x) retain];
    } else {
        selectionEndTime = [cursorTime retain];
        selectionStartTime = [XtoTIME(selectionAnchorPoint.x) retain];
    }

    selectionLastPoint = point;

    [self setNeedsDisplayInRect:redisplayRect];
    [self scrollRectToVisible:redisplayRect];
    [controller setSelectionStartTime:selectionStartTime
                              endTime:selectionEndTime];
}

- (void)setNeedsDisplayInSelection
{
    NSRect redisplayRect = [self visibleRect];
    redisplayRect.origin.x = TIMEtoX(selectionStartTime);
    redisplayRect.size.width = TIMEtoX(selectionEndTime) - redisplayRect.origin.x + 1;
    [self setNeedsDisplayInRect:redisplayRect];
}

- (void)selectAll:(id)sender
{
    if (selectionExists) {
        [selectionStartTime release];
        [selectionEndTime release];
    }
    selectionStartTime = [startTime retain];
    selectionEndTime = [endTime retain];
    selectionExists = YES;
    [controller setSelectionStartTime:selectionStartTime
			      endTime:selectionEndTime];
}



/*
 * Dragging control (NSDraggingDestination protocol)
 * ------------------------------------------------------------------------
 */

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];

    [self setHighlightedEntity:[self findEntityAtPoint:point]];
#ifdef GNUSTEP
return NSDragOperationCopy;
#else
//    if (highlightedEntity)
        return NSDragOperationAll;
//    else
//        return NSDragOperationNone;
#endif
}

#ifdef GNUSTEP
// this shouldn't be needed (should be the defaul behaviour of NSView)
- (BOOL) prepareForDragOperation: (id <NSDraggingInfo>)sender
{
    return YES;
}
#endif
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSColor *draggedColor;
    NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];

    draggedColor = [NSColor colorFromPasteboard:[sender draggingPasteboard]];
    if (draggedColor == nil) {
        return NO;
    }

    // if some entity is highlighted, the color has been dropped over it.
    if (highlightedEntity != nil) {
        [filter setColor:draggedColor forEntity:highlightedEntity];
        [self setHighlightedEntity:nil];
    } else {
        // didn't drop on an entity, change background color
        if ([self isPointInSelection:point]) {
            [self setSelectedBackgroundColor:draggedColor];
        } else {
            [self setBackgroundColor:draggedColor];
        }
    }
    return YES;
}



/*
 * Printing
 * ------------------------------------------------------------------------
 */

- (void)endPrologue
/*
 * Spit out the custom PostScript defs.
 */
{
    PSInit();
    [super endPrologue];
}
@end
