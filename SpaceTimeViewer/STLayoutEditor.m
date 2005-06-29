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
#include <AppKit/PSOperators.h>

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
    [self subclassResponsibility:_cmd];
}

- (STEntityTypeLayout *)layoutDescriptor
{
    [self subclassResponsibility:_cmd];
    return nil;
}
@end


@implementation STContainerLayoutEditor

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STContainerTypeLayout class]]);
    layoutDescriptor = (STContainerTypeLayout *)descriptor;
    
    [siblingSeparationField setFloatValue:[layoutDescriptor siblingSeparation]];
    [subtypeSeparationField setFloatValue:[layoutDescriptor subtypeSeparation]];
    [heightForVariablesField setFloatValue:[layoutDescriptor heightForVariables]];
}

- (IBAction)siblingSeparationChanged:(id)sender
{
    [layoutDescriptor setSiblingSeparation:[sender floatValue]];
    [controller layoutEdited];
}

- (IBAction)subtypeSeparationChanged:(id)sender
{
    [layoutDescriptor setSubtypeSeparation:[sender floatValue]];
    [controller layoutEdited];
}

- (IBAction)heightForVariablesChanged:(id)sender
{
    [layoutDescriptor setHeightForVariables:[sender floatValue]];
    [controller layoutEdited];
}
@end



@implementation STVariableLayoutEditor

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STVariableTypeLayout class]]);
    layoutDescriptor = (STVariableTypeLayout *)descriptor;
    
    [heightField    setFloatValue:[layoutDescriptor height]];
    [lineWidthField setFloatValue:[layoutDescriptor lineWidth]];
    [minValueField  setFloatValue:[layoutDescriptor minValue]];
    [maxValueField  setFloatValue:[layoutDescriptor maxValue]];
}

- (IBAction)heightChanged:(id)sender
{
    [layoutDescriptor setHeight:[sender floatValue]];
    [controller layoutEdited];
}

- (IBAction)lineWidthChanged:(id)sender
{
    [layoutDescriptor setLineWidth:[sender floatValue]];
    [controller layoutEdited];
}

- (IBAction)minValueChanged:(id)sender
{
    [layoutDescriptor setMinValue:[sender floatValue]];
    [controller layoutEdited];
}

- (IBAction)maxValueChanged:(id)sender
{
    [layoutDescriptor setMaxValue:[sender floatValue]];
    [controller layoutEdited];
}
@end


@implementation STShapedLayoutEditor

- (NSRect)rectForImageOfSize:(NSSize)size
{
    [self subclassResponsibility:_cmd];
    return NSZeroRect;
}

- (ShapeFunction *)selectedShapeFunction
{
    return [[shapeMatrix selectedCell] representedObject];
}

- (DrawFunction *)selectedDrawFunction
{
    return [[drawMatrix selectedCell] representedObject];
}

- (DrawFunction *)selectedHighlightFunction
{
    return [[highlightMatrix selectedCell] representedObject];
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
        image = [NSImage allocWithZone:[self zone]];
        [[image initWithSize:size] autorelease];
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
    DrawFunction *selectedHighlightFunction;
    int col = 0;

    layoutDescriptor = [self layoutDescriptor];
    selectedDrawFunction = [layoutDescriptor drawFunction];
    selectedHighlightFunction = [layoutDescriptor highlightFunction];
    
    drawFunctions = [DrawFunction drawFunctions];
    
    [drawMatrix renewRows:1 columns:[drawFunctions count]];
    [highlightMatrix renewRows:1 columns:[drawFunctions count]];
    
    drawFunctionsEnumerator = [drawFunctions objectEnumerator];
    while ((drawFunction = [drawFunctionsEnumerator nextObject]) != nil) {
        NSButtonCell *drawCell;
        NSButtonCell *highlightCell;
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
        highlightCell = [highlightMatrix cellAtRow:0 column:col];
        [drawCell setImage:image];
        [highlightCell setImage:image];
        [drawCell setRepresentedObject:drawFunction];
        [highlightCell setRepresentedObject:drawFunction];
        [drawCell setButtonType:NSOnOffButton];
        [highlightCell setButtonType:NSOnOffButton];
        if (selectedDrawFunction == drawFunction) {
            [drawMatrix selectCellAtRow:0 column:col];
        }
        if (selectedHighlightFunction == drawFunction) {
            [highlightMatrix selectCellAtRow:0 column:col];
        }
        col++;
    }
    [drawMatrix sizeToCells];
    [highlightMatrix sizeToCells];
    
#ifdef GNUSTEP
    [drawMatrix setNeedsDisplay:YES];
    [highlightMatrix setNeedsDisplay:YES];
#endif
}

