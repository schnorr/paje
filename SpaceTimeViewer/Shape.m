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

#include "Shape.h"
#include <math.h>

// 19.ago.2004 BS  creation

static void PSNoShape(NSBezierPath *path, NSRect rect) {}

//
// Shape Functions
//

// these functions should only make a path to be drawn later

// functions for PajeState entities' shapes

static void PSRect(NSBezierPath *path, NSRect rect)
{
    [path appendBezierPathWithRect:rect];
}

// functions for PajeEvent entities' shapes

// x, y is the main point; w, h are the size of the shape

static void PSTriangle(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)+2)];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect)/2, -NSHeight(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
    [path closePath];
}

static void PSFTriangle(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)-2)];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect)/2, NSHeight(rect))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect), 0)];
    [path closePath];
}

static void PSPin(NSBezierPath *path, NSRect rect)
{
    float radius = NSWidth(rect) / 2;
    float yCenter = NSMinY(rect) - (NSHeight(rect) - radius - 2);

    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)+2)];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), yCenter)
                                     radius:radius
                                 startAngle:90.0
                                   endAngle:450.0];
    [path closePath];
}

static void PSFPin(NSBezierPath *path, NSRect rect)
{
    float radius = NSWidth(rect) / 2;
    float yCenter = NSMinY(rect) + (NSHeight(rect) - radius - 2);

    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)-2)];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), yCenter)
                                     radius:radius
                                 startAngle:-90.0
                                   endAngle:270.0];
    [path closePath];
}

static void PSFlag(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)+2)];
    [path relativeLineToPoint:NSMakePoint(0, -(NSHeight(rect) - NSWidth(rect)))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect), 0)];
    [path relativeLineToPoint:NSMakePoint(0, -NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
    [path closePath];
}

static void PSFFlag(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)-2)];
    [path relativeLineToPoint:NSMakePoint(0, NSHeight(rect))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect), 0)];
    [path relativeLineToPoint:NSMakePoint(0, -NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
    [path closePath];
}

static void PSRFlag(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)+2)];
    [path relativeLineToPoint:NSMakePoint(0, -NSHeight(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
    [path relativeLineToPoint:NSMakePoint(0, NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect), 0)];
    [path closePath];
}

static void PSFRFlag(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)-2)];
    [path relativeLineToPoint:NSMakePoint(0, NSHeight(rect) - NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
    [path relativeLineToPoint:NSMakePoint(0, NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect), 0)];
    [path closePath];
}

static void PSSquare(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)+2)];
    [path relativeLineToPoint:NSMakePoint(0, -(NSHeight(rect)-NSWidth(rect)))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect)/2, 0)];
    [path relativeLineToPoint:NSMakePoint(0, -NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
    [path relativeLineToPoint:NSMakePoint(0, NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect)/2, 0)];
    [path closePath];
}

static void PSFSquare(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)-2)];
    [path relativeLineToPoint:NSMakePoint(0, NSHeight(rect) - NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect)/2, 0)];
    [path relativeLineToPoint:NSMakePoint(0, NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(-NSWidth(rect), 0)];
    [path relativeLineToPoint:NSMakePoint(0, -NSWidth(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect)/2, 0)];
    [path closePath];
}

static void PSOut(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                     radius:NSWidth(rect)
                                 startAngle:0
                                   endAngle:360];
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                     radius:1
                                 startAngle:0
                                   endAngle:360];
}

static void PSIn(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                     radius:NSWidth(rect)
                                 startAngle:0
                                   endAngle:360];
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect) - NSWidth(rect)/2)];
    [path relativeLineToPoint:NSMakePoint(0, NSWidth(rect))];
    [path moveToPoint:NSMakePoint(NSMinX(rect) - NSWidth(rect)/2, NSMinY(rect))];
    [path relativeLineToPoint:NSMakePoint(NSWidth(rect), 0)];
}

// functions for PajeLink entities' shapes

