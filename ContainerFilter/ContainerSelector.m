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
/* ContainerSelector.m created by benhur on Sat 14-Jun-1997 */

#include "ContainerSelector.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"
#include "../General/Macros.h"
#include "../General/ColoredSwitchButtonCell.h"


@implementation ContainerSelector

- (id)initWithController:(PajeTraceController *)c
{
    NSWindow *win;
    
    [super initWithController:c];

    filters = [[NSMutableDictionary alloc] init];
    hiddenEntityTypes = [[NSMutableSet alloc] init];

    if (![NSBundle loadNibNamed:@"ContainerSelector" owner:self]) {
        NSRunAlertPanel(@"ContainerSelector", @"Couldn't load interface file",
                        nil, nil, nil);
        return self;
    }

    win = [view window];
    
    // view is an NSBox. we need its contents.
    view = [[(NSBox *)view contentView] retain];

    [matrix registerForDraggedTypes:
                                 [NSArray arrayWithObject:NSColorPboardType]];
    [matrix setDelegate:self];
//    [matrix setCellClass:[ColoredSwitchButtonCell class]];

    [entityTypePopUp removeAllItems];

    [self registerFilter:self];

#ifndef GNUSTEP
    [win release];
#endif

    return self;
}

- (void)dealloc
{
    [entityTypePopUp removeAllItems];
    [filters release];
    [hiddenEntityTypes release];
    [view release];
    [super dealloc];
}

- (NSView *)filterView
{
    return view;
}

- (NSString *)filterName
{
    return @"Container Selector";
}

- (id)filterDelegate
{
    return self;
}

//
// Notifications sent by other filters
//
- (void)hierarchyChanged
{
    PajeEntityType *entityType;
    NSEnumerator *typeEnum;
    
    typeEnum = [[self allEntityTypes] objectEnumerator];
    while ((entityType = [typeEnum nextObject]) != nil) {
        if ([self isContainerEntityType:entityType] 
            && ![entityType isEqual:[self rootEntityType]]) {
            [self setFilterForEntityType:entityType];
        }
    }
    [self synchronizeMatrix];
    [super hierarchyChanged];
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    if (entityType == nil || [entityType isEqual:[self selectedEntityType]]) {
        [self synchronizeMatrix];
    }
    [super colorChangedForEntityType:entityType];
}



//
//
//
- (BOOL)isRegisteredAsHiddenEntityType:(PajeEntityType *)entityType
{
    NSString *defaultKey;
    
    defaultKey = [[self descriptionForEntityType:entityType] stringByAppendingString:@" Hide"];

    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultKey];
}

- (void)setFilterForEntityType:(PajeEntityType *)entityType
// a new entity type is known. create a new filter for it.
{
    NSMutableSet *filter;
    NSString *entityTypeDescription;

    NSParameterAssert(entityType);
    
    entityTypeDescription = [self descriptionForEntityType:entityType];
    filter = [filters objectForKey:entityTypeDescription];

    if (nil == filter) {

        filter = [self defaultFilterForEntityType:entityType];

        [filters setObject:filter forKey:entityTypeDescription];

        [entityTypePopUp addItemWithTitle:entityTypeDescription];
        [[entityTypePopUp lastItem] setRepresentedObject:entityType];
#ifdef GNUSTEP
	[entityTypePopUp setEnabled:YES];
#endif
    }
    
//    if ([self isRegisteredAsHiddenEntityType:entityType]) {
//        [hiddenEntityTypes addObject:entityTypeDescription];
//    } else {
//        [hiddenEntityTypes removeObject:entityTypeDescription];
//    }
}

- (void)setHidden:(BOOL)hidden
       entityType:(PajeEntityType *)entityType
{
    NSString *defaultKey;
    NSString *entityTypeDescription;

    entityTypeDescription = [self descriptionForEntityType:entityType];
    defaultKey = [entityTypeDescription stringByAppendingString:@" Hide"];

    if (hidden) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:defaultKey];
        [hiddenEntityTypes addObject:entityTypeDescription];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultKey];
        [hiddenEntityTypes removeObject:entityTypeDescription];
   }
}

- (NSMutableSet *)defaultFilterForEntityType:(PajeEntityType *)entityType
{
    NSString *defaultName;
    NSArray *filterArray;

    defaultName = [NSString stringWithFormat:@"%@%@Filter",
                                    NSStringFromClass([self class]),
                                    [self descriptionForEntityType:entityType]];
    filterArray = [[NSUserDefaults standardUserDefaults]
                                    arrayForKey:defaultName];

    return [NSMutableSet setWithArray:[filterArray unifyStrings]];
}

