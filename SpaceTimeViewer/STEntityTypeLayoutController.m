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

@implementation STEntityTypeLayoutController

- (id)initWithDelegate:(id)del
{
    self = [super init];
    if (self) {
        delegate = del;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)toolName
{
    return @"Shapes & sizes";
}

- (void)activateTool:(id)sender
/* sent by PajeController when the user selects this Tool */
{
    if (!shapeMatrix) {
        if (![NSBundle loadNibNamed:@"STEntityTypeLayout" owner:self]) {
            NSRunAlertPanel(@"EntityTypeLayoutController",
                            @"Couldn't load interface file",
                            nil, nil, nil);
            return;
        }
        [self setupPopUpWithLayoutDescriptors:[delegate layoutDescriptors]];
        [self setupShapeMatrix];
        [self setupDrawMatrixes];
    }
    
    [[shapeMatrix window] orderFront:self];
}

- (void)setupPopUpWithLayoutDescriptors:(NSArray *)set
{
    NSEnumerator *enumerator;
    STEntityTypeLayout *item;
    
    [entityTypePopUp removeAllItems];

    enumerator = [set objectEnumerator];
    while ((item = [enumerator nextObject]) != nil) {
        if ([item isContainer]) continue;
        [entityTypePopUp addItemWithTitle:[item description]];
        [[entityTypePopUp lastItem] setRepresentedObject:item];
    }
    enumerator = [set objectEnumerator];
    while ((item = [enumerator nextObject]) != nil) {
        if (![item isContainer]) continue;
        [entityTypePopUp addItemWithTitle:[item description]];
        [[entityTypePopUp lastItem] setRepresentedObject:item];
    }

    [entityTypePopUp selectItemAtIndex:0];
    [self entityTypeSelected:self];
}

- (STEntityTypeLayout *)selectedLayoutDescriptor
{
    return [[entityTypePopUp selectedItem] representedObject];
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

    layoutDescriptor = [self selectedLayoutDescriptor];
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
    [shapeMatrix setEnabled:![layoutDescriptor isContainer]];
#ifdef GNUSTEP
    // GNUSTEP BUG: when a view becomes smaller, superview is not redisplayed
    [[shapeMatrix window] display];
#endif
}

- (void)setupDrawMatrixes
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

    layoutDescriptor = [self selectedLayoutDescriptor];
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
    [drawMatrix setEnabled:![layoutDescriptor isContainer]];
    [highlightMatrix setEnabled:![layoutDescriptor isContainer]];
    
#ifdef GNUSTEP
    [[drawMatrix window] display];
#endif
    //BUG - pourquoi est-ce que matrixes sont detruites?
    [drawMatrix retain];
    [highlightMatrix retain];
    [shapeMatrix retain];
}

- (NSRect)rectForDescriptor:(STEntityTypeLayout *)layoutDescriptor
               inRectOfSize:(NSSize)size
{
    PajeDrawingType drawingType;
    float x, y, w, h;

    drawingType = [layoutDescriptor drawingType];
    switch (drawingType) {
        case PajeEventDrawingType :
            w = [(STEventTypeLayout *)layoutDescriptor width];
            h = [layoutDescriptor height];
            x = size.width / 2;
            y = size.height / 2 - h / 2;
            break;
        case PajeVariableDrawingType :
        case PajeStateDrawingType :
            w = size.width - 10;
            h = [layoutDescriptor height];
            x = 5;
            y = size.height / 2 - h / 2;
            break;
        case PajeLinkDrawingType :
            x = 5;
            y = 5;
            w = size.width - 10;
            h = size.height - 10;
            break;
        case PajeContainerDrawingType :
            return;
        default:
            NSAssert1(0, @"Invalid drawing type %d", drawingType);
    }
    return NSMakeRect(x, y, w, h);
}