// x, y is the starting point; x+w, y+h is the ending point
// functions should not change line width

static void PSLine(NSBezierPath *path, NSRect rect)
{
    [path moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
    [path lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
}

static void PSArrow(NSBezierPath *path, NSRect rect)
{
    float len;
    float ang;

    len = sqrt(NSWidth(rect)*NSWidth(rect) + NSHeight(rect)*NSHeight(rect));
    if (len > 0) {
        NSBezierPath *arrow;
        arrow = [NSBezierPath bezierPath];
        [arrow moveToPoint:NSMakePoint(-7, 0)];
        [arrow lineToPoint:NSMakePoint(-7, 2.5)];
        [arrow lineToPoint:NSMakePoint(0, 0)];
        [arrow lineToPoint:NSMakePoint(-7, -2.5)];
        [arrow lineToPoint:NSMakePoint(-7, 0)];
        ang = atan2(NSHeight(rect), NSWidth(rect)) * 180 / M_PI;
        NSAffineTransform *transform;
        transform = [NSAffineTransform transform];
        [transform translateXBy:NSMaxX(rect) yBy:NSMaxY(rect)];
        [transform rotateByDegrees:ang];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                         radius:1.5
                                     startAngle:ang
                                       endAngle:ang+360];
    }
}

static void PSOpenArrow(NSBezierPath *path, NSRect rect)
{
    float len;
    float ang;

    len = sqrt(NSWidth(rect)*NSWidth(rect) + NSHeight(rect)*NSHeight(rect));
    if (len > 0) {
        NSBezierPath *arrow;
        arrow = [NSBezierPath bezierPath];
        [arrow moveToPoint:NSMakePoint(-7, 3)];
        [arrow lineToPoint:NSMakePoint(0, 0)];
        [arrow lineToPoint:NSMakePoint(-7, -3)];
        [arrow moveToPoint:NSMakePoint(0, 0)];
        ang = atan2(NSHeight(rect), NSWidth(rect)) * 180 / M_PI;
        NSAffineTransform *transform;
        transform = [NSAffineTransform transform];
        [transform translateXBy:NSMaxX(rect) yBy:NSMaxY(rect)];
        [transform rotateByDegrees:ang];
        [arrow transformUsingAffineTransform:transform];
        [path appendBezierPath:arrow];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                         radius:1.5
                                     startAngle:ang
                                       endAngle:ang+360];
    }
}

static void PSDoubleArrow(NSBezierPath *path, NSRect rect)
{
    float len;
    float ang;

    len = sqrt(NSWidth(rect)*NSWidth(rect) + NSHeight(rect)*NSHeight(rect));
    if (len <= 0) {
        return;
    }

    NSBezierPath *arrow;
    arrow = [NSBezierPath bezierPath];
    [arrow moveToPoint:NSMakePoint(-12, 0)];
    [arrow lineToPoint:NSMakePoint(-12, 2.5)];
    [arrow lineToPoint:NSMakePoint(-7, 2.5*2/7)];
    [arrow lineToPoint:NSMakePoint(-7, 2.5)];
    [arrow lineToPoint:NSMakePoint(0, 0)];
    [arrow lineToPoint:NSMakePoint(-7, -2.5)];
    [arrow lineToPoint:NSMakePoint(-7, -2.5*2/7)];
    [arrow lineToPoint:NSMakePoint(-12, -2.5)];
    [arrow lineToPoint:NSMakePoint(-12, 0)];
    ang = atan2(NSHeight(rect), NSWidth(rect)) * 180 / M_PI;
    NSAffineTransform *transform;
    transform = [NSAffineTransform transform];
    [transform translateXBy:NSMaxX(rect) yBy:NSMaxY(rect)];
    [transform rotateByDegrees:ang];
    [arrow transformUsingAffineTransform:transform];
    [path appendBezierPath:arrow];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                     radius:1.5
                                 startAngle:ang
                                   endAngle:ang+360];
    
}

