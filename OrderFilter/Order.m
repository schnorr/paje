/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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
/* Order.m created by benhur on 20-mar-2001 */

/*
 * A Paje filter to change the order of containers
 */

#include "Order.h"
#include "OrderKey.h"

@implementation Order

- (id)initWithController:(PajeTraceController *)c
{
    NSWindow *win;
    
    self = [super initWithController:c];

    if (self != nil) {
        containers = [[NSMutableDictionary alloc] init];

        if (![NSBundle loadNibNamed:@"Order" owner:self]) {
            NSRunAlertPanel(@"Order", @"Couldn't load interface file",
                            nil, nil, nil);
            return self;
        }

        win = [view window];

        // view is an NSBox. we need its contents.
        view = [[(NSBox *)view contentView] retain];

        hierarchyBrowser = [[HierarchyBrowser alloc] initWithFilter:self];
        [hierarchyBrowser setContainersOnly:YES];
        [[hierarchyBrowser view] setFrame:[browserBox frame]];
        [[browserBox superview] replaceSubview:browserBox
                                          with:[hierarchyBrowser view]];

        [self registerFilter:self];

#ifndef GNUSTEP
        [win release];
#endif

    }
    return self;
}

- (void)dealloc
{
    [containers release];
    [hierarchyBrowser release];
#ifndef __APPLE__
    [view release];
#endif
    [super dealloc];
}

- (NSView *)filterView
{
    return view;
}

- (NSString *)filterName
{
    return @"Order";
}

- (id)filterDelegate
{
    return self;
}

- (NSArray *)defaultsForKey:(OrderKey *)key
{
    NSString *defaultKey;
    
    defaultKey = [NSString stringWithFormat:@"%@ in %@ Order", 
                           [key entityType], [key container]];

    return [[NSUserDefaults standardUserDefaults] arrayForKey:defaultKey];
}

- (void)registerDefaultsForKey:(OrderKey *)key
{
    NSString *defaultKey;
    NSMutableArray *containerNames;
    NSEnumerator *containerEnum;
    PajeContainer *container;
    
    containerNames = [NSMutableArray array];
    containerEnum = [[containers objectForKey:key] objectEnumerator];
    
    while ((container = [containerEnum nextObject]) != nil) {
        [containerNames addObject:[container name]];
    }
    
    defaultKey = [NSString stringWithFormat:@"%@ in %@ Order", 
                           [key entityType], [key container]];

    [[NSUserDefaults standardUserDefaults] setObject:containerNames
                                              forKey:defaultKey];
}

//
// Notifications sent by other filters
//

- (PajeContainer *)removeContainerNamed:(NSString *)containerName
                              fromArray:(NSMutableArray *)array
{
    PajeContainer *container;
    int index;
    
    index = [array count];
    while (index > 0) {
        container = [array objectAtIndex:--index];
        if ([[container name] isEqual:containerName]) {
            [array removeObjectAtIndex:index];
            return container;
        }
    }
    return nil;
}

- (void)synchronizeKey:(OrderKey *)key
        toOrderedNames:(NSArray *)containerNames
{
    NSMutableArray *orderedContainers;
    NSMutableArray *allContainers;
    NSEnumerator *containerNamesEnum;
    NSString *containerName;
    
    orderedContainers = [NSMutableArray array];
    allContainers = [[[super enumeratorOfContainersTyped:[key entityType]
                                             inContainer:[key container]]
                                allObjects] mutableCopy];
    containerNamesEnum = [containerNames objectEnumerator];
    while ((containerName = [containerNamesEnum nextObject]) != nil) {
        PajeContainer *container;
        container = [self removeContainerNamed:containerName
                                     fromArray:allContainers];
        if (container != nil) {
            [orderedContainers addObject:container];
        }
    }
    [orderedContainers addObjectsFromArray:allContainers];
    [containers setObject:orderedContainers forKey:key];
    [allContainers release];
    //[self registerDefaultsForKey:key];
}

- (void)synchronizeKey:(OrderKey *)key
{
    NSArray *orderFromDefaults;
    
    orderFromDefaults = [self defaultsForKey:key];
    if (orderFromDefaults == nil) {
        return;
    }

    [self synchronizeKey:key toOrderedNames:orderFromDefaults];
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    if ([entityType isContainer]) {
        NSEnumerator *keyEnum;
        OrderKey *key;
        
        keyEnum = [containers keyEnumerator];
        while ((key = [keyEnum nextObject]) != nil) {
            if ([[key entityType] isEqual:entityType]) {
                [self synchronizeKey:key];
            }
        }
    }
    [super dataChangedForEntityType:entityType];
}

- (void)hierarchyChanged
{
    [containers removeAllObjects];
    [hierarchyBrowser refreshLastColumn];
    [super hierarchyChanged];
}

