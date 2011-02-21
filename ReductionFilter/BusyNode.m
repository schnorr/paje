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
/* BusyNode.m created by benhur on Fri 27-Feb-1998 */

#include "BusyNode.h"
#include "ReduceEntity.h"
#include "../General/UniqueString.h"
#include "../General/Macros.h"

@implementation BusyNode

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self) {

        // load the interface. it initializes view.
        if (![NSBundle loadNibNamed:@"ReductionFilter" owner:self])
            NSRunAlertPanel(NSStringFromClass([self class]),
                            @"Couldn't load interface file",
                            nil, nil, nil);

        // view is an NSBox. we need its contents.
        view = [[view contentView] retain];
#ifndef GNUSTEP
        [[view window] autorelease];
#endif
        [view removeFromSuperview];

        reduceEntityTypes = [[NSMutableSet alloc] init];
        typesContainingReducedTypes = [[NSMutableDictionary alloc] init];
        [self readDefaults];

//        [self registerFilterWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
//            NSStringFromClass([self class]), @"Name",
//            view, @"View", nil]];
        [self registerFilter:self];
        
    }
    return self;
}

- (NSString *)filterName
{
    return @"Reduction";
}

- (NSView *)filterView
{
    return view;
}

- (void)dealloc
{
    [reduceEntityTypes release];
    [entityTypesDictionary release];
    [typesContainingReducedTypes release];
    [view removeFromSuperview];
    [groupByPopUp removeAllItems];
    [entityTypePopUp removeAllItems];
    //[nameMatrix removeAllItems];
    [entityNamePopUp removeAllItems];
    [view release];
    [super dealloc];
}


- (void)readDefaults
{
    NSString *defaultName;

    defaultName = [NSStringFromClass([self class]) stringByAppendingString:@" ReduceEntityTypes"];
    entityTypesDictionary = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultName] mutableCopy];
    if (entityTypesDictionary == nil) {
        entityTypesDictionary = [[NSMutableDictionary alloc] init];
    }
}

- (void)registerDefaults
{
    NSString *defaultName;

    defaultName = [NSStringFromClass([self class]) stringByAppendingString:@" ReduceEntityTypes"];

    [[NSUserDefaults standardUserDefaults] setObject:entityTypesDictionary
                                              forKey:defaultName];
}

//TODO treat -dataChangedForEntityType:
//- (void)dataChangedForEntityType:(id)entityType
//{
//    [self hierarchyChanged];
//}

- (void)hierarchyChanged
{
    [self calcEntityTypes];
    [self calcEntityNamePopUp];
    [self calcEntityTypePopUp];
    [self calcGroupPopUp];
    [self calcReduceModePopUp];
    [self refreshMatrix];

    [super hierarchyChanged];
}

- (void)calcEntityTypes
{
    NSEnumerator *filterEnum;
    NSDictionary *filter;
    ReduceEntityType *entityType;

    [reduceEntityTypes removeAllObjects];
    filterEnum = [entityTypesDictionary objectEnumerator];
    while ((filter = [filterEnum nextObject]) != nil) {
        entityType = [ReduceEntityType typeFromDictionary:filter component:self];
        if (entityType != nil) {
            [reduceEntityTypes addObject:entityType];
            [self addToHierarchy:entityType];
        }
    }
}

- (void)calcEntityNamePopUp
{
    NSEnumerator *typeEnumerator;
    ReduceEntityType *selectedType;
    ReduceEntityType *type;
    int ct = 0;

    selectedType = [[entityNamePopUp selectedItem] representedObject];
    [entityNamePopUp removeAllItems];
    typeEnumerator = [reduceEntityTypes objectEnumerator];
    while ((type = [typeEnumerator nextObject]) != nil) {
        [entityNamePopUp addItemWithTitle:[type description]];
        [[entityNamePopUp itemWithTitle:[type description]]
                                    setRepresentedObject:type];
	ct++;
    }
    if (ct == 0) {
        [entityNamePopUp addItemWithTitle:@"None"];
        [entityNamePopUp setEnabled:NO];
    } else {
        [entityNamePopUp setEnabled:YES];
    }
    if (selectedType != nil)
        [entityNamePopUp selectItemWithTitle:[selectedType description]];
    if ([entityNamePopUp selectedItem] == nil
        && [entityNamePopUp numberOfItems] > 0)
        [entityNamePopUp selectItemAtIndex:0];
    if ([entityNamePopUp selectedItem] != nil)
        [entityNameField setStringValue:[entityNamePopUp titleOfSelectedItem]];
}

