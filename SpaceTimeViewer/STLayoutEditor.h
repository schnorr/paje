/*
    Copyright (c) 2005 Benhur Stein
    
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
#ifndef _STLayoutEditor_h_
#define _STLayoutEditor_h_

// STLayoutEditor
// Controllers for editing many STEntityTypeLayouts

#include <AppKit/AppKit.h>

@class STEntityTypeLayoutController;
@class ShapeImageRep;

@interface STLayoutEditor : NSObject
{
    IBOutlet NSBox *box;
    IBOutlet STEntityTypeLayoutController *controller;
}

- (void)awakeFromNib;
- (void)dealloc;

- (NSView *)view;

- (void)setController:(STEntityTypeLayoutController *)c;
- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;
- (STEntityTypeLayout *)layoutDescriptor;
@end

// Private subclasses

@interface STContainerLayoutEditor : STLayoutEditor
{
    STContainerTypeLayout *layoutDescriptor;
    IBOutlet NSTextField *siblingSeparationField;
    IBOutlet NSTextField *subtypeSeparationField;
    IBOutlet NSTextField *heightForVariablesField;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)siblingSeparationChanged:(id)sender;
- (IBAction)subtypeSeparationChanged:(id)sender;
- (IBAction)heightForVariablesChanged:(id)sender;
@end


@interface STVariableLayoutEditor : STLayoutEditor
{
    STVariableTypeLayout *layoutDescriptor;
    IBOutlet NSTextField *heightField;
    IBOutlet NSTextField *lineWidthField;
    IBOutlet NSTextField *minValueField;
    IBOutlet NSTextField *maxValueField;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)heightChanged:(id)sender;
- (IBAction)lineWidthChanged:(id)sender;
- (IBAction)minValueChanged:(id)sender;
- (IBAction)maxValueChanged:(id)sender;
@end


@interface STShapedLayoutEditor : STLayoutEditor
{
    IBOutlet NSMatrix *shapeMatrix;
    IBOutlet NSMatrix *drawMatrix;
    IBOutlet NSMatrix *highlightMatrix;
}

- (NSRect)rectForImageOfSize:(NSSize)size;

- (ShapeFunction *)selectedShapeFunction;
- (DrawFunction *)selectedDrawFunction;
- (DrawFunction *)selectedHighlightFunction;

- (void)setupShapeMatrix;
- (void)setupDrawMatrices;
- (void)drawShape:(ShapeImageRep *)image;
- (void)drawDraw:(ShapeImageRep *)image;

- (void)recacheAll;

- (IBAction)drawFunctionSelected:(id)sender;
- (IBAction)highlightFunctionSelected:(id)sender;
- (IBAction)shapeSelected:(id)sender;
@end


@interface STLinkLayoutEditor : STShapedLayoutEditor
{
    STLinkTypeLayout *layoutDescriptor;
    IBOutlet NSTextField *lineWidthField;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)lineWidthChanged:(id)sender;
@end


@interface STEventLayoutEditor : STShapedLayoutEditor
{
    STEventTypeLayout *layoutDescriptor;
    IBOutlet NSButton *displayValueSwitch;
    IBOutlet NSTextField *heightField;
    IBOutlet NSTextField *widthField;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)heightChanged:(id)sender;
- (IBAction)widthChanged:(id)sender;
- (IBAction)displayValueChanged:(id)sender;
@end


@interface STStateLayoutEditor : STShapedLayoutEditor
{
    STStateTypeLayout *layoutDescriptor;
    IBOutlet NSButton *displayValueSwitch;
    IBOutlet NSTextField *heightField;
    IBOutlet NSTextField *insetAmountField;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)heightChanged:(id)sender;
- (IBAction)insetAmountChanged:(id)sender;
- (IBAction)displayValueChanged:(id)sender;
@end


#endif
