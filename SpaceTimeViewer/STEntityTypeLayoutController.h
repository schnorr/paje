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
#ifndef _STEntityTypeLayoutController_h_
#define _STEntityTypeLayoutController_h_

// STEntityTypeLayoutController
// Controls the iteraction between the EntityTypeLayout GUI and 
// EntityTypeLayout objects

#include <AppKit/AppKit.h>

#include "STController.h"

@interface STEntityTypeLayoutController : NSObject
{
    IBOutlet NSPopUpButton *entityTypePopUp;
    IBOutlet NSMatrix *shapeMatrix;
    IBOutlet NSMatrix *drawMatrix;
    IBOutlet NSMatrix *highlightMatrix;
    IBOutlet NSForm *fields;
    IBOutlet NSForm *otherFields;
    IBOutlet NSBox *otherFieldsBox;
    IBOutlet NSStepper *stepper0;
    IBOutlet NSStepper *stepper1;
    IBOutlet NSButton *switch0;
    IBOutlet NSBox *matrices;
    STController *delegate;
}
- (IBAction)entityTypeSelected:(id)sender;
- (IBAction)shapeSelected:(id)sender;
- (IBAction)drawFunctionSelected:(id)sender;
- (IBAction)highlightFunctionSelected:(id)sender;
- (IBAction)sizeChanged:(id)sender;
- (IBAction)stepperChanged:(id)sender;
- (IBAction)switchChanged:(id)sender;

- (id)initWithDelegate:(id)del;
- (void)setupPopUpWithLayoutDescriptors:(NSArray *)set;
- (void)setupShapeMatrix;
- (void)setupDrawMatrixes;
//- (void)drawShape:(MyCustomImageRep *)image;
//- (void)drawDraw:(MyCustomImageRep *)image;
@end

#endif
