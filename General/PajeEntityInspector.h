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
#ifndef _PajeEntityInspector_h_
#define _PajeEntityInspector_h_

#include <AppKit/AppKit.h>
#include "PajeEntity.h"
#include "PajeContainer.h"
#include "PajeFilter.h"

@interface PajeEntityInspector : NSObject
{
    PajeEntity *inspectedEntity;
    PajeFilter *filter;

    IBOutlet NSWindow *inspectionWindow;
    IBOutlet NSTextField *nameField;
    IBOutlet NSColorWell *colorField;
    IBOutlet NSButton *reuseButton;
    IBOutlet NSButton *filterButton;
    IBOutlet NSBox *fieldBox;
    IBOutlet NSBox *relatedEntitiesBox;
    IBOutlet NSMatrix *relatedEntitiesMatrix;
    
    IBOutlet NSBox *fileBox;
    IBOutlet NSTextField *filenameField;
    IBOutlet NSTextField *lineNumberField;

    NSMutableSet *nonDisplayedFields;

    float top;
    float bottom;
}

+ (PajeEntityInspector *)inspector;

- (id)init;
- (void)dealloc;

- (void)addSubview:(NSView *)view atBottom:(BOOL)atBottom;
- (void)addLastSubview:(NSView *)view;
- (NSBox *)boxWithTitle:(NSString *)boxTitle
            fieldTitles:(NSArray *)titles
            fieldValues:(NSArray *)values;
- (NSBox *)boxWithTitle:(NSString *)boxTitle
            fieldTitles:(NSArray *)titles
             fieldNames:(NSArray *)names;
- (void)addLocalFields;
- (void)addBoxForContainer:(PajeContainer *)container
             upToContainer:(PajeContainer *)upto
                 withTitle:(NSString *)title;

- (BOOL)isReusable;
- (void)setReusable:(BOOL)reuse;

- (void)inspectEntity:(id<PajeEntity>)entity
           withFilter:(PajeFilter *)filter;

- (IBAction)colorChanged:(id)sender;
- (IBAction)entityClicked:(id)sender;

- (IBAction)showSource:(id)sender;
- (IBAction)filterEntityName:(id)sender;
@end

#endif
