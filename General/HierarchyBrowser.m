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
//

#include "HierarchyBrowser.h"
#include "Macros.h"

@interface NSObject (HierarchyBrowserDelegate)
- (void)hierarchyBrowserContainerSelected:(HierarchyBrowser *)sender;
@end

@implementation HierarchyBrowser

- (id)initWithFilter:(PajeFilter *)f
{
    self = [super init];
    if (self) {
        filter = f; // not retained
        if (![NSBundle loadNibNamed:@"HierarchyBrowser" owner:self])
            NSRunAlertPanel(@"HierarchyBrowser", @"Couldn't load interface file",
                            nil, nil, nil);
    }
    return self;
}

- (void)dealloc
{
    // filter is not retained, do not release it.
    Assign(containerTypesBrowser, nil);
    Assign(containersBrowser, nil);
    Assign(splitView, nil);
    containersOnly = NO;
    [super dealloc];
}

- (void)awakeFromNib
{
    NSWindow *window;
    window = [splitView window];
    [splitView retain];
    [splitView removeFromSuperview];
#ifndef GNUSTEP
    [window release];
#endif
}

- (void)refresh
{
    [containersBrowser loadColumnZero];
    [containerTypesBrowser loadColumnZero];
    //if (selection)
    //    [self select:selection];
}

- (void)refreshLastColumn
{
// FIXME: this is wrong. sometimes it should be lastcolumn-1
    [containersBrowser reloadColumn:[containersBrowser /*selected*/lastColumn]];
}

- (void)setFilter:(id)f
{
    filter = f; // not retained
    [self refresh];
}

- (void)setContainersOnly:(BOOL)flag
{
    containersOnly = flag;
}

- (NSView *)view
{
    return splitView;
}


- (PajeEntityType *)selectedEntityType
{
    PajeEntity *selectedEntity;
    selectedEntity = [[containersBrowser selectedCell] representedObject];
    return [selectedEntity entityType];
}

- (NSArray *)selectedContainers
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *cellEnum = [[containersBrowser selectedCells] objectEnumerator];
    NSCell *cell;
    while ((cell = [cellEnum nextObject]) != nil) {
        [array addObject:[cell representedObject]];
    }
    return array;
}

- (void)selectContainers:(NSArray *)containers
{
// FIXME: this is wrong. sometimes it should be lastcolumn-1
    NSMatrix *matrix = [containersBrowser matrixInColumn:[containersBrowser lastColumn]];
    NSCell *cell;
    int row = 0;

//NSLog(@"matrix=%@ [%@]", matrix, [[matrix cellAtRow:row column:0] representedObject]);
    while ((cell = [matrix cellAtRow:row column:0]) != nil) {
//NSLog(@"select? %@", [cell representedObject]);
        if ([containers indexOfObjectIdenticalTo:[cell representedObject]] != NSNotFound) {
            [matrix selectCellAtRow:row column:0];
        }
        row++;
    }
}

- (NSArray *)selectedNames
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *cellEnum = [[containersBrowser selectedCells] objectEnumerator];
    NSCell *cell;
    while ((cell = [cellEnum nextObject]) != nil) {
        [array addObject:[cell stringValue]];
    }
    return array;
}

- (PajeContainer *)selectedParentContainer
{
    return [[[containersBrowser selectedCell] representedObject] container];
}



- (void)_syncBottom:(id)sender
    // Make visible columns in bottom browser same as top one
{
    int first = [containerTypesBrowser firstVisibleColumn];
    int last = [containerTypesBrowser lastVisibleColumn];
    while ([containersBrowser lastColumn] < last)
        [containersBrowser addColumn];
    if ([containersBrowser firstVisibleColumn] > first)
        [containersBrowser scrollColumnToVisible:first];
    if ([containersBrowser lastVisibleColumn] < last)
        [containersBrowser scrollColumnToVisible:last];
}

- (void)_syncTop:(id)sender
    // Make visible columns in top browser same as bottom one
{
    int first = [containersBrowser firstVisibleColumn];
    int last = [containersBrowser lastVisibleColumn];
//    return;
    if ([containerTypesBrowser firstVisibleColumn] > first)
        [containerTypesBrowser scrollColumnToVisible:first];
    if ([containerTypesBrowser lastVisibleColumn] < last)
        [containerTypesBrowser scrollColumnToVisible:last];
}

// NSBrowser actions

