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
//#include <AppKit/AppKit.h>
#if defined(GNUSTEP)
#include <AppKit/PSOperators.h>
#endif
#if defined(__APPLE__)
#include "PSOperators.h"
#endif
#if defined(NeXT)
#import <AppKit/psopsOpenStep.h>	// For PS and DPS function prototypes
#import "drawline.h" // for pswraps
#endif
#include <math.h>

// 19.ago.2004 BS  creation


void emptydrawfunction(void) {}
void PSNoShape(float x, float y, float w, float h) {}

//
// Shape Functions
//

// these functions should only make a path to be drawn later

// functions for PajeState entities' shapes

void PSRect(float x, float y, float w, float h)
{
//    PSnewpath();
    PSmoveto(x, y);
    PSrlineto(w, 0);
    PSrlineto(0, h);
    PSrlineto(-w, 0);
//    PSclosepath();
PSrlineto(0, -h);
}

// functions for PajeEvent entities' shapes

// x, y is the main point; w, h are the size of the shape

void PSTriangle(float x, float y, float w, float h)
{
    PSnewpath();
    PSmoveto(x, y+2);
    PSrlineto(w/2, -(h));
    PSrlineto(-w, 0);
    PSclosepath();
//PSrlineto(w/2, -h);
}

void PSFTriangle(float x, float y, float w, float h)
{
    PSnewpath();
    PSmoveto(x, y-2);
    PSrlineto(w/2, h);
    PSrlineto(-w, 0);
    PSclosepath();
//PSrlineto(w/2, -h);
}

void PSPin(float x, float y, float w, float h)
{
    PSmoveto(x, y + 2);
    PSarc(x, y - (h - w/2 - 2), w/2, 90, 450);
}

void PSFPin(float x, float y, float w, float h)
{
    PSmoveto(x, y - 2);
    PSarc(x, y + (h - w/2 - 2), w/2, -90, 270);
}

void PSFlag(float x, float y, float w, float h)
{
    PSmoveto(x, y + 2);
    PSrlineto(0, -h);
    PSrlineto(-w, 0);
    PSrlineto(0, w);
    PSrlineto(w, 0);
}

void PSFFlag(float x, float y, float w, float h)
{
    PSmoveto(x, y - 2);
    PSrlineto(0, h);
    PSrlineto(-w, 0);
    PSrlineto(0, -w);
    PSrlineto(w, 0);
}

void PSRFlag(float x, float y, float w, float h)
{
    PSmoveto(x, y + 2);
    PSrlineto(0, -h);
    PSrlineto(w, 0);
    PSrlineto(0, w);
    PSrlineto(-w, 0);
}

void PSFRFlag(float x, float y, float w, float h)
{
    PSmoveto(x, y - 2);
    PSrlineto(0, h);
    PSrlineto(w, 0);
    PSrlineto(0, -w);
    PSrlineto(-w, 0);
}

void PSOut(float x, float y, float w, float h)
{
    //PSsetlinewidth(2);
    PSmoveto(x + w, y);
    PSarc(x, y, w, 0, 360);
    PSmoveto(x, y);
    PSarc(x, y, 1, 0, 360);
}

void PSIn(float x, float y, float w, float h)
{
    //PSsetlinewidth(2);
    PSmoveto(x + w, y);
    PSarc(x, y, w, 0, 360);
    PSmoveto(x, y - w/2);
    PSrlineto(0, w);
    PSmoveto(x - w/2, y);
    PSrlineto(w, 0);
}

// functions for PajeLink entities' shapes

// x, y is the starting point; x+w, y+h is the ending point
// functions should not change line width

void PSLine(float x, float y, float w, float h)
{
    PSmoveto(x, y);
    PSrlineto(w, h);
}

void PSArrow(float x, float y, float w, float h)
{
    float len;
    float ang;
    float bx, by;
    
    len = sqrt(w*w + h*h);
    if (len) {
        ang = atan2(h, w) * 180 / M_PI;
        PSnewpath();
        PSmoveto(x, y);
        PSrotate(ang);
        PScurrentpoint(&bx, &by);
        PSrmoveto(len - 7, 0);
        PSrlineto(0, 2.5);
        PSrlineto(7, -2.5);
        PSrlineto(-7, -2.5);
        PSclosepath();
        PSarc(bx, by, 1.5, 0, 360);
    }
}

void PSArrow2(float x, float y, float w, float h)
{
    float len;
    float ang;

    len = sqrt(w*w + h*h);
    if (len) {
        ang = atan2(h, w) * 180 / M_PI;
        PSmoveto(x, y);
        PSrotate(ang);
        PSrlineto(0, 2);
        PSrlineto(0, -4);
        PSrlineto(0, 2);	
        PSrlineto(len - 7, 0);
        PSrlineto(0, 2.5);
        PSrlineto(7, -2.5);
        PSrlineto(-7, -2.5);
        PSrlineto(0, 2.5);
    }
}

// functions for PajeContainer entities' shapes

/* none */

//
// Draw Functions
//

// these functions should draw an already made shape path
// using the current color

void PSDashedStroke(void)
{
    float dash[] = {2, 1};
    //PSsetlinewidth(2);
    PSsetdash(dash, 2, 0);
    PSstroke();
}

void PSFillAndFrameBlack(void)
{
    PSgsave();
    PSfill();
    PSgrestore();
    PSsetgray(0);
    PSstroke();
}

void PSFillAndFrameGray(void)
{
    PSgsave();
    PSfill();
    PSgrestore();
    PSsetgray(0.5);
    PSstroke();
}

void PSFillAndFrameWhite(void)
{
    PSgsave();
    PSfill();
    PSgrestore();
    PSsetgray(1);
    PSstroke();
}


void PSFrameWhite(void)
{
    PSsetgray(1);
    PSstroke();
}


void PSFillAndDashedStrokeBlack(void)
{
    float dash[] = {2, 1};
    PSgsave();
    PSfill();
    PSgrestore();
    PSsetgray(0);
    //PSsetlinewidth(2);
    PSsetdash(dash, 2, 0);
    PSstroke();
}


@implementation ShapeFunction

NSDictionary *stateShapeFunctionsDictionary;
NSDictionary *eventShapeFunctionsDictionary;
NSDictionary *linkShapeFunctionsDictionary;
NSDictionary *containerShapeFunctionsDictionary;


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
        EFUNCTION(PSFlag, 1, 0),
        EFUNCTION(PSFFlag, 0, 0),
        EFUNCTION(PSRFlag, 1, 1),
        EFUNCTION(PSFRFlag, 0, 1),
        EFUNCTION(PSOut, 0.5, 0.5),
        EFUNCTION(PSIn, 0.5, 0.5),
        nil] retain];
    linkShapeFunctionsDictionary = [[NSDictionary dictionaryWithObjectsAndKeys:
        FUNCTION(PSArrow),
        FUNCTION(PSArrow2),
        FUNCTION(PSLine),
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
    case PajeContainerDrawingType:
        return [containerShapeFunctionsDictionary allValues];
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
        FUNCTION(PSfill),
        FUNCTION(PSstroke),
        FUNCTION(PSDashedStroke),
        FUNCTION(PSFillAndFrameBlack),
        FUNCTION(PSFillAndFrameGray),
        FUNCTION(PSFillAndFrameWhite),
        FUNCTION(PSFrameWhite),
        FUNCTION(PSFillAndDashedStrokeBlack),
        nil] retain];
#undef FUNCTION
}

+ (DrawFunction *)drawFunctionWithName:(NSString *)n
{
    return [drawFunctionsDictionary objectForKey:n];
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
