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
#ifndef _HierarchyBrowser_h_
#define _HierarchyBrowser_h_

#include <AppKit/AppKit.h>
#include "PajeFilter.h"

@interface HierarchyBrowser : NSObject
{
    PajeFilter *filter;
    IBOutlet NSBrowser *containerTypesBrowser;
    IBOutlet NSBrowser *containersBrowser;
    IBOutlet NSSplitView *splitView;
    BOOL containersOnly;
}

- (id)initWithFilter:(PajeFilter *)f;

- (NSView *)view;

- (void)setFilter:(PajeFilter *)f;

- (void)setContainersOnly:(BOOL)flag;

- (PajeEntityType *)selectedEntityType;
- (NSArray *)selectedContainers;
- (NSArray *)selectedNames;
- (PajeContainer *)selectedParentContainer;

- (void)refreshLastColumn;

- (void)selectContainers:(NSArray *)containers;

// NSBrowser actions

- (IBAction)containerTypeSelected:(NSBrowser *)sender;
- (IBAction)containerSelected:(NSBrowser *)sender;


// NSBrowser  delegate

- (void)browser:(NSBrowser *)sender createRowsForColumn:(int)column inMatrix:(NSMatrix *)matrix;
- (void)containerTypesBrowser:(NSBrowser *)sender createRowsForColumn:(int)column inMatrix:(NSMatrix *)matrix;
- (void)containersBrowser:(NSBrowser *)sender createRowsForColumn:(int)column inMatrix:(NSMatrix *)matrix;

@end

#endif