- (void)drawShape:(ShapeImageRep *)image
{
    STEntityTypeLayout *layoutDescriptor;
    shapefunction *path;
    drawfunction *draw;
    NSRect rect;

    layoutDescriptor = [self layoutDescriptor];

    path = [(ShapeFunction *)[image function] function];
    draw = [[self selectedDrawFunction] function];
    if (draw == NULL) {
        draw = [[DrawFunction drawFunctionWithName:@"PSFillAndFrameBlack"] function];
    }

    rect = [self rectForImageOfSize:[image size]];

    [[NSColor brownColor] set];
    PSgsave();
    path(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
    draw();
    PSgrestore();
}

- (void)drawDraw:(ShapeImageRep *)image
{
    STEntityTypeLayout *layoutDescriptor;
    shapefunction *path;
    drawfunction *draw;
    NSRect rect;

    layoutDescriptor = [self layoutDescriptor];

    path = [[self selectedShapeFunction] function];
    draw = [(DrawFunction *)[image function] function];
    if (path == NULL) {
        path = [[ShapeFunction shapeFunctionWithName:@"PSRect"] function];
    }

    rect = [self rectForImageOfSize:[image size]];

    [[[NSColor brownColor] highlightWithLevel:.2] set];
    PSgsave();
    path(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
    draw();
    PSgrestore();
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
    [highlightMatrix getNumberOfRows:&x columns:&count];
    for (i=0; i<count; i++)
        [[[highlightMatrix cellAtRow:0 column:i] image] recache];
    [highlightMatrix setNeedsDisplay:YES];

    [controller layoutEdited];
}

- (IBAction)drawFunctionSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self layoutDescriptor];
    [layoutDescriptor setDrawFunction:[self selectedDrawFunction]];

    [self recacheAll];
}

- (IBAction)highlightFunctionSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self layoutDescriptor];
    [layoutDescriptor setHighlightFunction:[self selectedHighlightFunction]];
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
}

- (IBAction)lineWidthChanged:(id)sender
{
    [layoutDescriptor setLineWidth:[sender floatValue]];
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
    y = size.height / 2 - h / 2;

    return NSMakeRect(x, y, w, h);
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor
{
    NSParameterAssert([descriptor isKindOfClass:[STEventTypeLayout class]]);
    layoutDescriptor = (STEventTypeLayout *)descriptor;
    
    [self setupShapeMatrix];
    [self setupDrawMatrices];
    [heightField setFloatValue:[layoutDescriptor height]];
    [widthField setFloatValue:[layoutDescriptor width]];
    [displayValueSwitch setState:[layoutDescriptor drawsName]];
}

- (IBAction)heightChanged:(id)sender
{
    [layoutDescriptor setHeight:[sender floatValue]];
    [self recacheAll];
}

- (IBAction)widthChanged:(id)sender
{
    [layoutDescriptor setWidth:[sender floatValue]];
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
    if (h > size.height) {
        h = size.height;
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
    [insetAmountField setFloatValue:[layoutDescriptor insetAmount]];
    [displayValueSwitch setState:[layoutDescriptor drawsName]];
}

- (IBAction)heightChanged:(id)sender
{
    [layoutDescriptor setHeight:[sender floatValue]];
    [self recacheAll];
}

- (IBAction)insetAmountChanged:(id)sender
{
    [layoutDescriptor setInsetAmount:[sender floatValue]];
    [self recacheAll];
}

- (IBAction)displayValueChanged:(id)sender
{
    [layoutDescriptor setDrawsName:[sender state]];
    [self recacheAll];
}
@end