- (IBAction)containerTypeSelected:(NSBrowser *)sender
{
    if ([sender selectedColumn] != 0) {
        if ([containersBrowser selectedCellInColumn:[sender selectedColumn]-1] == nil) {
            [containersBrowser selectRow:0 inColumn:[sender selectedColumn]-1];
        }
    }
    [containersBrowser reloadColumn:[sender selectedColumn]];
    //[containersBrowser reloadColumn:[sender selectedColumn] + 1];
}

- (IBAction)containerSelected:(NSBrowser *)sender
{
    if ([filter respondsToSelector:@selector(hierarchyBrowserContainerSelected:)]) {
        [filter hierarchyBrowserContainerSelected:self];
    }
}



// NSBrowser  delegate

- (void)browser:(NSBrowser *)sender createRowsForColumn:(int)column
       inMatrix:(NSMatrix *)matrix
{
    if (sender == containerTypesBrowser)
        [self containerTypesBrowser:sender createRowsForColumn:column
                           inMatrix:matrix];
    else if (sender == containersBrowser)
        [self containersBrowser:sender createRowsForColumn:column
                       inMatrix:matrix];
    else
        NSDebugLog(@"Unknown browser in HierarchyBrowser");
}

- (void)containersBrowser:(NSBrowser *)sender createRowsForColumn:(int)column inMatrix:(NSMatrix *)matrix
{
    id upperContainer;
    NSEnumerator *containerEnum;
    PajeContainer *container;
    id containerType;
    int row;
    NSBrowserCell *cell;
    BOOL isContainer;

    if (column == 0) {
        upperContainer = [filter rootInstance];
    } else {
        upperContainer = [[sender selectedCellInColumn:column-1] representedObject];
    }

    cell = [containerTypesBrowser selectedCellInColumn:column];
    containerType = [cell representedObject];
    if (containerType == nil)
        return;
    isContainer = ![cell isLeaf];

    if (isContainer || containersOnly) {
        containerEnum = [filter enumeratorOfContainersTyped:containerType
                                                inContainer:upperContainer];
    } else {
        containerEnum = [[filter allNamesForEntityType:containerType] objectEnumerator];
    }
    for (row = 0; (container = [containerEnum nextObject]) != nil; row++) {
        NSBrowserCell *cell;
        [matrix renewRows:row+1 columns:1];
        cell = [matrix cellAtRow:row column:0];
        [cell setRepresentedObject:container];
        [cell setStringValue:[container name]];
        [cell setLeaf:!isContainer];
    }
    if ([containerTypesBrowser lastColumn] < column) {
//        NSLog(@"antesB: %d, %d", [containerTypesBrowser lastColumn], column);
        [containerTypesBrowser addColumn];
//        NSLog(@"depoisB: %d, %d", [containerTypesBrowser lastColumn], column);
    }
}

- (void)containerTypesBrowser:(NSBrowser *)sender
          createRowsForColumn:(int)column
                     inMatrix:(NSMatrix *)matrix
{
    int rows;
    NSEnumerator *typeEnum;
    PajeEntityType *containerType;
    PajeEntityType *entityType;
    
    if (column == 0) {
        containerType = [filter rootEntityType];
    } else {
        containerType = [[sender selectedCellInColumn:column-1]
                                 representedObject];
    }
    rows=0;
    typeEnum = [[filter containedTypesForContainerType:containerType] objectEnumerator];
    while ((entityType = [typeEnum nextObject]) != nil) {
        NSBrowserCell *cell;
        BOOL isContainer = [filter isContainerEntityType:entityType];
        if (containersOnly && !isContainer) {
            continue;
        }
        rows++;
        [matrix renewRows:rows columns:1];
        cell = [matrix cellAtRow:rows-1 column:0];
        [cell setRepresentedObject:entityType];
        [cell setStringValue:[entityType name]];
        // FIXME: if containersOnly, containers that do not contain containers
        //        should be leaves
        [cell setLeaf:!isContainer];
    }
}

- (void)browserDidScroll:(NSBrowser *)sender
{
    // one browser scrolled. sync the other one.
    // do delayed performing because visibleColumns are not yet updated when this method is called (at least in OS4.2).
    if (sender == containerTypesBrowser)
        [self _syncBottom:self];//[self performSelector:@selector(_syncBottom:) withObject:self afterDelay:1.0];
    else
        [self _syncTop:self];//[self performSelector:@selector(_syncTop:) withObject:self afterDelay:1.0];
}
@end
