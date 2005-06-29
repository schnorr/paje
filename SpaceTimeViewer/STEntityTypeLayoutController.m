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
    if (entityTypePopUp == nil) {
        if (![NSBundle loadNibNamed:@"STEntityTypeLayout" owner:self]) {
            NSRunAlertPanel(@"EntityTypeLayoutController",
                            @"Couldn't load interface file",
                            nil, nil, nil);
            return;
        }
        [self reset];
    }
    
    [[entityTypePopUp window] orderFront:self];
}

- (void)reset
{
    NSEnumerator *enumerator;
    STEntityTypeLayout *item;
    
    [entityTypePopUp removeAllItems];

    enumerator = [[delegate layoutDescriptors] objectEnumerator];
    while ((item = [enumerator nextObject]) != nil) {
        if ([item isContainer]) continue;
        [entityTypePopUp addItemWithTitle:[item description]];
        [[entityTypePopUp lastItem] setRepresentedObject:item];
    }
    enumerator = [[delegate layoutDescriptors] objectEnumerator];
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


- (void)layoutEdited
{
    STEntityTypeLayout *layoutDescriptor;
    layoutDescriptor = [self selectedLayoutDescriptor];
    [delegate dataChangedForEntityType:[layoutDescriptor entityType]];
}

- (void)setView:(NSView *)view
{
    if (currentView == view) {
        return;
    }
    [currentView removeFromSuperview];
    currentView = view;
    [[entityTypePopUp superview] addSubview:currentView];
}


- (void)entityTypeSelected:(id)sender
{
    STEntityTypeLayout *layoutDescriptor;
    PajeDrawingType drawingType;
    STLayoutEditor *layoutEditor;

    layoutDescriptor = [self selectedLayoutDescriptor];
    drawingType = [layoutDescriptor drawingType];

    switch (drawingType) {
        case PajeEventDrawingType :
            layoutEditor = eventEditor;
            break;
        case PajeStateDrawingType :
            layoutEditor = stateEditor;
            break;
        case PajeLinkDrawingType :
            layoutEditor = linkEditor;
            break;
        case PajeVariableDrawingType :
            layoutEditor = variableEditor;
            break;
        case PajeContainerDrawingType :
            layoutEditor = containerEditor;
            break;
        default:
            NSAssert1(0, @"Invalid drawing type %d", drawingType);
    }
    [self setView:[layoutEditor view]];
    [layoutEditor setLayoutDescriptor:layoutDescriptor];
}

@end


