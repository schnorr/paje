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
#ifndef _EntityTypeSelector_h_
#define _EntityTypeSelector_h_

/* EntityTypeSelector.h created by benhur on Sat 14-Jun-1997 */

#include <AppKit/AppKit.h>
#include "../General/FilteredEnumerator.h"
#include "../General/Protocols.h"
#include "../General/PajeFilter.h"

@interface EntityTypeSelector : PajeFilter
{
    NSMutableDictionary *filters;
    NSMutableSet *hiddenEntityTypes;
    IBOutlet NSView *view;
    IBOutlet NSMatrix *matrix;
    IBOutlet NSPopUpButton *entityTypePopUp;
    IBOutlet NSButton *hideButton;
}

- (id)initWithController:(PajeTraceController *)c;
- (void)dealloc;

- (void)setFilterForEntityType:(PajeEntityType *)entityType;

- (PajeEntityType *)selectedEntityType;

// read and write defaults
- (NSMutableSet *)defaultFilterForEntityType:(PajeEntityType *)entityType;
- (void)registerDefaultFilter:(NSSet *)filter
                forEntityType:(PajeEntityType *)entityType;

//
// Handle interface messages
//
- (IBAction)selectAll:(id)sender;
- (IBAction)unselectAll:(id)sender;
- (IBAction)matrixChanged:(id)sender;
- (IBAction)entityPopUpChanged:(id)sender;
- (IBAction)hideButtonClicked:(id)sender;

//
// interact with interface
//
- (void)viewWillBeSelected:(NSView *)view;
- (void)synchronizeMatrix;


//
// methods in Trace for making the filtering
//
- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end;

- (BOOL)isHiddenEntityType:(PajeEntityType*)entityType;

//
// methods to be a dragging destination, as delegate of matrix
// (colors dropped in a cell change the color of the 
// entity type it represents)
//
- (unsigned int)matrix:(NSMatrix *)m draggingUpdated:(id <NSDraggingInfo>)sender;
- (BOOL)matrix:(NSMatrix *)m performDragOperation:(id <NSDraggingInfo>)sender;
- (void)matrix:(NSMatrix *)m draggingExited:(id <NSDraggingInfo>)sender;
// help method for highlighting the destination cell
- (void)highlightCell:(id)cell inMatrix:(NSMatrix *)m;

@end

#endif
