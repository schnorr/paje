/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
#include "STEntityTypeLayoutController.h"

#include "STEntityTypeLayout.h"
#include "DrawView.h"
#include "../General/Macros.h"

@interface ShapeImageRep : NSCustomImageRep
{
    id function;
}
- (id)function;
- (void)setFunction:(id)f;
@end
@implementation ShapeImageRep
- (void)dealloc
{
    Assign(function, nil);
    [super dealloc];
}

- (id)function
{
    return function;
}

- (void)setFunction:(id)f
{
    Assign(function, f);
}
@end



@implementation STLayoutEditor
- (void)awakeFromNib
{
    [box retain];
}

- (void)dealloc
{
    [box release];
    [super dealloc];
}

- (NSView *)view
{
    return box;
}

- (void)setController:(STEntityTypeLayoutController *)c
{
    controller = c;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)d
{
    [self _subclassResponsibility:_cmd];
}

- (STEntityTypeLayout *)layoutDescriptor
{
    [self _subclassResponsibility:_cmd];
    return nil;
}
@end


@implementation STContainerLayoutEditor

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STContainerTypeLayout class]]);
    layoutDescriptor = (STContainerTypeLayout *)descriptor;
    
    [siblingSeparationField setFloatValue:[layoutDescriptor siblingSeparation]];
    [siblingSeparationStepper setFloatValue:[layoutDescriptor siblingSeparation]];
    [subtypeSeparationField setFloatValue:[layoutDescriptor subtypeSeparation]];
    [subtypeSeparationStepper setFloatValue:[layoutDescriptor subtypeSeparation]];
    [heightForVariablesField setFloatValue:[layoutDescriptor heightForVariables]];
    [heightForVariablesStepper setFloatValue:[layoutDescriptor heightForVariables]];
}

- (IBAction)siblingSeparationChanged:(id)sender
{
    [layoutDescriptor setSiblingSeparation:[sender floatValue]];
    [siblingSeparationField setFloatValue:[layoutDescriptor siblingSeparation]];
    [siblingSeparationStepper setFloatValue:[layoutDescriptor siblingSeparation]];
    [controller layoutEdited];
}

- (IBAction)subtypeSeparationChanged:(id)sender
{
    [layoutDescriptor setSubtypeSeparation:[sender floatValue]];
    [subtypeSeparationField setFloatValue:[layoutDescriptor subtypeSeparation]];
    [subtypeSeparationStepper setFloatValue:[layoutDescriptor subtypeSeparation]];
    [controller layoutEdited];
}

- (IBAction)heightForVariablesChanged:(id)sender
{
    [layoutDescriptor setHeightForVariables:[sender floatValue]];
    [heightForVariablesField setFloatValue:[layoutDescriptor heightForVariables]];
    [heightForVariablesStepper setFloatValue:[layoutDescriptor heightForVariables]];
    [controller layoutEdited];
}
@end



@implementation STVariableLayoutEditor
- (STEntityTypeLayout *)layoutDescriptor
{
    return layoutDescriptor;
}


- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STVariableTypeLayout class]]);
    layoutDescriptor = (STVariableTypeLayout *)descriptor;
    
    [self setupShapeMatrix];
    [self setupDrawMatrices];
    [lineWidthField setFloatValue:[layoutDescriptor lineWidth]];
    [lineWidthStepper setFloatValue:[layoutDescriptor lineWidth]];
    [showMinMaxSwitch  setState:[layoutDescriptor showMinMax]];
}

- (IBAction)lineWidthChanged:(id)sender
{
    [layoutDescriptor setLineWidth:[sender floatValue]];
    [lineWidthField setFloatValue:[layoutDescriptor lineWidth]];
    [lineWidthStepper setFloatValue:[layoutDescriptor lineWidth]];
    [controller layoutEdited];
}

- (IBAction)showMinMaxChanged:(id)sender
{
    [layoutDescriptor setShowMinMax:[sender state]];
    [controller layoutEdited];
}

- (NSRect)rectForImageOfSize:(NSSize)size
{
    return NSMakeRect(0, 0, size.width, size.height);
}


