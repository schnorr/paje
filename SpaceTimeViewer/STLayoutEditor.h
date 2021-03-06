/*
    Copyright (c) 2005 Benhur Stein
    
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
    IBOutlet NSStepper *siblingSeparationStepper;
    IBOutlet NSTextField *subtypeSeparationField;
    IBOutlet NSStepper *subtypeSeparationStepper;
    IBOutlet NSTextField *heightForVariablesField;
    IBOutlet NSStepper *heightForVariablesStepper;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)siblingSeparationChanged:(id)sender;
- (IBAction)subtypeSeparationChanged:(id)sender;
- (IBAction)heightForVariablesChanged:(id)sender;
@end


@interface STShapedLayoutEditor : STLayoutEditor
{
    IBOutlet NSMatrix *shapeMatrix;
    IBOutlet NSMatrix *drawMatrix;
}

- (NSRect)rectForImageOfSize:(NSSize)size;

- (ShapeFunction *)selectedShapeFunction;
- (DrawFunction *)selectedDrawFunction;

- (void)setupShapeMatrix;
- (void)setupDrawMatrices;
- (void)drawShape:(ShapeImageRep *)image;
- (void)drawDraw:(ShapeImageRep *)image;

- (void)recacheAll;

- (IBAction)drawFunctionSelected:(id)sender;
- (IBAction)shapeSelected:(id)sender;
@end


@interface STLinkLayoutEditor : STShapedLayoutEditor
{
    STLinkTypeLayout *layoutDescriptor;
    IBOutlet NSTextField *lineWidthField;
    IBOutlet NSStepper *lineWidthStepper;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)lineWidthChanged:(id)sender;
@end


@interface STEventLayoutEditor : STShapedLayoutEditor
{
    STEventTypeLayout *layoutDescriptor;
    IBOutlet NSButton *displayValueSwitch;
    IBOutlet NSTextField *heightField;
    IBOutlet NSStepper *heightStepper;
    IBOutlet NSTextField *widthField;
    IBOutlet NSStepper *widthStepper;
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
    IBOutlet NSStepper *heightStepper;
    IBOutlet NSTextField *insetAmountField;
    IBOutlet NSStepper *insetAmountStepper;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)heightChanged:(id)sender;
- (IBAction)insetAmountChanged:(id)sender;
- (IBAction)displayValueChanged:(id)sender;
@end



@interface STVariableLayoutEditor : STShapedLayoutEditor
{
    STVariableTypeLayout *layoutDescriptor;
    IBOutlet NSTextField *lineWidthField;
    IBOutlet NSStepper *lineWidthStepper;
    IBOutlet NSButton *showMinMaxSwitch;
}

- (void)setLayoutDescriptor:(STEntityTypeLayout *)descriptor;

- (IBAction)lineWidthChanged:(id)sender;
- (IBAction)showMinMaxChanged:(id)sender;
@end



#endif