static void PSDiamondArrow(NSBezierPath *path, NSRect rect)
{
    float len;
    float ang;

    len = sqrt(NSWidth(rect)*NSWidth(rect) + NSHeight(rect)*NSHeight(rect));
    if (len <= 0) {
        return;
    }

    NSBezierPath *arrow;
    arrow = [NSBezierPath bezierPath];
    [arrow moveToPoint:NSMakePoint(-14, 0)];
    [arrow lineToPoint:NSMakePoint(-7, 2.5)];
    [arrow lineToPoint:NSMakePoint(0, 0)];
    [arrow lineToPoint:NSMakePoint(-7, -2.5)];
    [arrow lineToPoint:NSMakePoint(-14, 0)];
    ang = atan2(NSHeight(rect), NSWidth(rect)) * 180 / M_PI;
    NSAffineTransform *transform;
    transform = [NSAffineTransform transform];
    [transform translateXBy:NSMaxX(rect) yBy:NSMaxY(rect)];
    [transform rotateByDegrees:ang];
    [arrow transformUsingAffineTransform:transform];
    [path appendBezierPath:arrow];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect))
                                     radius:1.5
                                 startAngle:ang
                                   endAngle:ang+360];
    
}

// functions for PajeVariable entities' shapes


void PSCurveAvg(NSBezierPath *path, NSRect rect)
{
    float xMax = NSMaxX(rect);
    float xAvg = NSMidX(rect);
    float yAvg = NSMidY(rect);
    float yCur = [path currentPoint].y;

    [path curveToPoint:NSMakePoint(xAvg, yAvg)
         controlPoint1:NSMakePoint(xMax, yCur)
         controlPoint2:NSMakePoint(xMax, yAvg)];
}

void PSCurve(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float xMax = NSMaxX(rect);
    float x1 = xMin+2./3*(xMax-xMin);
    float x2 = xMin+1./3*(xMax-xMin);
    float yAvg = NSMidY(rect);
    float yCur = [path currentPoint].y;

    [path curveToPoint:NSMakePoint(xMin, yAvg)
         controlPoint1:NSMakePoint(x1, yCur)
         controlPoint2:NSMakePoint(x2, yAvg)];
}

void PSCurveMin2(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float xMax = NSMaxX(rect);
    float xAvg = NSMidX(rect);
    float yAvg = NSMidY(rect);

    [path curveToPoint:NSMakePoint(xMin, yAvg)
         controlPoint1:NSMakePoint(xMax, yAvg)
         controlPoint2:NSMakePoint(xAvg, yAvg)];
}

void PSCurveMin(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float xAvg = NSMidX(rect);
    float yAvg = NSMidY(rect);
    float yCur = [path currentPoint].y;

    [path curveToPoint:NSMakePoint(xMin, yAvg)
         controlPoint1:NSMakePoint(xAvg, yCur)
         controlPoint2:NSMakePoint(xAvg, yAvg)];
}

void PSBuilding(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float xMax = NSMaxX(rect);
    float yAvg = NSMidY(rect);

    [path lineToPoint:NSMakePoint(xMax, yAvg)];
    [path lineToPoint:NSMakePoint(xMin, yAvg)];
}

void PSMountain(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float yAvg = NSMidY(rect);

    [path lineToPoint:NSMakePoint(xMin, yAvg)];
}

void PSTimes(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float yAvg = NSMidY(rect);

    [path moveToPoint:NSMakePoint(xMin-3, yAvg-3)];
    [path lineToPoint:NSMakePoint(xMin+3, yAvg+3)];
    [path moveToPoint:NSMakePoint(xMin+3, yAvg-3)];
    [path lineToPoint:NSMakePoint(xMin-3, yAvg+3)];
}

void PSCrosses(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float yAvg = NSMidY(rect);

    [path moveToPoint:NSMakePoint(xMin, yAvg-3)];
    [path lineToPoint:NSMakePoint(xMin, yAvg+3)];
    [path moveToPoint:NSMakePoint(xMin+3, yAvg)];
    [path lineToPoint:NSMakePoint(xMin-3, yAvg)];
}