//
// Handle interface messages
//
- (void)moveSelectedContainersBy:(int)moveAmount
{
    PajeEntityType *containerType;
    PajeContainer *container;
    OrderKey *key;
    NSMutableArray *containerArray;
    NSArray *selectedContainers;
    PajeContainer *firstSelectedContainer;
    NSUInteger index, maxIndex;

    selectedContainers = [[self selectedContainers] allObjects];
    if ((selectedContainers == nil) || ([selectedContainers count] == 0)) {
        NSBeep();
        return;
    }
    firstSelectedContainer = [selectedContainers objectAtIndex:0];

    containerType = [super entityTypeForEntity:firstSelectedContainer];
    container = [super containerForEntity:firstSelectedContainer];
    key = [OrderKey keyWithEntityType:containerType container:container];
    containerArray = [containers objectForKey:key];

    // if not being filtered, initialize a filter for them.
    if (containerArray == nil) {
        NSEnumerator *unfilteredEnum;
        unfilteredEnum = [super enumeratorOfContainersTyped:containerType
                                                inContainer:container];
        containerArray = [NSMutableArray arrayWithArray:[unfilteredEnum allObjects]];
        [containers setObject:containerArray forKey:key];
    }

    index = [containerArray indexOfObjectIdenticalTo:firstSelectedContainer];
    if (index == NSNotFound) {
        [NSException raise:@"Order: Internal Inconsistency"
                    format:@"Container Not Found: %@", firstSelectedContainer];
    }
    index += moveAmount;
    maxIndex = [containerArray count] - [selectedContainers count];
    if (index > maxIndex) {
        index = maxIndex;
    }
    [containerArray removeObjectsInArray:selectedContainers];
    [containerArray replaceObjectsInRange:NSMakeRange(index, 0)
                     withObjectsFromArray:selectedContainers];

    [self setOrder:containerArray
 ofContainersTyped:containerType
       inContainer:container];
}

- (void)setOrder:(NSArray *)containerOrder
ofContainersTyped:(PajeEntityType *)containerType
     inContainer:(PajeContainer *)container
{
    OrderKey *key;
    key = [OrderKey keyWithEntityType:containerType container:container];
    [containers setObject:containerOrder forKey:key];
    [self registerDefaultsForKey:key];
    [hierarchyBrowser refreshLastColumn];
    [hierarchyBrowser selectContainers:[[self selectedContainers] allObjects]];
    [super orderChangedForContainerType:containerType];
}

- (void)containerSelectionChanged
{
    // TODO make last column the one that contains the selected containers
    [hierarchyBrowser refreshLastColumn];
    [hierarchyBrowser selectContainers:[[self selectedContainers] allObjects]];
    [super containerSelectionChanged];
}

- (void)hierarchyBrowserContainerSelected:(HierarchyBrowser *)browser 
{
    [super setSelectedContainers:[NSSet setWithArray:[browser selectedContainers]]];
}

- (IBAction)moveUp:(id)sender
{
    [self moveSelectedContainersBy:-1];
}

- (IBAction)moveDown:(id)sender
{
    [self moveSelectedContainersBy:1];
}


/*
- (void)entityTypeSelected:(id)sender
{
    [self synchronizeMatrix];
}

- (void)synchronizeMatrix
{
    [hierarchyBrowser setFilter:self];
}
*/

//
// interact with interface
//

/*
- (void)viewWillBeSelected:(NSView *)selectedView
// message sent by PajeController when a view will be selected for display
{
    [self synchronizeMatrix];        
}
*/

//
// Queries that are filtered
//
- (NSEnumerator *)enumeratorOfContainersTyped:(PajeContainerType *)entityType
                                  inContainer:(PajeContainer *)container
{
    OrderKey *key;
    NSArray *containerArray;

    if (container == nil) {
        return [super enumeratorOfContainersTyped:entityType
                                      inContainer:container];
    }

    key = [OrderKey keyWithEntityType:entityType container:container];
    containerArray = [containers objectForKey:key];
    if (containerArray == nil) {
        [self synchronizeKey:key];
        containerArray = [containers objectForKey:key];
    }
    
    if (containerArray == nil) {
        return [super enumeratorOfContainersTyped:entityType
                                      inContainer:container];
    } else {
        return [containerArray objectEnumerator];
    }
}

- (id)configuration
{
    return containers;
}

- (OrderKey *)keyFromDescription:(NSString *)description
{
    NSArray *keyAsArray;
    PajeEntityType *entityType;
    PajeContainer *container;

    NS_DURING
        keyAsArray = [description propertyList];
    NS_HANDLER
        NS_VALUERETURN(nil, id);
    NS_ENDHANDLER

    if (![keyAsArray isKindOfClass:[NSArray class]]
        || [keyAsArray count] != 2) {
        return nil;
    }

    entityType = [self entityTypeWithName:[keyAsArray objectAtIndex:0]];
    if (entityType == nil) {
        return nil;
    }
    
    container = [self containerWithName:[keyAsArray objectAtIndex:1]
                                   type:[self containerTypeForType:entityType]];
    if (container == nil) {
        return nil;
    }

    return [OrderKey keyWithEntityType:entityType container:container];
}

- (void)setConfiguration:(id)cfg
{
    NSEnumerator *keyDescriptionEnumerator;
    NSString *keyDescription;
    OrderKey *key;
    NSDictionary *config;

    config = cfg;
    if (![config isKindOfClass:[NSDictionary class]]) {
        return;
    }

    keyDescriptionEnumerator = [config keyEnumerator];
    while ((keyDescription = [keyDescriptionEnumerator nextObject]) != nil) {
        key = [self keyFromDescription:keyDescription];
        if (key != nil) {
            [self synchronizeKey:key
                  toOrderedNames:[config objectForKey:keyDescription]];
        }
    }
    [hierarchyBrowser refreshLastColumn];
    [super hierarchyChanged];
}
@end