- (void)drawShape:(ShapeImageRep *)image
{
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSRect rect;
    NSBezierPath *path;

    pathFunction = [(ShapeFunction *)[image function] function];
    drawFunction = [[self selectedDrawFunction] function];
    if (drawFunction == NULL) {
        drawFunction = [[DrawFunction drawFunctionWithName:@"PSFillAndFrameBlack"] function];
    }

    rect = [self rectForImageOfSize:[image size]];

    path = [NSBezierPath bezierPath];
    //pathFunction(path, rect);
    [path moveToPoint:NSMakePoint(NSMaxX(rect)+5, NSMidY(rect))];
    pathFunction(path, NSMakeRect(40, 15, 10, 0));
    pathFunction(path, NSMakeRect(30, 15, 10, 0));
    pathFunction(path, NSMakeRect(20, 10, 10, 0));
    pathFunction(path, NSMakeRect(15, 30, 5, 0));
    pathFunction(path, NSMakeRect(3, 10, 12, 0));
    pathFunction(path, NSMakeRect(-10, 10, 13, 0));
    //[path moveToPoint:NSMakePoint(0,0)];
    //[path lineToPoint:NSMakePoint(10,20)];
    //[self flipPath:path height:[image size].height];
    drawFunction(path, [NSColor brownColor]);
}

- (void)drawDraw:(ShapeImageRep *)image
{
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSRect rect;
    NSBezierPath *path;

    pathFunction = [[self selectedShapeFunction] function];
    drawFunction = [(DrawFunction *)[image function] function];
    if (pathFunction == NULL) {
        pathFunction = [[ShapeFunction shapeFunctionWithName:@"PSRect"] function];
    }

    rect = [self rectForImageOfSize:[image size]];

    path = [NSBezierPath bezierPath];
    //pathFunction(path, rect);
    [path moveToPoint:NSMakePoint(NSMaxX(rect), NSMidY(rect))];
    pathFunction(path, NSMakeRect(40, 15, 10, 0));
    pathFunction(path, NSMakeRect(30, 15, 10, 0));
    pathFunction(path, NSMakeRect(20, 10, 10, 0));
    pathFunction(path, NSMakeRect(15, 30, 5, 0));
    pathFunction(path, NSMakeRect(3, 10, 12, 0));
    pathFunction(path, NSMakeRect(-10, 10, 13, 0));
    //[path moveToPoint:NSMakePoint(0,0)];
    //[path lineToPoint:NSMakePoint(10,20)];
    //[self flipPath:path height:[image size].height];
    drawFunction(path, [[NSColor brownColor] highlightWithLevel:.2]);
}


@end


@implementation STShapedLayoutEditor

- (NSRect)rectForImageOfSize:(NSSize)size
{
    [self _subclassResponsibility:_cmd];
    return NSZeroRect;
}

- (ShapeFunction *)selectedShapeFunction
{
    return [(NSCell *)[shapeMatrix selectedCell] representedObject];
}

- (DrawFunction *)selectedDrawFunction
{
    return [(NSCell *)[drawMatrix selectedCell] representedObject];
}

- (void)setupShapeMatrix
{
    ShapeImageRep *imageRep;
    NSImage *image;
    NSSize size = [shapeMatrix cellSize];
    int col = 0;
    STEntityTypeLayout *layoutDescriptor;
    NSEnumerator *shapeFunctionsEnumerator;
    ShapeFunction *shapeFunction;
    ShapeFunction *selectedShapeFunction;
    NSArray *shapeFunctions;

    layoutDescriptor = [self layoutDescriptor];
    selectedShapeFunction = [layoutDescriptor shapeFunction];
    
    shapeFunctions = [ShapeFunction shapeFunctionsForDrawingType:
                                             [layoutDescriptor drawingType]];
    
    [shapeMatrix renewRows:1 columns:[shapeFunctions count]];
    shapeFunctionsEnumerator = [shapeFunctions objectEnumerator];
    while ((shapeFunction = [shapeFunctionsEnumerator nextObject]) != nil) {
        NSButtonCell *cell;
        imageRep = [[[ShapeImageRep alloc]
                            initWithDrawSelector:@selector(drawShape:)
                                        delegate:self] autorelease];
        [imageRep setFunction:shapeFunction];
        image = [[[NSImage allocWithZone:[self zone]]
                                    initWithSize:size] autorelease];
#ifdef GNUSTEP
	[imageRep setSize:size];
#endif
        [image addRepresentation:imageRep];
        [image setBackgroundColor:[NSColor clearColor]];
        cell = [shapeMatrix cellAtRow:0 column:col];
        [cell setImage:image];
        [cell setRepresentedObject:shapeFunction];
        [cell setButtonType:NSOnOffButton];
        if (selectedShapeFunction == shapeFunction) {
            [shapeMatrix selectCellAtRow:0 column:col];
        }
        col++;
    }
    [shapeMatrix sizeToCells];
#ifdef GNUSTEP
    // GNUSTEP BUG: when a view becomes smaller, superview is not redisplayed
    [shapeMatrix setNeedsDisplay:YES];
#endif
}