void PSDots(NSBezierPath *path, NSRect rect)
{
    float xMin = NSMinX(rect);
    float yAvg = NSMidY(rect);

    [path appendBezierPathWithOvalInRect:NSMakeRect(xMin-1.5, yAvg-1.5, 3, 3)];
}


// functions for PajeContainer entities' shapes

/* none */

//
// Draw Functions
//

// these functions should draw an already made shape path
// using the current color

static void PSFill(NSBezierPath *path, NSColor *color)
{
    if (color != nil){
        [color set];
        [path fill];
    }
}

static void PSFrame(NSBezierPath *path, NSColor *color)
{
    if (color != nil){
        [color set];
    } else {
        [[NSColor blackColor] set];
    }
    [path stroke];
}

static void PSFillAndFrame(NSBezierPath *path, NSColor *color)
{
    if (color != nil){
        [color set];
        [path fill];
    } else {
        [[NSColor blackColor] set];
    }
    [path stroke];
}


static void PSDashedStroke(NSBezierPath *path, NSColor *color)
{
    float dash[] = {5, 3};
    [path setLineDash:dash count:2 phase:0];
    if (color == nil){
        color = [NSColor blackColor];
    }
    [color set];
    [path stroke];
}

static void PSFillAndFrameBlack(NSBezierPath *path, NSColor *color)
{
    if (color != nil){
        [color set];
        [path fill];
    }
    [[NSColor blackColor] set];
    [path stroke];
}

static void PSFillAndFrameGray(NSBezierPath *path, NSColor *color)
{
    if (color != nil){
        [color set];
        [path fill];
    }
    [[NSColor grayColor] set];
    [path stroke];
}

static void PSFillAndFrameWhite(NSBezierPath *path, NSColor *color)
{
    if (color != nil){
        [color set];
        [path fill];
    }
    [[NSColor whiteColor] set];
    [path stroke];
}


static void PSFrameWhite(NSBezierPath *path, NSColor *color)
{
    [[NSColor whiteColor] set];
    [path stroke];
}


static void PSFillAndDashedStrokeBlack(NSBezierPath *path, NSColor *color)
{
    float dash[] = {5, 3};
    [path setLineDash:dash count:2 phase:0];
    if (color != nil) {
        [color set];
        [path fill];
    }
    [[NSColor blackColor] set];
    [path stroke];
}

static void PS3DStroke(NSBezierPath *path, NSColor *color)
{
    float lineWidth;
    lineWidth = [path lineWidth];
    if (lineWidth < 2) {
        lineWidth = 2;
    }
    if (color == nil) {
        color = [NSColor blackColor];
    }
    [color set];
    [path stroke];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [path setLineWidth:lineWidth + 4];
    [[NSColor colorWithCalibratedWhite:0.2 alpha:0.1] set];
    [transform translateXBy: 4.0 yBy: 6.0];
    [path transformUsingAffineTransform: transform];
    [path stroke];
    [path setLineWidth:lineWidth];
    [path stroke];
    //[path setLineWidth:lineWidth - 2];
    //[path stroke];
    [transform translateXBy: -8.0 yBy: -12.0];
    [path transformUsingAffineTransform: transform];
    [transform translateXBy: 4.0 yBy: 6.0];

    [path setLineWidth:lineWidth - 2];
    [transform translateXBy: 1.0 yBy: 1.0]; // move +1,+1
    [path transformUsingAffineTransform: transform]; // at +1,+1
    [[color shadowWithLevel:0.3] set];
    [path stroke];
    [transform translateXBy: -3.0 yBy: -3.0]; // move -2,-2
    [path transformUsingAffineTransform: transform]; // at -1,-1
    [[color highlightWithLevel:0.3] set];
    [path stroke];
    [transform translateXBy: 3.0 yBy: 3.0]; // move +1,+1
    [path transformUsingAffineTransform: transform]; // at 0,0
    [color set];
    [path stroke];
}

