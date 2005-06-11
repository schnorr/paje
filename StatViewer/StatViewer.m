/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
/*
 */

#include "StatViewer.h"

#include "../General/Macros.h"

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
    id cell;
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
    
    // notify that we are a Tool
    [self registerTool:self];
}

- (NSString *)toolName
{
    return @"Stat Viewer";
}

- (void)activateTool:(id)sender
{
    [window makeKeyAndOrderFront:self];
}

- (void)setInputComponent:(PajeComponent *)component
{
    [super setInputComponent:component];
    Assign(filter, component);
}

- (void)hierarchyChanged
{
    [self invalidateValues];
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    [self invalidateValues];
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    [self invalidateValues];
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

    if (!filter) return;

    [self fillEntityTypeSelector];

    nn = [filter enumeratorOfContainersTyped:[self selectedContainerType]
                                 inContainer:[filter rootInstance]];
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
    PajeEntity *entity;
    id array;
    PajeContainer *container;
    NSMutableArray *stack;

    if (!filter) return;

    if (!startTime) [self setStartTime:[filter startTime]];
    if (!endTime) [self setEndTime:[filter endTime]];

    container = [cell representedObject];
    //NSAssert(container, @"Invalid container in StatViewer cell");
    if (container == nil) return;

    array = [[StatArray alloc] initWithName:[filter nameForEntity:container]];
    stack = [NSMutableArray array];

    enumerator = [filter enumeratorOfEntitiesTyped:[self selectedEntityType]
                                       inContainer:container
                                          fromTime:startTime
                                            toTime:endTime];
    enumerator = [[enumerator allObjects] reverseObjectEnumerator];
    while ((entity = [enumerator nextObject]) != nil) {
        StatValue *v;
        double duration;
        NSDate *entityStart;
        NSDate *entityEnd;
        
        entityStart = [self startTimeForEntity:entity];
        entityEnd = [self endTimeForEntity:entity];
        duration = [[endTime earlierDate:entityEnd]
                       timeIntervalSinceDate:[startTime laterDate:entityStart]];
        if (duration == 0) duration = 1; // for events; should be a separate mth
        
        while ([stack count] > 0) {
            PajeEntity *topEntity;
            topEntity = [stack lastObject];
            if ([self isEntity:entity inEntity:topEntity]) {
                v = [StatValue valueWithValue:-duration
                                        color:[filter colorForEntity:topEntity]
                                         name:[filter nameForEntity:topEntity]];
                [array addObject:v];
                break;
            } else {
                [stack removeLastObject];
            }
        }
        [stack addObject:entity];

        v = [StatValue valueWithValue:duration
                                color:[filter colorForEntity:entity]
                                 name:[filter nameForEntity:entity]];
        [array addObject:v];
    }

    [array setSum:[endTime timeIntervalSinceDate:startTime]];
    [cell setData:array];
    [cell setGraphType:[[graphTypeSelector selectedItem] tag]];
    [cell setShowPercent:[[percentSelector selectedCell] tag]];
    [array release];
}

- (IBAction)entityTypeSelectorChanged:(id)sender
{
    [self invalidateValues];
}

- (IBAction)percentSelectorChanged:(id)sender
{
    [self invalidateValues];
}

- (IBAction)graphTypeSelectorChanged:(id)sender
{
    int rows, cols;
    PieCell *cell;
    int i;

    [matrix getNumberOfRows:&rows columns:&cols];
    for (i=0; i<rows; i++) {
        cell = [matrix cellAtRow:i column:0];
        [cell setGraphType:[[graphTypeSelector selectedItem] tag]];
        [cell setShowPercent:[[percentSelector selectedCell] tag]];
    }
    [matrix setNeedsDisplay];
}

- (void)changeInitialAngle:(id)sender;
{
    [[matrix cells] makeObjectsPerformSelector:@selector(setInitialAngle:)
                                    withObject:sender];
    [matrix display];
}

- (void)windowDidResize:(NSNotification *)notification
{
        NSSize cellSize;
        NSRect matrixFrame;

#if 1
        cellSize = [matrix cellSize];
        matrixFrame = [matrix frame];
        cellSize.width = NSWidth(matrixFrame);
        [matrix setCellSize:cellSize];
        [matrix setIntercellSpacing:NSMakeSize(0, 0)];
        [matrix sizeToCells];
        [matrix setNeedsDisplay];
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