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
#ifndef _STController_h_
#define _STController_h_

#include <AppKit/AppKit.h>
#include "HierarchyRuler.h"

@class DrawView;
@class HierarchyRuler;
@class STEntityTypeLayoutController;

@interface STController: PajeFilter <PajeTool>
{
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSWindow *window;
    IBOutlet DrawView *drawView;
    NSRulerView *timeRuler;
    HierarchyRuler *hierarchyRuler;
    STEntityTypeLayoutController *layoutController;

    NSMutableDictionary *layoutDescriptors; // STEntityTypeLayout[entity type]
    
}
- (id)initWithController:(PajeTraceController *)c;
- (void)awakeFromNib;
- (void)print:(id)sender;

- (NSArray *)layoutDescriptors;
- (STEntityTypeLayout *)descriptorForEntityType:(PajeEntityType *)entityType;
- (STContainerTypeLayout *)rootLayout;

- (void)changedTimeScale;

@end

@interface STController (Positioning)
- (NSRect)calcRectOfInstance:(id)entity
          ofLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor
                        minY:(float)minY;
- (NSRect)calcRectOfAllInstancesOfLayoutDescriptor:(STContainerTypeLayout *)layoutDescriptor
                                       inContainer:(PajeContainer *)container
                                              minY:(float)minY;

@end

#endif