- (void)setupDrawMatrices
{
    ShapeImageRep *imageRep;
    NSImage *image;
    NSSize size = [drawMatrix cellSize];
    STEntityTypeLayout *layoutDescriptor;
    NSArray *drawFunctions;
    NSEnumerator *drawFunctionsEnumerator;
    DrawFunction *drawFunction;
    DrawFunction *selectedDrawFunction;
    int col = 0;

    layoutDescriptor = [self layoutDescriptor];
    selectedDrawFunction = [layoutDescriptor drawFunction];
    
    drawFunctions = [DrawFunction drawFunctions];
    
    [drawMatrix renewRows:1 columns:[drawFunctions count]];
    
    drawFunctionsEnumerator = [drawFunctions objectEnumerator];
    while ((drawFunction = [drawFunctionsEnumerator nextObject]) != nil) {
        NSButtonCell *drawCell;
        imageRep = [[[ShapeImageRep alloc]
                                initWithDrawSelector:@selector(drawDraw:)
                                            delegate:self] autorelease];
        [imageRep setFunction:drawFunction];
        image = [NSImage allocWithZone:[self zone]];
        [[image initWithSize:size] autorelease];
#ifdef GNUSTEP
	[imageRep setSize:size];
#endif
        [image addRepresentation:imageRep];
        [image setBackgroundColor:[NSColor clearColor]];
        drawCell = [drawMatrix cellAtRow:0 column:col];
        [drawCell setImage:image];
        [drawCell setRepresentedObject:drawFunction];
        [drawCell setButtonType:NSOnOffButton];
        if (selectedDrawFunction == drawFunction) {
            [drawMatrix selectCellAtRow:0 column:col];
        }
        col++;
    }
    [drawMatrix sizeToCells];
    
#ifdef GNUSTEP
    [drawMatrix setNeedsDisplay:YES];
#endif
}

- (void)flipPath:(NSBezierPath *)path height:(float)height
{
    NSAffineTransform *transform;

    transform = [NSAffineTransform transform];
    [transform translateXBy:0 yBy:height];
    [transform scaleXBy:1 yBy:-1];
    [path transformUsingAffineTransform:transform];
}

- (void)drawShape:(ShapeImageRep *)image
{
    STEntityTypeLayout *layoutDescriptor;
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSRect rect;
    NSBezierPath *path;

    layoutDescriptor = [self layoutDescriptor];

    pathFunction = [(ShapeFunction *)[image function] function];
    drawFunction = [[self selectedDrawFunction] function];
    if (drawFunction == NULL) {
        drawFunction = [[DrawFunction drawFunctionWithName:@"PSFillAndFrameBlack"] function];
    }

    rect = [self rectForImageOfSize:[image size]];

    path = [NSBezierPath bezierPath];
    pathFunction(path, rect);
    [self flipPath:path height:[image size].height];
    drawFunction(path, [NSColor brownColor]);
}

- (void)drawDraw:(ShapeImageRep *)image
{
    STEntityTypeLayout *layoutDescriptor;
    shapefunction *pathFunction;
    drawfunction *drawFunction;
    NSRect rect;
    NSBezierPath *path;

    layoutDescriptor = [self layoutDescriptor];

    pathFunction = [[self selectedShapeFunction] function];
    drawFunction = [(DrawFunction *)[image function] function];
    if (pathFunction == NULL) {
        pathFunction = [[ShapeFunction shapeFunctionWithName:@"PSRect"] function];
    }

    rect = [self rectForImageOfSize:[image size]];

    path = [NSBezierPath bezierPath];
    pathFunction(path, rect);
    [self flipPath:path height:[image size].height];
    drawFunction(path, [[NSColor brownColor] highlightWithLevel:.2]);
}


- (void)recacheAll
{
    int i, count, x;

    [shapeMatrix getNumberOfRows:&x columns:&count];
    for (i=0; i<count; i++)
        [[[shapeMatrix cellAtRow:0 column:i] image] recache];
    [shapeMatrix setNeedsDisplay:YES];
    [drawMatrix getNumberOfRows:&x columns:&count];
    for (i=0; i<count; i++)
        [[[drawMatrix cellAtRow:0 column:i] image] recache];
    [drawMatrix setNeedsDisplay:YES];

    [controller layoutEdited];
}

- (IBAction)drawFunctionSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self layoutDescriptor];
    [layoutDescriptor setDrawFunction:[self selectedDrawFunction]];

    [self recacheAll];
}