- (void)calcEntityTypePopUp
{
    NSEnumerator *subenum;
    PajeEntityType *entityType;
    ReduceEntityType *type;
    int ct = 0;

    type = [[entityNamePopUp selectedItem] representedObject];
    [entityTypePopUp removeAllItems];
//    subenum = [[inputComponent allEntityTypes] objectEnumerator];
    subenum = [[self allEntityTypes] objectEnumerator];
    while ((entityType = [subenum nextObject]) != nil) {
        if (![self isContainerEntityType:entityType]) {
            NSString *title;
            title = [self descriptionForEntityType:entityType];
            [entityTypePopUp addItemWithTitle:title];
            [[entityTypePopUp itemWithTitle:title]
                                       setRepresentedObject:entityType];
            ct++;
        }
    }
    if (ct == 0) {
        [entityTypePopUp addItemWithTitle:@"None"];
        [entityTypePopUp setEnabled:NO];
    } else {
        [entityTypePopUp setEnabled:YES];
    }
    NSString *selectedTitle;
    selectedTitle = [self descriptionForEntityType:[type entityTypeToReduce]];
    [entityTypePopUp selectItemWithTitle:selectedTitle];
}

- (void)calcGroupPopUp
{
    PajeEntityType *entityType;
    PajeEntityType *parentEntityType;
    ReduceEntityType *type;
    int ct = 0;

    type = [[entityNamePopUp selectedItem] representedObject];
    [groupByPopUp removeAllItems];
    entityType = [type entityTypeToReduce];
    while ((parentEntityType = [self containerTypeForType:entityType]) != nil) {
        if (parentEntityType == entityType) break;
        entityType = parentEntityType;
        NSString *title;
        title = [self descriptionForEntityType:entityType];
        [groupByPopUp insertItemWithTitle:title atIndex:0];
        [[groupByPopUp itemAtIndex:0] setRepresentedObject:entityType];
	ct++;
    }
    if (ct == 0) {
        [groupByPopUp addItemWithTitle:@"None"];
        [groupByPopUp setEnabled:NO];
    } else {
        [groupByPopUp setEnabled:YES];
    }
    NSString *selectedTitle;
    selectedTitle = [self descriptionForEntityType:
                                              [self containerTypeForType:type]];
    [groupByPopUp selectItemWithTitle:selectedTitle];
}

- (void)calcReduceModePopUp
{
    ReduceEntityType *type;
    Class entityClass;
    NSArray *reduceEntityClassNames = [NSArray arrayWithObjects:
        @"CountReduceEntity",
        @"SumReduceEntity",
        @"AverageReduceEntity",
        @"MaxReduceEntity",
        @"MinReduceEntity",
        nil];
    NSEnumerator *classNameEnum;
    NSString *className;
    int ct = 0;
    
    [reduceModePopUp removeAllItems];
    classNameEnum = [reduceEntityClassNames objectEnumerator];
    while ((className = [classNameEnum nextObject]) != nil) {
        entityClass = NSClassFromString(className);
        if (!entityClass) {
            NSWarnMLog(@"class named %@ not found!", className);
            continue;
        }
        [reduceModePopUp addItemWithTitle:[entityClass titleForPopUp]];
        [[reduceModePopUp lastItem] setRepresentedObject:entityClass];
	ct++;
    }
    if (ct == 0) {
    	[reduceModePopUp addItemWithTitle:@"None"];
    	[reduceModePopUp setEnabled:NO];
    } else {
    	[reduceModePopUp setEnabled:YES];
    }

    type = [[entityNamePopUp selectedItem] representedObject];
    entityClass = [type entityClass];
    if (entityClass)
        [reduceModePopUp selectItemWithTitle:[entityClass titleForPopUp]];
}

- (void)calcHierarchy
{
    ReduceEntityType *entityType;
    NSEnumerator *entityTypeEnumerator;
    
    [typesContainingReducedTypes removeAllObjects];

    entityTypeEnumerator = [reduceEntityTypes objectEnumerator];
    while ((entityType = [entityTypeEnumerator nextObject]) != nil) {
        [self addToHierarchy:entityType];
    }

    [super hierarchyChanged];
}