static void PS3DFill(NSBezierPath *path, NSColor *color)
{
    float lineWidth;
    lineWidth = [path lineWidth];
    if (lineWidth < 2) {
        lineWidth = 2;
    }
    if (color == nil) {
        color = [NSColor blackColor];
    }
    [color set];
    [path fill];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [path setLineWidth:lineWidth + 4];
    [[NSColor colorWithCalibratedWhite:0.2 alpha:0.1] set];
    [transform translateXBy: 4.0 yBy: 6.0];
    [path transformUsingAffineTransform: transform];
    [path fill];
    [path setLineWidth:lineWidth];
    [path fill];
    //[path setLineWidth:lineWidth - 2];
    //[path stroke];
    [transform translateXBy: -8.0 yBy: -12.0];
    [path transformUsingAffineTransform: transform];
    [transform translateXBy: 4.0 yBy: 6.0];

    [path setLineWidth:lineWidth - 2];
    [transform translateXBy: 1.0 yBy: 1.0]; // move +1,+1
    [path transformUsingAffineTransform: transform]; // at +1,+1
    [[color shadowWithLevel:0.3] set];
    [path fill];
    [transform translateXBy: -3.0 yBy: -3.0]; // move -2,-2
    [path transformUsingAffineTransform: transform]; // at -1,-1
    [[color highlightWithLevel:0.3] set];
    [path fill];
    [transform translateXBy: 3.0 yBy: 3.0]; // move +1,+1
    [path transformUsingAffineTransform: transform]; // at 0,0
    [color set];
    [path fill];
}

@implementation ShapeFunction

static NSDictionary *stateShapeFunctionsDictionary;
static NSDictionary *eventShapeFunctionsDictionary;
static NSDictionary *linkShapeFunctionsDictionary;
static NSDictionary *variableShapeFunctionsDictionary;
static NSDictionary *containerShapeFunctionsDictionary;


+ (void)initialize
{
#define FUNCTION(n) [self shapeFunctionWithFunction:n name:@#n], @#n
#define EFUNCTION(n, a, b) [self shapeFunctionWithFunction:n \
                                                      name:@#n \
                                              topExtension:a \
                                            rightExtension:b], \
                           @#n
    stateShapeFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        FUNCTION(PSRect),
        nil] retain];
    eventShapeFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        EFUNCTION(PSTriangle, 1, 0.5),
        EFUNCTION(PSFTriangle, 0, 0.5),
        EFUNCTION(PSPin, 1, 0.5),
        EFUNCTION(PSFPin, 0, 0.5),
        EFUNCTION(PSSquare, 1, 0.5),
        EFUNCTION(PSFSquare, 0, 0.5),
        EFUNCTION(PSFlag, 1, 0),
        EFUNCTION(PSFFlag, 0, 0),
        EFUNCTION(PSRFlag, 1, 1),
        EFUNCTION(PSFRFlag, 0, 1),
        EFUNCTION(PSOut, 0.5, 0.5),
        EFUNCTION(PSIn, 0.5, 0.5),
        nil] retain];
    linkShapeFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        FUNCTION(PSArrow),
        FUNCTION(PSOpenArrow),
        FUNCTION(PSDoubleArrow),
        FUNCTION(PSDiamondArrow),
        FUNCTION(PSLine),
        nil] retain];
    variableShapeFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        FUNCTION(PSCurveAvg),
        FUNCTION(PSCurve),
        FUNCTION(PSCurveMin),
        FUNCTION(PSCurveMin2),
        FUNCTION(PSBuilding),
        FUNCTION(PSMountain),
        FUNCTION(PSTimes),
        FUNCTION(PSCrosses),
        FUNCTION(PSDots),
        nil] retain];
    containerShapeFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        FUNCTION(PSNoShape),
        FUNCTION(PSRect),
        nil] retain];
#undef FUNCTION
}