- (void)drawShape:(ShapeImageRep *)image
{
    STEntityTypeLayout *layoutDescriptor;
    shapefunction *path;
    drawfunction *draw;
    NSRect rect;

    layoutDescriptor = [self selectedLayoutDescriptor];

    path = [(ShapeFunction *)[image function] function];
    draw = [[self selectedDrawFunction] function];
    if (draw == NULL) {
        draw = [[DrawFunction drawFunctionWithName:@"PSFillAndFrameBlack"] function];
    }

    rect = [self rectForDescriptor:layoutDescriptor
                      inRectOfSize:[image size]];

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

    layoutDescriptor = [self selectedLayoutDescriptor];

    path = [[self selectedShapeFunction] function];
    draw = [(DrawFunction *)[image function] function];
    if (path == NULL) {
        path = [[ShapeFunction shapeFunctionWithName:@"PSRect"] function];
    }

    rect = [self rectForDescriptor:layoutDescriptor
                      inRectOfSize:[image size]];

    [[[NSColor brownColor] highlightWithLevel:.2] set];
    PSgsave();
    path(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
    draw();
    PSgrestore();
}

/*
- (void)drawExampleView:(NSCustomImageRep *)image
{
    NSRect exrect, exrects[] = {
        NSMakeRect(5,0,30,20),
        NSMakeRect(35,0,50,-10),
        NSMakeRect(85,0,35,30),
    };
    NSColor *colors[] = {
        [NSColor brownColor],
        [NSColor orangeColor],
        [NSColor redColor],
        [NSColor blueColor],
    };
    int ci=0, cc = sizeof(colors)/sizeof(colors[0]);
    STEntityTypeLayout *entityDescriptor;
    PajeDrawingType drawingType;
    NSRect rect;
    shapefunction *path;
    drawfunction *draw;
    drawfunction *high;
    int i, count, r, cr;
    float y = 5;

    count = [entityTypePopUp numberOfItems];

    for (i=0; i<count; i++) {
        entityDescriptor = [[entityTypePopUp itemAtIndex:i] representedObject];
        drawingType = [entityDescriptor drawingType];
        path = [[entityDescriptor shapeFunction] function];
        draw = [[entityDescriptor drawFunction] function];
        high = [[entityDescriptor highlightFunction] function];

        cr = sizeof(exrects) / sizeof(exrects[0]);
        for (r=0; r<cr; r++) {
            exrect = exrects[r];

            exrect.origin.y = y;

            rect = [entityDescriptor drawingRect];

            switch (drawingType) {
                case PajeEventDrawingType :
                    rect.origin.x += exrect.origin.x;
                    rect.origin.y += exrect.origin.y;
                    break;
                case PajeVariableDrawingType :
                case PajeStateDrawingType :
                    rect.origin.x += exrect.origin.x;
                    rect.origin.y += exrect.origin.y;
                    rect.size.width += exrect.size.width;
                    break;
                case PajeLinkDrawingType :
                    rect.origin.x += exrect.origin.x;
                    rect.origin.y += exrect.origin.y;
                    rect.size.width += exrect.size.width;
                    rect.size.height += exrect.size.height;
                    break;
                case PajeContainerDrawingType :
                    rect.origin.x += exrect.origin.x;
                    rect.origin.y += exrect.origin.y;
                    rect.size.width += exrect.size.width;
                    break;
                default:
                    NSAssert1(0, @"Invalid drawing type %d", drawingType);
            }

            PSgsave();
            ci++;
            if (ci >= cc) ci = 0;
            [colors[ci] set];
            path(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
            if (r == 1) high();
            else draw();
            PSgrestore();
        }
        y += NSMaxY([entityDescriptor drawingRect]);
    }
}
*/

- (void)recacheAll
{
    int i, count, x;
    STEntityTypeLayout *layoutDescriptor;

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

    layoutDescriptor = [self selectedLayoutDescriptor];
    [delegate dataChangedForEntityType:[layoutDescriptor entityType]];
}

- (void)drawFunctionSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self selectedLayoutDescriptor];
    [layoutDescriptor setDrawFunction:[self selectedDrawFunction]];

    [self recacheAll];
}

- (void)entityTypeSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;
    PajeDrawingType drawingType;
    NSString *field1Name;
    NSString *field2Name;
    float field1Value;
    float field2Value;
    NSFormCell *field1;
    NSFormCell *field2;

    layoutDescriptor = [self selectedLayoutDescriptor];
    drawingType = [layoutDescriptor drawingType];
    [matrices setHidden:NO];
    [switch0 setHidden:YES];
    [otherFieldsBox setHidden:YES];

    switch (drawingType) {
        case PajeEventDrawingType :
            field1Name = @"Height:";
            field2Name = @"Width:";
            field1Value = [(STEventTypeLayout *)layoutDescriptor height];
            field2Value = [(STEventTypeLayout *)layoutDescriptor width];
            [switch0 setHidden:NO];
            [switch0 setState:[layoutDescriptor drawsName]];
            break;
        case PajeStateDrawingType :
            field1Name = @"Height:";
            field2Name = @"Inset:";
            field1Value = [(STStateTypeLayout *)layoutDescriptor height];
            field2Value = [(STStateTypeLayout *)layoutDescriptor insetAmount];
            [switch0 setHidden:NO];
            [switch0 setState:[layoutDescriptor drawsName]];
            break;
        case PajeLinkDrawingType :
            field1Name = @"Line width:";
            field2Name = nil;
            field1Value = [(STLinkTypeLayout *)layoutDescriptor lineWidth];
            field2Value = 0;
            break;
        case PajeVariableDrawingType :
            field1Name = nil;
            //field1Name = @"Height:";
            //field2Name = @"Line width:";
            //field1Value = [(STVariableTypeLayout *)layoutDescriptor height];
            //field2Value = [(STVariableTypeLayout *)layoutDescriptor lineWidth];
            [[otherFields cellAtIndex:0] setFloatValue:
                    [(STVariableTypeLayout *)layoutDescriptor height]];
            [[otherFields cellAtIndex:1] setFloatValue:
                    [(STVariableTypeLayout *)layoutDescriptor lineWidth]];
            [[otherFields cellAtIndex:2] setFloatValue:
                    [(STVariableTypeLayout *)layoutDescriptor minValue]];
            [[otherFields cellAtIndex:3] setFloatValue:
                    [(STVariableTypeLayout *)layoutDescriptor maxValue]];

            [matrices setHidden:YES];
            [otherFieldsBox setHidden:NO];
            break;
        case PajeContainerDrawingType :
            field1Name = @"Container Separation:";
            field2Name = @"Subtype Separation:";
            field1Value = [(STContainerTypeLayout *)layoutDescriptor
                                     siblingSeparation];
            field2Value = [(STContainerTypeLayout *)layoutDescriptor
                                     subtypeSeparation];
            [matrices setHidden:YES];
            break;
        default:
            NSAssert1(0, @"Invalid drawing type %d", drawingType);
    }
    if (field1Name != nil) {
    field1 = [fields cellAtIndex:0];
    [field1 setTitle:field1Name];
    [field1 setFloatValue:field1Value];
    [stepper0 setFloatValue:field1Value];
    if (field2Name != nil) {
        if ([fields numberOfRows] < 2) {
            [fields addEntry:@""];
        }
        field2 = [fields cellAtIndex:1];
        [field2 setTitle:field2Name];
        [field2 setFloatValue:field2Value];
        [stepper1 setHidden:NO];
        [stepper1 setFloatValue:field2Value];
        [[stepper1 superview] setNeedsDisplay:YES];
    } else {
        if ([fields numberOfRows] > 1) {
            [fields removeEntryAtIndex:1];
        }
        [stepper1 setHidden:YES];
        [[stepper1 superview] setNeedsDisplay:YES];
    }
    }
    
    [self setupShapeMatrix];
    [self setupDrawMatrixes];
