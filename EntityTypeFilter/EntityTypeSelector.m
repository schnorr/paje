/*
    Copyright (c) 1998--2005 Benhur Stein
    
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
/* EntityTypeSelector.m created by benhur on Sat 14-Jun-1997 */

#include "EntityTypeSelector.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"
#include "../General/Macros.h"
#include "../General/ColoredSwitchButtonCell.h"


@implementation EntityTypeSelector

- (id)initWithController:(PajeTraceController *)c
{
    NSWindow *win;
    
    [super initWithController:c];

    filters = [[NSMutableDictionary alloc] init];
    hiddenEntityTypes = [[NSMutableSet alloc] init];

    if (![NSBundle loadNibNamed:@"EntityTypeSelector" owner:self]) {
        NSRunAlertPanel(@"EntityTypeSelector", @"Couldn't load interface file",
                        nil, nil, nil);
        return self;
    }

    win = [view window];
    
    // view is an NSBox. we need its contents.
    view = [[(NSBox *)view contentView] retain];

    [matrix registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];
    [matrix setDelegate:self];
#ifdef __APPLE__
    ColoredSwitchButtonCell *protoCell;
    protoCell = [[ColoredSwitchButtonCell alloc] init];
    [matrix setPrototype:protoCell];
    [protoCell release];
#else
    [matrix setCellClass:[ColoredSwitchButtonCell class]];
#endif

    [entityTypePopUp removeAllItems];

    [self registerFilter:self];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(filterEntityValueNotification:)
               name:@"PajeFilterEntityValueNotification"
             object:nil];

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
    return @"Entity Type Selector";
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
        if (![self isContainerEntityType:entityType]) {
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
    
    defaultKey = [[entityType description] stringByAppendingString:@" Hide"];

    return [[NSUserDefaults standardUserDefaults] boolForKey:defaultKey];
}

- (void)setFilterForEntityType:(PajeEntityType *)entityType
// a new entity type is known. create a new filter for it.
{
    NSMutableSet *filter;

    NSParameterAssert(entityType);
    
    filter = [filters objectForKey:entityType];

    if (nil == filter) {

        filter = [self defaultFilterForEntityType:entityType];

        [filters setObject:filter forKey:entityType];

        [entityTypePopUp addItemWithTitle:[entityType description]];
        [[entityTypePopUp lastItem] setRepresentedObject:entityType];
#ifdef GNUSTEP
	[entityTypePopUp setEnabled:YES];
#endif
    }
    
    if ([self isRegisteredAsHiddenEntityType:entityType]) {
        [hiddenEntityTypes addObject:entityType];
    } else {
        [hiddenEntityTypes removeObject:entityType];
    }
}

- (void)setHidden:(BOOL)hidden
       entityType:(PajeEntityType *)entityType
{
    NSString *defaultKey;
    
    defaultKey = [[entityType description] stringByAppendingString:@" Hide"];

    if (hidden) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:defaultKey];
        [hiddenEntityTypes addObject:entityType];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultKey];
        [hiddenEntityTypes removeObject:entityType];
   }
}

- (NSMutableSet *)defaultFilterForEntityType:(PajeEntityType *)entityType
{
    NSString *defaultName = [NSString stringWithFormat:@"%@%@Filter", NSStringFromClass([self class]), [entityType description]];
    NSArray *filterArray = [[NSUserDefaults standardUserDefaults] arrayForKey:defaultName];
    NSMutableSet *uniqueSet;
    NSEnumerator *filterEnum;
    NSString *s;
    
#ifdef GNUSTEP
    uniqueSet = [[[NSMutableSet alloc] init] autorelease];
#else
    uniqueSet = [NSMutableSet set];
#endif
    filterEnum = [filterArray objectEnumerator];
    while ((s = [filterEnum nextObject]) != nil) {
        [uniqueSet addObject:U(s)];
    }
    
    return uniqueSet;
}