- (void)addToHierarchy:(ReduceEntityType *)entityType
{
    PajeContainerType *containerType;
    NSMutableArray *containedTypes;
    
    containerType = [entityType containerType];
    containedTypes = [typesContainingReducedTypes objectForKey:containerType];
    
    if (containedTypes == nil) {
        containedTypes = [NSMutableArray arrayWithObject:entityType];
        [containedTypes addObjectsFromArray:[super containedTypesForContainerType:containerType]];
        [typesContainingReducedTypes setObject:containedTypes
                                        forKey:containerType];
    } else {
        [containedTypes addObject:entityType];
    }
}

//
// interaction with interface
//
- (IBAction)createEntityType:(id)sender;
{
    ReduceEntityType *selectedEntityType;
    ReduceEntityType *newEntityType;
    NSString *newEntityName;
    int index;

    newEntityName = [entityNameField stringValue];
    index = [entityNamePopUp indexOfItemWithTitle:newEntityName];
    if (index != -1) {
        [entityNamePopUp selectItemAtIndex:index];
        [self entityNamePopUpChanged:self];
        return;
    }

    selectedEntityType = [[entityNamePopUp selectedItem] representedObject];
    if (selectedEntityType) {
        newEntityType = [ReduceEntityType typeWithName:newEntityName
                                         containerType:(PajeContainerType *)[self containerTypeForType:selectedEntityType]
                                             component:self];
        [newEntityType setEntityClass:[selectedEntityType entityClass]];
        [newEntityType setEntityTypeToReduce:[selectedEntityType entityTypeToReduce]];
        [newEntityType addValuesToFilter:[[selectedEntityType filterValues] allObjects]];        
    } else {
        newEntityType = [ReduceEntityType typeWithName:newEntityName
                                         containerType:(PajeContainerType *)[self rootEntityType]
                                             component:self];
        [newEntityType setEntityClass:[CountReduceEntity class]];
        [newEntityType setEntityTypeToReduce:nil]; //FIXME
    }
    [reduceEntityTypes addObject:newEntityType];
    [entityTypesDictionary setObject:[newEntityType dictionaryForDefaults]
                              forKey:[newEntityType description]];
    [self registerDefaults];
    [self addToHierarchy:newEntityType];

    [self calcEntityNamePopUp];
    [entityNamePopUp selectItemWithTitle:[newEntityType description]];
    [self entityNamePopUpChanged:self];
    [super hierarchyChanged];
}

- (IBAction)deleteEntityType:(id)sender
{
    PajeEntityType *entityType;
    entityType = [[entityNamePopUp selectedItem] representedObject];
    if (entityType == nil) {
        NSBeep();
        return;
    }
    [entityTypesDictionary removeObjectForKey:[entityType description]];
    [reduceEntityTypes removeObject:entityType];
    [self calcHierarchy];
    [self registerDefaults];
    [self hierarchyChanged];
}

- (IBAction)renameEntityType:(id)sender
{
    ReduceEntityType *entityType;
    NSString *oldName;
    NSString *newName;
    entityType = [[entityNamePopUp selectedItem] representedObject];
    oldName = [entityType description];
    newName = [entityNameField stringValue];
    if ((oldName == nil) || (newName == nil) || [newName isEqual:oldName]) {
        NSBeep();
        return;
    }
    [reduceEntityTypes removeObject:entityType];
    [entityType setDescription:newName];
    [reduceEntityTypes addObject:entityType];
    [entityTypesDictionary removeObjectForKey:oldName];
    [entityTypesDictionary setObject:[entityType dictionaryForDefaults]
                              forKey:newName];
    [self calcHierarchy];
    [self registerDefaults];
    [[entityNamePopUp selectedItem] setTitle:newName];
    [entityNamePopUp synchronizeTitleAndSelectedItem];
//    [super hierarchyChanged];
}

- (IBAction)entityNamePopUpChanged:(id)sender
{
    [entityNameField setStringValue:[entityNamePopUp titleOfSelectedItem]];
    [self calcEntityTypePopUp];
    [self calcGroupPopUp];
    [self refreshMatrix];
}