- (IBAction)shapeSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self layoutDescriptor];
    [layoutDescriptor setShapeFunction:[self selectedShapeFunction]];

    [self recacheAll];
}
@end



@implementation STLinkLayoutEditor

- (STEntityTypeLayout *)layoutDescriptor
{
    return layoutDescriptor;
}

- (NSRect)rectForImageOfSize:(NSSize)size
{
    return NSMakeRect(5, 5, size.width - 10, size.height - 10);
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STLinkTypeLayout class]]);
    layoutDescriptor = (STLinkTypeLayout *)descriptor;
    
    [self setupShapeMatrix];
    [self setupDrawMatrices];
    [lineWidthField setFloatValue:[layoutDescriptor lineWidth]];
    [lineWidthStepper setFloatValue:[layoutDescriptor lineWidth]];
}

- (IBAction)lineWidthChanged:(id)sender
{
    [layoutDescriptor setLineWidth:[sender floatValue]];
    [lineWidthField setFloatValue:[layoutDescriptor lineWidth]];
    [lineWidthStepper setFloatValue:[layoutDescriptor lineWidth]];
    [self recacheAll];
}
@end




@implementation STEventLayoutEditor

- (STEntityTypeLayout *)layoutDescriptor
{
    return layoutDescriptor;
}

- (NSRect)rectForImageOfSize:(NSSize)size
{
    float x, y, w, h;

    x = size.width / 2;
    w = [layoutDescriptor width];
    h = [layoutDescriptor height];
    y = size.height / 2;

    return NSMakeRect(x, y, w, h);
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STEventTypeLayout class]]);
    layoutDescriptor = (STEventTypeLayout *)descriptor;
    
    [self setupShapeMatrix];
    [self setupDrawMatrices];
    [heightField setFloatValue:[layoutDescriptor height]];
    [heightStepper setFloatValue:[layoutDescriptor height]];
    [widthField setFloatValue:[layoutDescriptor width]];
    [widthStepper setFloatValue:[layoutDescriptor width]];
    [displayValueSwitch setState:[layoutDescriptor drawsName]];
}

- (IBAction)heightChanged:(id)sender
{
    [layoutDescriptor setHeight:[sender floatValue]];
    [heightField setFloatValue:[layoutDescriptor height]];
    [heightStepper setFloatValue:[layoutDescriptor height]];
    [self recacheAll];
}

- (IBAction)widthChanged:(id)sender
{
    [layoutDescriptor setWidth:[sender floatValue]];
    [widthField setFloatValue:[layoutDescriptor width]];
    [widthStepper setFloatValue:[layoutDescriptor width]];
    [self recacheAll];
}

- (IBAction)displayValueChanged:(id)sender
{
    [layoutDescriptor setDrawsName:[sender state]];
    [self recacheAll];
}
@end



@implementation STStateLayoutEditor

- (STEntityTypeLayout *)layoutDescriptor
{
    return layoutDescriptor;
}

- (NSRect)rectForImageOfSize:(NSSize)size
{
    float x, y, w, h;

    x = 5;
    w = size.width - 10;
    h = [layoutDescriptor height];
    if (h > size.height - 10) {
        h = size.height - 10;
    }
    y = size.height / 2 - h / 2;

    return NSMakeRect(x, y, w, h);
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STStateTypeLayout class]]);
    layoutDescriptor = (STStateTypeLayout *)descriptor;
    
    [self setupShapeMatrix];
    [self setupDrawMatrices];
    [heightField setFloatValue:[layoutDescriptor height]];
    [heightStepper setFloatValue:[layoutDescriptor height]];
    [insetAmountField setFloatValue:[layoutDescriptor insetAmount]];
    [insetAmountStepper setFloatValue:[layoutDescriptor insetAmount]];
    [displayValueSwitch setState:[layoutDescriptor drawsName]];
}

- (IBAction)heightChanged:(id)sender
{
    [layoutDescriptor setHeight:[sender floatValue]];
    [heightField setFloatValue:[layoutDescriptor height]];
    [heightStepper setFloatValue:[layoutDescriptor height]];
    [self recacheAll];
}

- (IBAction)insetAmountChanged:(id)sender
{
    [layoutDescriptor setInsetAmount:[sender floatValue]];
    [insetAmountField setFloatValue:[layoutDescriptor insetAmount]];
    [insetAmountStepper setFloatValue:[layoutDescriptor insetAmount]];
    [self recacheAll];
}

- (IBAction)displayValueChanged:(id)sender
{
    [layoutDescriptor setDrawsName:[sender state]];
    [self recacheAll];
}
@end