//    [self recacheAll];
}

- (void)highlightFunctionSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [[entityTypePopUp selectedItem] representedObject];
    [layoutDescriptor setHighlightFunction:[self selectedHighlightFunction]];
    [self recacheAll];
}

- (void)shapeSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self selectedLayoutDescriptor];
    [layoutDescriptor setShapeFunction:[self selectedShapeFunction]];

    [self recacheAll];
}

- (void)sizeChanged:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;
    PajeDrawingType drawingType;
    float field1Value;
    float field2Value;

    layoutDescriptor = [self selectedLayoutDescriptor];
    drawingType = [layoutDescriptor drawingType];

    field1Value = [[fields cellAtIndex:0] floatValue];
    field2Value = [[fields cellAtIndex:1] floatValue];
    [stepper0 setFloatValue:field1Value];
    [stepper1 setFloatValue:field2Value];

    switch (drawingType) {
        case PajeEventDrawingType :
            [(STEventTypeLayout *)layoutDescriptor setHeight:field1Value];
            [(STEventTypeLayout *)layoutDescriptor setWidth:field2Value];
            break;
        case PajeStateDrawingType :
            [(STStateTypeLayout *)layoutDescriptor setHeight:field1Value];
            [(STStateTypeLayout *)layoutDescriptor setInsetAmount:field2Value];
            break;
        case PajeLinkDrawingType :
            [(STLinkTypeLayout *)layoutDescriptor setLineWidth:field1Value];
            break;
        case PajeVariableDrawingType :
            //[(STVariableTypeLayout *)layoutDescriptor setHeight:field1Value];
            //[(STVariableTypeLayout *)layoutDescriptor setLineWidth:field2Value];
            [(STVariableTypeLayout *)layoutDescriptor setHeight:
                    [[otherFields cellAtIndex:0] floatValue]];
            [(STVariableTypeLayout *)layoutDescriptor setLineWidth:
                    [[otherFields cellAtIndex:1] floatValue]];
            [(STVariableTypeLayout *)layoutDescriptor setMinValue:
                    [[otherFields cellAtIndex:2] floatValue]];
            [(STVariableTypeLayout *)layoutDescriptor setMaxValue:
                    [[otherFields cellAtIndex:3] floatValue]];
            break;
        case PajeContainerDrawingType :
            [(STContainerTypeLayout *)layoutDescriptor
                                 setSiblingSeparation:field1Value];
            [(STContainerTypeLayout *)layoutDescriptor
                                 setSubtypeSeparation:field2Value];
            break;
        default:
            NSAssert1(0, @"Invalid drawing type %d", drawingType);
    }

    [self recacheAll];
}

- (IBAction)stepperChanged:(id)sender
{
    if (sender == stepper0) {
        [[fields cellAtIndex:0] takeIntValueFrom:sender];
        [self sizeChanged:self];
    } else if (sender == stepper1) {
        [[fields cellAtIndex:1] takeIntValueFrom:sender];
        [self sizeChanged:self];
    }
}

- (IBAction)switchChanged:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;

    layoutDescriptor = [self selectedLayoutDescriptor];
    
    [layoutDescriptor setDrawsName:[sender intValue] != 0];
    [delegate dataChangedForEntityType:[layoutDescriptor entityType]];
}
@end
