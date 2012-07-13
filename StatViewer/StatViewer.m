/*
    Copyright (c) 1997-2005 Benhur Stein
    
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

#include "StatViewer.h"

#include "../General/Macros.h"
#include "StatArray.h"

@implementation StatViewer
- initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self != nil) {
        if (![NSBundle loadNibNamed:@"StatViewer" owner:self])
            NSRunAlertPanel(@"StatViewer", @"Couldn't load interface file",
                            nil, nil, nil);
    }
    
    return self;
}

- (void)awakeFromNib
{
    PieCell *cell;
    NSSize cellSize = NSZeroSize;
    NSString *cellSizeString;

    [window setFrameAutosaveName:NSStringFromClass([self class])];

    cellSizeString = [[NSUserDefaults standardUserDefaults]
                               stringForKey:@"StatViewerCellSize"];
    if (cellSizeString != nil) {
        cellSize = NSSizeFromString(cellSizeString);
    }
    if (!NSEqualSizes(cellSize, NSZeroSize)) {
        [matrix setCellSize:cellSize];
    }
    
    cell = [[PieCell alloc] initImageCell:nil];
    [cell setRepresentedObject:nil];
    [cell setDataProvider:self];
    [matrix setPrototype:cell];
    [matrix putCell:cell atRow:0 column:0];
    [matrix setIntercellSpacing:NSMakeSize(0, 0)];
    [cell release];
    
    // notify that we are a Tool
    [self registerTool:self];
}

- (void)dealloc
{
    Assign(startTime, nil);
    Assign(endTime, nil);
    [entityTypeSelector removeAllItems];
    [[matrix cells] makeObjectsPerformSelector:@selector(setRepresentedObject:)
                                    withObject:nil];
//commenting next line fix the bug #3465562. Does it create a memory leak?
//anyways, the memory leak is not that big because StatViewer is allocated and
//deallocated only once per Paje execution
//    [matrix removeFromSuperview];
    [window release];
    [super dealloc];
}

- (NSString *)toolName
{
    return @"Stat Viewer";
}

- (void)activateTool:(id)sender
{
    [window makeKeyAndOrderFront:self];
}

- (void)hierarchyChanged
{
    [self invalidateValues];
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    if ([entityType isEqual:[self selectedEntityType]]) {
        [self invalidateValues];
    }
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    if ([entityType isEqual:[self selectedEntityType]]) {
        [self invalidateCellCaches];
    }
}

- (void)setStartTime:(NSDate *)time
{
    Assign(startTime, time);
}

- (void)setEndTime:(NSDate *)time
{
    Assign(endTime, time);
}

- (void)timeSelectionChanged
{
    [self setStartTime:[self selectionStartTime]];
    [self setEndTime:[self selectionEndTime]];
    [durationField setStringValue:[NSString stringWithFormat:@"%.6f s", [endTime timeIntervalSinceDate:startTime]]];
    [self invalidateValues];
}

- (PajeEntityType *)selectedEntityType
{
    return [[entityTypeSelector selectedItem] representedObject];
}

- (PajeEntityType *)selectedContainerType
{
    return [self containerTypeForType:[self selectedEntityType]];
}

- (void)fillEntityTypeSelector
{
    PajeEntityType *entityType;
    PajeEntityType *selectedEntityType;
    NSEnumerator *typeEnum;

    selectedEntityType = [self selectedEntityType];
    [entityTypeSelector removeAllItems];

    typeEnum = [[self allEntityTypes] objectEnumerator];
    while ((entityType = [typeEnum nextObject]) != nil) {
        PajeDrawingType drawingType;
        
        drawingType = [self drawingTypeForEntityType:entityType];
        if (drawingType == PajeStateDrawingType
            || drawingType == PajeEventDrawingType) {
            NSString *entityTypeDescription;
            
            entityTypeDescription = [self descriptionForEntityType:entityType];

            [entityTypeSelector addItemWithTitle:entityTypeDescription];
            [[entityTypeSelector lastItem] setRepresentedObject:entityType];
            if ([entityType isEqual:selectedEntityType]) {
                [entityTypeSelector selectItemAtIndex:
                                        [entityTypeSelector numberOfItems] - 1];
            }
        }
    }
}

- (void)invalidateValues
{
    int i=0;
    NSEnumerator *nn;
    id container;
    PieCell *cell;

    [self fillEntityTypeSelector];

    nn = [self enumeratorOfContainersTyped:[self selectedContainerType]
                               inContainer:[self rootInstance]];
    while ((container = [nn nextObject]) != nil) {
        [matrix renewRows:i+1 columns:1];

        cell = [matrix cellAtRow:i column:0];
        [cell setRepresentedObject:container];
        [cell setData:nil];
        [cell setDataProvider:self];
        i++;
    }
    [matrix setIntercellSpacing:NSMakeSize(0, 0)];
    [matrix sizeToCells];
    [matrix setNeedsDisplay];
}

- (void)invalidateCellCaches
{
    [[matrix cells] makeObjectsPerformSelector:@selector(discardCache)];
    [matrix setNeedsDisplay];
}

- (BOOL)isEntity:(PajeEntity *)internalEntity
        inEntity:(PajeEntity *)externalEntity
{
    if ([self imbricationLevelForEntity:internalEntity]
        <= [self imbricationLevelForEntity:externalEntity]) {
        return NO;
    }
    if ([[self startTimeForEntity:internalEntity]
        isEarlierThanDate:[self startTimeForEntity:externalEntity]]) {
        return NO;
    }
    if ([[self endTimeForEntity:internalEntity]
        isLaterThanDate:[self endTimeForEntity:externalEntity]]) {
        return NO;
    }
    return YES;
}

- (void)provideDataForCell:(PieCell *)cell
{
    NSEnumerator *enumerator;
    id array;
    PajeContainer *container;
    double minDuration;

    if (startTime == nil) {
        [self setStartTime:[super startTime]];
    }
    if (endTime == nil) {
        [self setEndTime:[super endTime]];
    }

    container = [cell representedObject];
    //NSAssert(container, @"Invalid container in StatViewer cell");
    if (container == nil) return;

    minDuration = [endTime timeIntervalSinceDate:startTime]/500;
    enumerator = [self enumeratorOfEntitiesTyped:[self selectedEntityType]
                                     inContainer:container
                                        fromTime:startTime
                                          toTime:endTime
                                     minDuration:minDuration];

    array = [[StatArray stateArrayWithName:[container name]
                                      type:[self selectedEntityType]
                                 startTime:startTime
                                   endTime:endTime
                                    filter:self
                          entityEnumerator:enumerator] retain];

    [cell setData:array];
    [cell setGraphType:[[graphTypeSelector selectedItem] tag]];
    [array release];
}

- (IBAction)entityTypeSelectorChanged:(id)sender
{
    [self invalidateValues];
}

- (IBAction)graphTypeSelectorChanged:(id)sender
{
    NSInteger rows, cols;
    PieCell *cell;
    int i;

    [matrix getNumberOfRows:&rows columns:&cols];
    for (i=0; i<rows; i++) {
        cell = [matrix cellAtRow:i column:0];
        [cell setGraphType:[[graphTypeSelector selectedItem] tag]];
    }
    [matrix setNeedsDisplay];
}

- (void)changeInitialAngle:(id)sender;
{
    [[matrix cells] makeObjectsPerformSelector:@selector(setInitialAngle:)
                                    withObject:sender];
    [self invalidateCellCaches];
}

- (void)windowDidResize:(NSNotification *)notification
{
        NSSize cellSize;
        NSRect matrixFrame;

        if (![window isVisible]) return;

#if 1
        matrixFrame = [[matrix superview] frame];
        cellSize.width = NSWidth(matrixFrame);
        cellSize.height = 3 * cellSize.width / 5;
        [matrix setCellSize:cellSize];
        [matrix setIntercellSpacing:NSMakeSize(0, 0)];
        [matrix sizeToCells];
        [self invalidateCellCaches];
#else
        [matrix setAutosizesCells:YES];
        [matrix setValidateSize:NO];
#endif
        [matrix setNeedsDisplay];
        cellSize = [matrix cellSize];
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromSize(cellSize) forKey:@"StatViewerCellSize"];
}

- (void)print:(id)sender
{
//    [[NSPrintOperation printOperationWithView:[window contentView]] runOperation]; 
    [window print:sender];
}
@end