+ (ShapeFunction *)shapeFunctionWithName:(NSString *)n
{
    ShapeFunction *f;
    f = [stateShapeFunctionsDictionary objectForKey:n];
    if (f != nil) return f;
    f = [eventShapeFunctionsDictionary objectForKey:n];
    if (f != nil) return f;
    f = [linkShapeFunctionsDictionary objectForKey:n];
    if (f != nil) return f;
    f = [variableShapeFunctionsDictionary objectForKey:n];
    if (f != nil) return f;
    f = [containerShapeFunctionsDictionary objectForKey:n];
    if (f != nil) return f;
    return [self shapeFunctionWithName:@"PSNoShape"];
}

+ (NSArray *)shapeFunctionsForDrawingType:(PajeDrawingType)drawingType
{
    switch (drawingType) {
    case PajeStateDrawingType:
        return [stateShapeFunctionsDictionary allValues];
    case PajeEventDrawingType:
        return [eventShapeFunctionsDictionary allValues];
    case PajeLinkDrawingType:
        return [linkShapeFunctionsDictionary allValues];
    case PajeVariableDrawingType:
        return [variableShapeFunctionsDictionary allValues];
    case PajeContainerDrawingType:
        return [containerShapeFunctionsDictionary allValues];
    default:
        return [NSArray array];
    }
    return [NSArray array];
}

+ (ShapeFunction *)shapeFunctionWithFunction:(shapefunction *)f
                                        name:(NSString *)n
{
    return [self shapeFunctionWithFunction:f
                                      name:n
                              topExtension:0
                            rightExtension:0];
}

+ (ShapeFunction *)shapeFunctionWithFunction:(shapefunction *)f
                                        name:(NSString *)n
                                topExtension:(float)top
                              rightExtension:(float)right
{
    return [[[self alloc] initWithShapeFunction:f
                                           name:n
                                   topExtension:top
                                 rightExtension:right] autorelease];
}

- (id)initWithShapeFunction:(shapefunction *)f
                       name:(NSString *)n
               topExtension:(float)top
             rightExtension:(float)right
{
    self = [super init];
    function = f;
    name = [n retain];
    topExtension = top;
    rightExtension = right;
    return self;
}

- (shapefunction *)function
{
    return function;
}

- (NSString *)name
{
    return name;
}

- (float)topExtension;
{
    return topExtension;
}

- (float)rightExtension;
{
    return rightExtension;
}
@end

@implementation DrawFunction

NSDictionary *drawFunctionsDictionary;

+ (void)initialize
{
#define FUNCTION(n) [self drawFunctionWithFunction:n name:@#n], @#n
    drawFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        FUNCTION(PSFill),
        FUNCTION(PSFrame),
        FUNCTION(PSFillAndFrame),
        FUNCTION(PSDashedStroke),
        FUNCTION(PSFillAndFrameBlack),
        FUNCTION(PSFillAndFrameGray),
        FUNCTION(PSFillAndFrameWhite),
        FUNCTION(PSFrameWhite),
        FUNCTION(PSFillAndDashedStrokeBlack),
        FUNCTION(PS3DStroke),
        FUNCTION(PS3DFill),
        nil] retain];
#undef FUNCTION
}

+ (DrawFunction *)drawFunctionWithName:(NSString *)n
{
    DrawFunction *function;
    function = [drawFunctionsDictionary objectForKey:n];
    if (function == nil) {
        function = [drawFunctionsDictionary objectForKey:@"PSFill"];
    }
    return function;
}

+ (NSArray *)drawFunctions
{
    return [drawFunctionsDictionary allValues];
}

+ (DrawFunction *)drawFunctionWithFunction:(drawfunction *)f name:(NSString *)n
{
    return [[[self alloc] initWithDrawFunction:f name:n] autorelease];
}

- (id)initWithDrawFunction:(drawfunction *)f name:(NSString *)n
{
    self = [super init];
    function = f;
    name = [n retain];
    return self;
}

- (drawfunction *)function;
{
    return function;
}

- (NSString *)name
{
    return name;
}
@end
