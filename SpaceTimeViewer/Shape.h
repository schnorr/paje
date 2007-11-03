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
#ifndef _Shape_h_
#define _Shape_h_

// Paje
// ----
// Shape.h
// shape drawing functions and classes.

// 19.ago.2004 BS  creation


#include <Foundation/Foundation.h>
#include "../General/Protocols.h"

typedef     void (shapefunction)(NSBezierPath *path, NSRect rect);
typedef     void (drawfunction)(NSBezierPath *path, NSColor *color);

@interface ShapeFunction : NSObject
{
    shapefunction *function;
    NSString *name;
    float topExtension;
    float rightExtension;
} 

+ (ShapeFunction *)shapeFunctionWithName:(NSString *)name;
+ (NSArray *)shapeFunctionsForDrawingType:(PajeDrawingType)drawingType;
+ (ShapeFunction *)shapeFunctionWithFunction:(shapefunction *)f
                                        name:(NSString *)n;
+ (ShapeFunction *)shapeFunctionWithFunction:(shapefunction *)f
                                        name:(NSString *)n
                                topExtension:(float)top
                              rightExtension:(float)right;

- (id)initWithShapeFunction:(shapefunction *)f
                       name:(NSString *)n
               topExtension:(float)top
             rightExtension:(float)right;

- (shapefunction *)function;
- (NSString *)name;
- (float)topExtension;
- (float)rightExtension;

@end

@interface DrawFunction : NSObject
{
    drawfunction *function;
    NSString *name;
    BOOL fillsPath;
} 

+ (DrawFunction *)drawFunctionWithName:(NSString *)name;
+ (NSArray *)drawFunctions;

+ (DrawFunction *)drawFunctionWithFunction:(drawfunction *)f
                                      name:(NSString *)n
                                 fillsPath:(BOOL)fills;

- (id)initWithDrawFunction:(drawfunction *)f name:(NSString *)n fillsPath:(BOOL)fills;

- (drawfunction *)function;
- (NSString *)name;
- (BOOL)fillsPath;

@end

#endif