- (void)registerDefaultFilter:(NSSet *)filter
                forEntityType:(PajeEntityType *)entityType
{
    NSString *defaultName = [NSString stringWithFormat:@"%@%@Filter", NSStringFromClass([self class]), [entityType description]];
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


//
// Handle interface messages
//
- (void)selectAll:(id)sender
{
    PajeEntityType *entityType = [self selectedEntityType];
    NSMutableSet *filter = [filters objectForKey:entityType];

    if (filter != nil) {
        [filter removeAllObjects];
        [self synchronizeMatrix];
        [self registerDefaultFilter:filter forEntityType:entityType];
        [super dataChangedForEntityType:entityType];
    } else {
        [NSException raise:@"EntityTypeSelector: Internal Inconsistency"
                    format:@"%@ sent by unknown view %@",
                             NSStringFromSelector(_cmd), sender];
    }
}

- (NSArray *)unfilteredObjectsForEntityType:(PajeEntityType *)entityType
{
    return [super allValuesForEntityType:entityType];
}

- (void)unselectAll:(id)sender
{
    PajeEntityType *entityType = [self selectedEntityType];
    NSMutableSet *filter = [filters objectForKey:entityType];

    if (filter != nil) {
        [filter addObjectsFromArray:
                              [self unfilteredObjectsForEntityType:entityType]];
        [self synchronizeMatrix];
        [self registerDefaultFilter:filter forEntityType:entityType];
        [super dataChangedForEntityType:entityType];
    } else {
        [NSException raise:@"EntityTypeSelector: Internal Inconsistency"
                    format:@"%@ sent by unknown view %@",
                            NSStringFromSelector(_cmd), sender];
    }
}

- (IBAction)hideButtonClicked:(id)sender
{
    [self setHidden:[sender state] entityType:[self selectedEntityType]];
    [super hierarchyChanged];
}

- (void)filterValue:(id)value
       ofEntityType:(PajeEntityType *)entityType
               show:(BOOL)flag
{
    NSMutableSet *filter;

    filter = [filters objectForKey:entityType];

    if (filter != nil) {
        if (flag) {
            [filter removeObject:value];
        } else {
            [filter addObject:value];
        }
        [self registerDefaultFilter:filter forEntityType:entityType];
        [super dataChangedForEntityType:entityType];
    }
}

- (void)filterEntityValueNotification:(NSNotification *)notification
{
    id value;
    PajeEntityType *entityType;
    BOOL flag;
    NSDictionary *userInfo;

    userInfo = [notification userInfo];
    if (userInfo == nil)
        return;

    entityType = [userInfo objectForKey:@"EntityType"];
    value = [userInfo objectForKey:@"EntityValue"];
    flag = [[userInfo objectForKey:@"Show"] isEqualToString:@"YES"];

    if (entityType != nil && value != nil) {
        [self filterValue:value
             ofEntityType:entityType
                     show:flag];
    }
    [self synchronizeMatrix];        
}

- (void)matrixChanged:(id)sender
{
    NSButtonCell *cell = [sender selectedCell];
    PajeEntityType* entityType = [self selectedEntityType];

    if (cell != nil) {
        [self filterValue:[cell representedObject]
             ofEntityType:entityType
                     show:[cell state]];
    }
}

- (void)entityPopUpChanged:(id)sender
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
    
    filter = [filters objectForKey:entityType];
    names = [[self unfilteredObjectsForEntityType:entityType] objectEnumerator];

    while ([matrix numberOfRows] > 0
            && ![[matrix cellAtRow:0 column:0]
                            isKindOfClass:[ColoredSwitchButtonCell class]]) {
        [matrix removeRow:0];
    }
    [matrix renewRows:[[self unfilteredObjectsForEntityType:entityType] count]
              columns:1];

    while ((entityName = [names nextObject]) != nil) {
        cell = [matrix cellAtRow:i column:0];
        [cell setState:!([filter containsObject:entityName])];
        [cell setRepresentedObject:entityName];
        [cell setTitle:[entityName description]];
        [cell setColor:[inputComponent colorForValue:entityName
                                        ofEntityType:entityType]];
        [cell setHighlightsBy:NSChangeBackgroundCellMask];
        i++;
    }
    [matrix sortUsingSelector:@selector(compare:)];
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
- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
    NSArray *types;
    NSMutableSet *filteredTypes;
    
    types = [super containedTypesForContainerType:containerType];
    filteredTypes = [NSMutableSet setWithArray:types];
    [filteredTypes minusSet:hiddenEntityTypes];
    return [filteredTypes allObjects];
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
    NSEnumerator *origEnum;
    NSMutableSet *filter;
    
    if ([self isHiddenEntityType:entityType]) {
        NSWarnLog(@"enumerating hidden type %@", entityType);
        return nil;
    }

    origEnum = [inputComponent enumeratorOfEntitiesTyped:entityType
                                             inContainer:container
                                                fromTime:start
                                                  toTime:end
                                             minDuration:minDuration];

    filter = [filters objectForKey:entityType];
    if (filter != nil) {
        return [[[FilteredEnumerator alloc] 
                        initWithEnumerator:origEnum
                                    filter:self
                                  selector:@selector(filterHiddenEntity:filter:)
                                   context:filter] autorelease];
    } else {
        return origEnum;
    }
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                        inContainer:(PajeContainer *)container
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
                                        minDuration:(double)minDuration
{
    NSEnumerator *origEnum;
    NSMutableSet *filter;
    
    if ([self isHiddenEntityType:entityType]) {
        NSWarnLog(@"enumerating hidden type %@", entityType);
        return nil;
    }

    origEnum = [inputComponent enumeratorOfCompleteEntitiesTyped:entityType
                                                     inContainer:container
                                                        fromTime:start
                                                          toTime:end
                                                     minDuration:minDuration];

    filter = [filters objectForKey:entityType];
    if (filter != nil) {
        return [[[FilteredEnumerator alloc] 
                        initWithEnumerator:origEnum
                                    filter:self
                                  selector:@selector(filterHiddenEntity:filter:)
                                   context:filter] autorelease];
    } else {
        return origEnum;
    }
}

- (BOOL)isHiddenEntityType:(PajeEntityType*)entityType
{
    return [hiddenEntityTypes member:entityType] != nil;
}

- (id)filterHiddenEntity:(PajeEntity *)entity
                  filter:(NSSet *)filter
{
    if ([filter containsObject:[self valueForEntity:entity]]) {
        return nil;
    } else {
        return entity;
    }
}

- (NSArray *)allValuesForEntityType:(PajeEntityType *)entityType
{
    NSArray *allValues = [inputComponent allValuesForEntityType:entityType];
    NSMutableSet *filter = [filters objectForKey:entityType];

    if (filter != nil) {
        NSMutableSet *set = [NSMutableSet setWithArray:allValues];
        [set minusSet:filter];
        allValues = [set allObjects];
    }
    return allValues;
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
    return NSDragOperationAll;
}
#endif

- (NSDragOperation)matrix:(NSMatrix *)m
          draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPoint point = [m convertPoint:[sender draggingLocation] fromView:nil];
    NSButtonCell *cell = [m cellAtPoint:point];

    [self highlightCell:cell inMatrix:m];
    if (cell)
        return NSDragOperationAll;//NSDragOperationGeneric;
    else
        return NSDragOperationNone;
}