- (void)registerDefaultFilter:(NSSet *)filter
                forEntityType:(PajeEntityType *)entityType
{
    NSString *defaultName = [NSString stringWithFormat:@"%@%@Filter", NSStringFromClass([self class]), [self descriptionForEntityType:entityType]];
    NSArray *filterArray = [filter allObjects];
    [[NSUserDefaults standardUserDefaults] setObject:filterArray
                                              forKey:defaultName];
}

- (PajeEntityType *)selectedEntityType
{
    if ([entityTypePopUp selectedItem] == nil) {
        [entityTypePopUp selectItemAtIndex:0];
    }
    return [[entityTypePopUp selectedItem] representedObject];
}

- (NSMutableSet *)filterForEntityType:(PajeEntityType *)entityType
{
    NSString *entityTypeDescription;

    entityTypeDescription = [self descriptionForEntityType:entityType];
    
    return [filters objectForKey:entityTypeDescription];
}

//
// Handle interface messages
//
- (IBAction)selectAll:(id)sender
{
    PajeEntityType *entityType = [self selectedEntityType];
    NSMutableSet *filter = [self filterForEntityType:entityType];

    if (filter) {
        [filter removeAllObjects];
        [self synchronizeMatrix];
        [self registerDefaultFilter:filter forEntityType:entityType];
        [super dataChangedForEntityType:entityType];
    } else {
        [NSException raise:@"ContainerSelector: Internal Inconsistency"
                    format:@"%@ sent by unknown view %@", 
                            NSStringFromSelector(_cmd), sender];
    }
}

- (NSArray *)unfilteredObjectsForEntityType:(PajeEntityType *)entityType
{
    NSEnumerator *containerEnum;
    PajeContainer *container;
    NSMutableArray *allDescriptions = [NSMutableArray array];
    
    containerEnum = [super enumeratorOfContainersTyped:entityType
                                           inContainer:[self rootInstance]];
    while ((container = [containerEnum nextObject]) != nil) {
        [allDescriptions addObject:[self nameForContainer:container]];
    }
    return allDescriptions;
}

- (id)configuration
{
    NSMutableDictionary *hiddenContainers;
    NSEnumerator *keyEnum;
    id key;
    NSSet *value;

    hiddenContainers = [NSMutableDictionary dictionaryWithCapacity:[filters count]];

    keyEnum = [filters keyEnumerator];
    while ((key = [keyEnum nextObject]) != nil) {
        value = [filters objectForKey:key];
	[hiddenContainers setObject:[value allObjects] forKey:key];
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:
                hiddenContainers, @"HiddenContainers",
                [hiddenEntityTypes allObjects], @"HiddenContainerTypes",
                nil];
}

- (void)setConfiguration:(id)config
{
    NSDictionary *configuration;
    NSMutableDictionary *hiddenContainers;
    NSEnumerator *keyEnum;
    id key;
    NSArray *value;
    NSArray *hiddenTypes;

    NSParameterAssert([config isKindOfClass:[NSDictionary class]]);
    configuration = config;

    hiddenContainers = [[configuration objectForKey:@"HiddenContainers"]
                                                                unifyStrings];

    keyEnum = [hiddenContainers keyEnumerator];
    while ((key = [keyEnum nextObject]) != nil) {
        value = [hiddenContainers objectForKey:key];
	[filters setObject:[NSMutableSet setWithArray:value] forKey:key];
    }

    hiddenTypes = [[configuration objectForKey:@"HiddenContainerTypes"]
                                                               unifyStrings];
    Assign(hiddenEntityTypes, [NSMutableSet setWithArray:hiddenTypes]);
    [self hierarchyChanged];
    [super dataChangedForEntityType:nil];
}

- (IBAction)unselectAll:(id)sender
{
    PajeEntityType *entityType = [self selectedEntityType];
    NSMutableSet *filter = [self filterForEntityType:entityType];

    if (filter) {
        [filter addObjectsFromArray:[self unfilteredObjectsForEntityType:entityType]];
        [self synchronizeMatrix];
        [self registerDefaultFilter:filter forEntityType:entityType];
        [super dataChangedForEntityType:entityType];
    } else {
        [NSException raise:@"ContainerSelector: Internal Inconsistency"
                    format:@"%@ sent by unknown view %@", NSStringFromSelector(_cmd), sender];
    }
}

