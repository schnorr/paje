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
/* FieldFilter.m created by benhur on Sun 26-Dec-2004 */

#include "FieldFilter.h"
#include "FieldFilterDescriptor.h"

#include "../General/Macros.h"


@interface FieldFilter (Private)
- (PajeEntityType *)selectedEntityType;
- (void)setFilterDescriptor:(FieldFilterDescriptor *)fdesc
              forEntityType:(PajeEntityType *)entityType;
- (FieldFilterDescriptor *)filterDescriptorFromGUI;
- (void)setFilterFromGUI;
- (void)setGUIFromSelectedEntityType;
@end

@implementation FieldFilter

- (id)initWithController:(PajeTraceController *)c
{
    NSWindow *win;
    
    [super initWithController:c];

    filterDescriptors = [[NSMutableDictionary alloc] init];

    if (![NSBundle loadNibNamed:@"FieldFilter" owner:self]) {
        NSRunAlertPanel(@"FieldFilter", @"Couldn't load interface file",
                        nil, nil, nil);
        return self;
    }

    win = [view window];
    
    // view is an NSBox. we need its contents.
    view = [[(NSBox *)view contentView] retain];

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
    [filterDescriptors release];
    [view release];
    [super dealloc];
}


//
// Methods for TraceController
//

- (NSView *)filterView
{
    return view;
}

- (NSString *)filterName
{
    return @"Field Filter";
}

- (id)filterDelegate
{
    return self;
}

- (void)viewWillBeSelected:(NSView *)selectedView
// message sent by PajeController when a view will be selected for display
{
    [self setGUIFromSelectedEntityType];
}

//
// Notifications sent by other filters
//

- (void)hierarchyChanged
{
    PajeEntityType *entityType;
    NSEnumerator *typeEnum;
    
    [entityTypePopUp removeAllItems];
    typeEnum = [[self allEntityTypes] objectEnumerator];
    while ((entityType = [typeEnum nextObject]) != nil) {
        if (![self isContainerEntityType:entityType]) {
            [entityTypePopUp addItemWithTitle:[self descriptionForEntityType:entityType]];
            [[entityTypePopUp lastItem] setRepresentedObject:entityType];
        }
    }
    [entityTypePopUp selectItemAtIndex:0];
    [self setGUIFromSelectedEntityType];
    [super hierarchyChanged];
}




//
// helper methods
//

- (PajeEntityType *)selectedEntityType
{
    if ([entityTypePopUp selectedItem] == nil) {
        [entityTypePopUp selectItemAtIndex:0];
    }
    return [[entityTypePopUp selectedItem] representedObject];
}

- (void)setFilterDescriptor:(FieldFilterDescriptor *)fdesc
              forEntityType:(PajeEntityType *)entityType
{
    if (fdesc == nil) {
        [filterDescriptors removeObjectForKey:entityType];
    } else {
        [filterDescriptors setObject:fdesc forKey:entityType];
    }
    // register in defaults
}

- (FieldFilterDescriptor *)filterDescriptorFromGUI
{
    FieldFilterDescriptor *fdesc = nil;
    NSString *fieldName;
    int comparision;
    id value;

    fieldName = [[fieldNamePopUp selectedItem] title];
    if (![fieldName isEqual:NOFILTER]) {
        comparision = [[comparisionPopUp selectedItem] tag];
        value = [valueField stringValue];
        fdesc = [FieldFilterDescriptor descriptorWithFieldName:fieldName
                                                   comparision:comparision
                                                         value:value];
        [fdesc setAction:[[actionMatrix selectedCell] tag]];
    }
    
    return fdesc;
}

- (void)setFilterFromGUI
{
    PajeEntityType *entityType;
    FieldFilterDescriptor *fdesc;

    entityType = [self selectedEntityType];

    if (entityType == nil) {
        return;
    }
    
    fdesc = [self filterDescriptorFromGUI];

    [self setFilterDescriptor:fdesc forEntityType:entityType];
    [super dataChangedForEntityType:entityType];
}

- (void)setGUIFromSelectedEntityType
{
    id entityType = [self selectedEntityType];
    NSEnumerator *names;
    id fieldName;
    FieldFilterDescriptor *fdesc;

    if (entityType == nil) {
        return;
    }
    
    fdesc = [filterDescriptors objectForKey:entityType];

    [fieldNamePopUp removeAllItems];
    [fieldNamePopUp addItemWithTitle:NOFILTER];
    names = [[self fieldNamesForEntityType:entityType] objectEnumerator];
    while ((fieldName = [names nextObject]) != nil) {
        [fieldNamePopUp addItemWithTitle:fieldName];
    }
    
    if (fdesc == nil) {
        [fieldNamePopUp selectItemAtIndex:0];
    } else {
        [fieldNamePopUp selectItemWithTitle:[fdesc fieldName]];
        [comparisionPopUp selectItemAtIndex:[fdesc comparision]];
        [valueField setStringValue:[fdesc value]];
        [actionMatrix selectCellWithTag:[fdesc action]];
    }
}


//
// Handle interface messages
//

- (IBAction)entityTypePopUpChanged:(id)sender
{
    [self setGUIFromSelectedEntityType];
}

- (IBAction)fieldNamePopUpChanged:(id)sender
{
    [self setFilterFromGUI];    
}

- (IBAction)comparisionPopUpChanged:(id)sender
{
    [self setFilterFromGUI];    
}

- (IBAction)valueChanged:(id)sender
{
    [self setFilterFromGUI];    
}


//
// method called for each entity during enumeration.
// returns YES if entity should be filtered (not shown)
//

- (id)filterEntity:(PajeEntity *)entity
withFilterDescriptor:(FieldFilterDescriptor *)fdesc
{
    id entityValue;
    id filterValue;
    BOOL result = NO;

    entityValue = [self valueOfFieldNamed:[fdesc fieldName] forEntity:entity];
    entityValue = [entityValue description];
    filterValue = [fdesc value];
    
    switch ([fdesc comparision]) {
    case 0:
        result = [entityValue isEqual:filterValue];
        break;
    case 1:
        result = [entityValue floatValue] > [filterValue floatValue];
        break;
    case 2:
        result = [entityValue floatValue] < [filterValue floatValue];
        break;
    }
    if (result) {
        return nil;
    } else {
        return entity;
    }
}


//
// PajeFilter messages that are filtered
//

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
    NSEnumerator *origEnum;
    FieldFilterDescriptor *fdesc;
    
    origEnum = [inputComponent enumeratorOfEntitiesTyped:entityType
                                             inContainer:container
                                                fromTime:start
                                                  toTime:end
                                             minDuration:minDuration];

    fdesc = [filterDescriptors objectForKey:entityType];
    if (fdesc != nil && [fdesc action] == FILTEROUT) {
        SEL filterSelector = @selector(filterEntity:withFilterDescriptor:);
        return [[[FilteredEnumerator alloc]
                                     initWithEnumerator:origEnum
                                                 filter:self
                                               selector:filterSelector
                                                context:fdesc] autorelease];
    } else {
        return origEnum;
    }
}

- (BOOL)isSelectedEntity:(id<PajeEntity>)entity
{
    FieldFilterDescriptor *fdesc;
    fdesc = [filterDescriptors objectForKey:[self entityTypeForEntity:entity]];
    if (fdesc != NULL && [fdesc action] == HIGHLIGHT) {
        return [self filterEntity:(PajeEntity *)entity
             withFilterDescriptor:fdesc] == nil;
    }
    return [super isSelectedEntity:entity];
}


@end