- (IBAction)entityTypePopUpChanged:(id)sender
{
    ReduceEntityType *type;
    PajeEntityType *newEntityTypeToReduce;
    
    type = [[entityNamePopUp selectedItem] representedObject];
    if (type == nil) {
        NSBeep();
        return;
    }
    newEntityTypeToReduce = [[entityTypePopUp selectedItem] representedObject];
    if (![[type entityTypeToReduce] isEqual:newEntityTypeToReduce]) {
        [type setEntityTypeToReduce:newEntityTypeToReduce];
        [entityTypesDictionary setObject:[type dictionaryForDefaults]
                                  forKey:[type description]];
        [self registerDefaults];
        [self calcGroupPopUp];
        [self refreshMatrix];
        [self calcHierarchy];
    }
}

- (IBAction)groupByPopUpChanged:(id)sender
{
    ReduceEntityType *type;
    PajeContainerType *newContainerType;

    type = [[entityNamePopUp selectedItem] representedObject];
    if (type == nil) {
        NSBeep();
        return;
    }
    newContainerType = [[groupByPopUp selectedItem] representedObject];
    if (![newContainerType isEqual:[type containerType]]) {
        [type setContainerType:newContainerType];
        [entityTypesDictionary setObject:[type dictionaryForDefaults]
                                  forKey:[type description]];
        [self registerDefaults];
        [self refreshMatrix];
        [self calcHierarchy];
    }
}

- (IBAction)reduceModePopUpChanged:(id)sender
{
    ReduceEntityType *type;
    Class entityClass;

    type = [[entityNamePopUp selectedItem] representedObject];
    if (type == nil) {
        NSBeep();
        return;
    }
    entityClass = [[reduceModePopUp selectedItem] representedObject];
    if (entityClass == nil) {
        NSBeep();
        return;
    }
    [type setEntityClass:entityClass];
    
    [entityTypesDictionary setObject:[type dictionaryForDefaults]
                              forKey:[type description]];
    [self registerDefaults];

    [super dataChangedForEntityType:type];
}

- (IBAction)matrixChanged:(id)sender
// some cell has been (de)selected in matrix.
{
    ReduceEntityType *type;
    NSButtonCell *cell;

    cell = [sender selectedCell];

    if (nil == cell)
        return;

    type = [[entityNamePopUp selectedItem] representedObject];
    if (type == nil) {
        NSBeep();
        return;
    }
    if ([cell state]) {
        [type removeValueFromFilter:[cell representedObject]];
    } else {
        [type addValueToFilter:[cell representedObject]];
    }
    [entityTypesDictionary setObject:[type dictionaryForDefaults]
                              forKey:[type description]];
    [self registerDefaults];

    [super dataChangedForEntityType:type];
}


- (void)refreshMatrix
{
    unsigned i, n;
    NSButtonCell *cell;
    NSArray *allArray;
    ReduceEntityType *type;

    type = [[entityNamePopUp selectedItem] representedObject];
    allArray = [inputComponent allValuesForEntityType:[type entityTypeToReduce]];

    n = [allArray count];
    [nameMatrix renewRows:n columns:1];
    for (i = 0; i < n; i++) {
        NSString *name = [allArray objectAtIndex:i];
        cell = [nameMatrix cellAtRow:i column:0];
        [cell setTitle:name];
        [cell setRepresentedObject:name];
        [cell setState:![[type filterValues] containsObject:name]];
    }
    [nameMatrix sizeToFit];
    [nameMatrix setNeedsDisplay:YES];
}

//
// Trace messages that are filtered
//
- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
    NSArray *containedTypes;
    containedTypes = [typesContainingReducedTypes objectForKey:containerType];
    if (containedTypes != nil) {
        return containedTypes;
    } else {
        return [super containedTypesForContainerType:containerType];
    }
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
    if (![entityType isKindOfClass:[ReduceEntityType class]]) {
        return [super enumeratorOfEntitiesTyped:entityType
                                    inContainer:container
                                       fromTime:start
                                         toTime:end
                                    minDuration:minDuration];
    }

    return [(ReduceEntityType *)entityType
                        enumeratorOfEntitiesInContainer:container
                                               fromTime:start
                                                 toTime:end
                                            minDuration:minDuration];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                        inContainer:(PajeContainer *)container
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
                                        minDuration:(double)minDuration
{
    if (![entityType isKindOfClass:[ReduceEntityType class]]) {
        return [super enumeratorOfCompleteEntitiesTyped:entityType
                                            inContainer:container
                                               fromTime:start
                                                 toTime:end
                                            minDuration:minDuration];
    }

    return [(ReduceEntityType *)entityType
                        enumeratorOfCompleteEntitiesInContainer:container
                                                       fromTime:start
                                                         toTime:end
                                                    minDuration:minDuration];
}