- (IBAction)hideButtonClicked:(id)sender
{
    [self setHidden:[sender state] entityType:[self selectedEntityType]];
    [super hierarchyChanged];
}

- (void)filterName:(NSString *)name
      ofEntityType:(PajeEntityType *)entityType
              show:(BOOL)flag
{
    NSMutableSet *filter;

    filter = [self filterForEntityType:entityType];

    if (filter != nil) {
        if (flag) {
            [filter removeObject:name];
        } else {
            [filter addObject:name];
        }
        [self registerDefaultFilter:filter forEntityType:entityType];
        [super dataChangedForEntityType:entityType];
    }
}

- (IBAction)matrixChanged:(id)sender
{
    NSButtonCell *cell = [sender selectedCell];
    PajeEntityType* entityType = [self selectedEntityType];

    if (cell != nil) {
        [self filterName:[cell representedObject]
            ofEntityType:entityType
                    show:[cell state]];
    }
}

- (IBAction)entityPopUpChanged:(id)sender
{
    [self synchronizeMatrix];
}

- (void)synchronizeMatrix
{
    id entityType = [self selectedEntityType];
    NSMutableSet *filter;
    NSEnumerator *names;
    id entityName;
    int i = 0;
    ColoredSwitchButtonCell *cell;

    if (entityType == nil) {
        return;
    }
    
    filter = [self filterForEntityType:entityType];
    names = [[self unfilteredObjectsForEntityType:entityType] objectEnumerator];

    while ([matrix cellAtRow:0 column:0]) {
        [matrix removeRow:0];
    }

    while ((entityName = [names nextObject]) != nil) {
        [matrix addRow];
        cell = [matrix cellAtRow:i column:0];
        [cell setState:!([filter containsObject:entityName])];
        [cell setRepresentedObject:entityName];
#if 0
#ifndef xxGNUSTEP
        NSMutableAttributedString *title;
        title = [[[NSMutableAttributedString alloc] initWithString:[entityName description]] autorelease];
#if defined(__APPLE__)// || defined(GNUSTEP)
        [title replaceCharactersInRange:NSMakeRange(0,0) withString:@"# "];
        [title addAttribute:NSFontAttributeName
                      value:[NSFont boldSystemFontOfSize:16]
                      range:NSMakeRange(0,1)];
        [title addAttribute:NSFontAttributeName
                      value:[NSFont systemFontOfSize:12]
                      range:NSMakeRange(1, [title length]-1)];
#else
        // 0x25a0 is unicode for a solid small square
        [title replaceCharactersInRange:NSMakeRange(0,0)
               withString:[NSString stringWithCharacter:0x25a0]];
        [title replaceCharactersInRange:NSMakeRange(1,0) withString:@" "];
#endif
        [title addAttribute:NSForegroundColorAttributeName
                      value:[inputComponent colorForName:entityName
                                            ofEntityType:entityType]
                      range:NSMakeRange(0,1)];
        [title fixAttributesInRange:NSMakeRange(0, [title length])];
        [cell setAttributedTitle:title];
#else /*!GNUSTEP*/
        [cell setTitle:[entityName description]];
#endif
#else
        [cell setTitle:[entityName description]];
//        [cell setColor:[inputComponent colorForName:entityName
//                                            ofEntityType:entityType]];
#endif
        [cell setHighlightsBy:NSChangeBackgroundCellMask];
        i++;
    }
//    [matrix sortUsingSelector:@selector(compare:)];
    [matrix sizeToCells];
    [matrix setNeedsDisplay:YES];
    
    [hideButton setState:[self isHiddenEntityType:entityType]];
}

//
// interact with interface
//

- (void)viewWillBeSelected:(NSView *)selectedView
// message sent by PajeController when a view will be selected for display
{
    [self synchronizeMatrix];        
}


//
// Trace messages that are filtered
//

- (void)hideEntityType:(PajeEntityType *)entityType
{
    if (![self isContainerEntityType:entityType]) {
        [super hideEntityType:entityType];
    } else {
        [self setHidden:YES entityType:entityType];
        [super hierarchyChanged];
    }
}

- (void)hideSelectedContainers
{
    NSEnumerator *containerEnum;
    PajeContainer *container;
    
    containerEnum = [[self selectedContainers] objectEnumerator];
    while ((container = [containerEnum nextObject]) != nil) {
        [[self filterForEntityType:[self entityTypeForEntity:container]]
            addObject:[self nameForContainer:container]];
    }
    [self synchronizeMatrix];
    [super dataChangedForEntityType:nil];
}

- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
    NSArray *entityTypes;
    PajeEntityType *entityType;
    NSEnumerator *typeEnum;
    NSMutableArray *filteredTypes;

    filteredTypes = [NSMutableArray array];
    entityTypes = [super containedTypesForContainerType:containerType];
    typeEnum = [entityTypes objectEnumerator];
    while ((entityType = [typeEnum nextObject]) != nil) {
        if (![self isHiddenEntityType:entityType]) {
            [filteredTypes addObject:entityType];
        }
    }
    return filteredTypes;
}

- (id)filterHiddenContainer:(PajeContainer *)container
                     filter:(NSSet *)filter
{
    if ([filter containsObject:[self nameForContainer:container]]) {
        return nil;
    } else {
        return container;
    }
}

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeContainerType *)entityType
                                  inContainer:(PajeContainer *)container
{
    NSEnumerator *origEnum;
    NSMutableSet *filter;

    if ([self isHiddenEntityType:entityType]) {
        NSWarnLog(@"enumerating hidden type %@", entityType);
        return nil;
    }

    origEnum = [inputComponent enumeratorOfContainersTyped:entityType
                                               inContainer:container];

    filter = [self filterForEntityType:entityType];
    if (filter != nil) {
        return [[[FilteredEnumerator alloc]
                    initWithEnumerator:origEnum
                                filter:self
                              selector:@selector(filterHiddenContainer:filter:)
                               context:filter] autorelease];
    } else {
        return origEnum;
    }
}

- (BOOL)isHiddenEntityType:(PajeEntityType*)entityType
{
    NSString *entityTypeDescription;
    entityTypeDescription = [self descriptionForEntityType:entityType];
    return [hiddenEntityTypes containsObject:entityTypeDescription];
}

//
// methods to be a dragging destination, as delegate of matrix
//

- (void)highlightCell:(id)cell inMatrix:(NSMatrix *)m
{
    NSInteger r, c;
    static id highlightedCell; // the last cell that has been highlighted
    
    if (highlightedCell && ![highlightedCell isEqual:cell]) {
        [m getRow:&r column:&c ofCell:highlightedCell];
        [m highlightCell:NO atRow:r column:c];
        highlightedCell = nil;
    }
    
    if (cell && ![cell isEqual:highlightedCell]) {
        [m getRow:&r column:&c ofCell:cell];
        [m highlightCell:YES atRow:r column:c];
        highlightedCell = cell;
    }
}

#ifdef GNUSTEP
- (NSDragOperation)matrix:(NSMatrix *)m
          draggingEntered:(id <NSDraggingInfo>)sender
{
NSDebugMLog(@"");
    return NSDragOperationAll;
}
#endif

- (NSDragOperation)matrix:(NSMatrix *)m
          draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPoint point = [m convertPoint:[sender draggingLocation] fromView:nil];
    NSButtonCell *cell = [m cellAtPoint:point];

NSDebugMLog(@"");
    [self highlightCell:cell inMatrix:m];
    if (cell)
        return NSDragOperationAll;//NSDragOperationGeneric;
    else
        return NSDragOperationNone;
}

#ifdef GNUSTEP
- (BOOL)matrix:(NSMatrix *)m prepareForDragOperation:(id <NSDraggingInfo>)sender
{
NSDebugMLog(@"");
    return YES;
}
#endif

- (BOOL)matrix:(NSMatrix *)m performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPoint point;
    NSButtonCell *cell;

NSDebugMLog(@"");
    point = [m convertPoint:[sender draggingLocation] fromView:nil];
    cell = [m cellAtPoint:point];

    [self highlightCell:nil inMatrix:m];
    
    if (cell != nil) {
        id entityType = [self selectedEntityType];
NSDebugMLog(@"entityType:%@ color:%@", entityType, [NSColor colorFromPasteboard:[sender draggingPasteboard]]);
        [inputComponent setColor:[NSColor colorFromPasteboard:[sender draggingPasteboard]]
                        forValue:[cell representedObject]
                    ofEntityType:entityType];
        if ([cell state] == 1) {
            [super colorChangedForEntityType:entityType];
	}
        [self synchronizeMatrix];
        return YES;
    }
    return NO;
}

- (void)matrix:(NSMatrix *)m draggingExited:(id <NSDraggingInfo>)sender
{
NSDebugMLog(@"");
    [self highlightCell:nil inMatrix:m];
}

@end