#ifdef GNUSTEP
- (BOOL)matrix:(NSMatrix *)m prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}
#endif

- (BOOL)matrix:(NSMatrix *)m performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPoint point;
    NSButtonCell *cell;

    point = [m convertPoint:[sender draggingLocation] fromView:nil];
    cell = [m cellAtPoint:point];

    [self highlightCell:nil inMatrix:m];
    
    if (cell != nil) {
        PajeEntityType *entityType = [self selectedEntityType];
        NSColor *dragColor;
        
        dragColor = [NSColor colorFromPasteboard:[sender draggingPasteboard]];
        [inputComponent setColor:dragColor
                        forValue:[cell representedObject]
                    ofEntityType:entityType];
        return YES;
    }
    return NO;
}

- (void)matrix:(NSMatrix *)m draggingExited:(id <NSDraggingInfo>)sender
{
    [self highlightCell:nil inMatrix:m];
}

- (id)configuration
{
    NSMutableDictionary *hiddenNames;
    NSEnumerator *keyEnum;
    id key;
    NSSet *value;

    hiddenNames = [NSMutableDictionary dictionaryWithCapacity:[filters count]];

    keyEnum = [filters keyEnumerator];
    while ((key = [keyEnum nextObject]) != nil) {
        value = [filters objectForKey:key];
	[hiddenNames setObject:[value allObjects] 
                        forKey:[self descriptionForEntityType:key]];
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:
                hiddenNames, @"HiddenNames", 
                [hiddenEntityTypes allObjects], @"HiddenEntityTypes",
                nil];
}

- (void)setConfiguration:(id)config
{
    NSDictionary *configuration;
    NSMutableDictionary *hiddenNames;
    NSMutableArray *hiddenTypes;
    NSEnumerator *keyEnum;
    NSString *entityTypeName;
    PajeEntityType *entityType;
    int i;

    NSParameterAssert([config isKindOfClass:[NSDictionary class]]);
    configuration = config;
    hiddenNames = [[configuration objectForKey:@"HiddenNames"] unifyStrings];

    keyEnum = [hiddenNames keyEnumerator];
    while ((entityTypeName = [keyEnum nextObject]) != nil) {
        entityType = [self entityTypeWithName:entityTypeName];
        if (entityType != nil) {
            NSArray *value;
            value = [hiddenNames objectForKey:entityTypeName];
	    [filters setObject:[NSMutableSet setWithArray:value]
                        forKey:entityType];
        }
    }

    hiddenTypes = [[configuration objectForKey:@"HiddenEntityTypes"]
                                                               unifyStrings];
    for (i = 0; i < [hiddenTypes count];) {
        entityTypeName = [hiddenTypes objectAtIndex:i];
        entityType = [self entityTypeWithName:entityTypeName];
        if (entityType == nil) {
            [hiddenTypes removeObjectAtIndex:i];
        } else {
            [hiddenTypes replaceObjectAtIndex:i withObject:entityType];
            i++;
        }
    }
    Assign(hiddenEntityTypes, [NSMutableSet setWithArray:hiddenTypes]);
    [self hierarchyChanged];
    [super dataChangedForEntityType:nil];
}
@end