- (BOOL)canHighlightEntity:(PajeEntity *)entity
{
    if ([entity isKindOfClass:[ReduceEntity class]]) {
        return NO;
    } else {
        return [inputComponent canHighlightEntity:entity];
    }
}

- (PajeDrawingType)drawingTypeForEntityType:(PajeEntityType *)entityType
{
    if ([entityType isKindOfClass:[ReduceEntityType class]])
        return [(ReduceEntityType *)entityType drawingType];
    else
        return [super drawingTypeForEntityType:entityType];
}

- (double)doubleValueForEntity:(PajeEntity *)entity
{
    if ([entity isKindOfClass:[ReduceEntity class]]) {
        return [(ReduceEntity *)entity doubleValue];
    } else {
        return [inputComponent doubleValueForEntity:entity];
    }
}

- (double)minValueForEntity:(PajeEntity *)entity
{
    if ([entity isKindOfClass:[ReduceEntity class]]) {
        return [(ReduceEntity *)entity minValue];
    } else {
        return [inputComponent minValueForEntity:entity];
    }
}

- (double)maxValueForEntity:(PajeEntity *)entity
{
    if ([entity isKindOfClass:[ReduceEntity class]]) {
        return [(ReduceEntity *)entity maxValue];
    } else {
        return [inputComponent maxValueForEntity:entity];
    }
}

- (double)minValueForEntityType:(PajeEntityType *)entityType
{
    if ([entityType isKindOfClass:[ReduceEntityType class]]) {
        return [(ReduceEntityType *)entityType minValue];
    } else {
        return [super minValueForEntityType:entityType];
    }
}

- (double)maxValueForEntityType:(PajeEntityType *)entityType
{
    if ([entityType isKindOfClass:[ReduceEntityType class]]) {
        return [(ReduceEntityType *)entityType maxValue];
    } else {
        return [super maxValueForEntityType:entityType];
    }
}

- (double)minValueForEntityType:(PajeEntityType *)entityType
                    inContainer:(PajeContainer *)container
{
    if ([entityType isKindOfClass:[ReduceEntityType class]]) {
        return [(ReduceEntityType *)entityType minValue];
    } else {
        return [super minValueForEntityType:entityType inContainer:container];
    }
}

- (double)maxValueForEntityType:(PajeEntityType *)entityType
                    inContainer:(PajeContainer *)container
{
    if ([entityType isKindOfClass:[ReduceEntityType class]]) {
        return [(ReduceEntityType *)entityType maxValue];
    } else {
        return [super maxValueForEntityType:entityType inContainer:container];
    }
}

- (id)configuration
{
    NSEnumerator *typeEnum;
    ReduceEntityType *type;
    NSMutableArray *types;
    
    types = [NSMutableArray arrayWithCapacity:[reduceEntityTypes count]];
    typeEnum = [reduceEntityTypes objectEnumerator];
    while ((type = [typeEnum nextObject]) != nil) {
        [types addObject:[type dictionaryForDefaults]];
    }
    return types;
}

- (void)setConfiguration:(id)config
{
    NSEnumerator *filterEnum;
    NSDictionary *filter;
    ReduceEntityType *entityType;

    [reduceEntityTypes removeAllObjects];
    filterEnum = [config objectEnumerator];
    while ((filter = [filterEnum nextObject]) != nil) {
        entityType = [ReduceEntityType typeFromDictionary:filter component:self];
        if (entityType != nil) {
            [reduceEntityTypes addObject:entityType];
            [self addToHierarchy:entityType];
        }
    }

    [self calcEntityNamePopUp];
    [self calcEntityTypePopUp];
    [self calcGroupPopUp];
    [self calcReduceModePopUp];
    [self refreshMatrix];
    [self calcHierarchy];

    //[super hierarchyChanged];
}

@end
