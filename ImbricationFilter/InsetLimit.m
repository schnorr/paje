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
/* InsetLimit.m created by benhur on 25-feb-2001 */

#include "InsetLimit.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"


@interface ImbricationFilteringEnumerator : NSEnumerator
{
    NSEnumerator *origEnum;
    PajeFilter *inputComponent;
    int minValue;
    int maxValue;
}
+ (ImbricationFilteringEnumerator *)enumeratorWithEnumerator:(NSEnumerator *)e
                                              inputComponent:(PajeFilter *)comp
                                                    minValue:(int)min
                                                    maxValue:(int)max;
- (id)initWithEnumerator:(NSEnumerator *)e
          inputComponent:(PajeFilter *)comp
                minValue:(int)min
                maxValue:(int)max;
- (id)nextObject;
@end
@implementation ImbricationFilteringEnumerator
+ (ImbricationFilteringEnumerator *)enumeratorWithEnumerator:(NSEnumerator *)e
                                              inputComponent:(PajeFilter *)comp
                                                    minValue:(int)min
                                                    maxValue:(int)max
{
    return [[[self alloc] initWithEnumerator:e
                              inputComponent:comp
                                    minValue:min
                                    maxValue:max] autorelease];
}
- (id)initWithEnumerator:(NSEnumerator *)e
          inputComponent:(PajeFilter *)comp
                minValue:(int)min
                maxValue:(int)max
{
    self = [super init];
    if (self) {
        origEnum = [e retain];
        inputComponent = comp;
        minValue = min;
        maxValue = max;
    }
    return self;
}

- (void)dealloc
{
    [origEnum release];
    [super dealloc];
}

- (id)nextObject
{
    id obj;
    while ((obj = [origEnum nextObject]) != nil) {
        int val = [inputComponent imbricationLevelForEntity:obj];
        if (val >= minValue && val <= maxValue)
            break;
    }
    return obj;
}
@end


@implementation InsetLimit

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self) {
        NSWindow *win;

        [self readDefaults];

        if (![NSBundle loadNibNamed:@"InsetLimit" owner:self]) {
            NSRunAlertPanel(@"InsetLimit", @"Couldn't load interface file",
                            nil, nil, nil);
            return self;
        }

        [entityTypePopUp removeAllItems];

        win = [view window];
        
        // view is an NSBox. we need its contents.
        view = [[(NSBox *)view contentView] retain];

        [self registerFilter:self];

#ifndef GNUSTEP
        [win release];
#endif
    }

    return self;
}

- (void)dealloc
{
    [limits release];
    [view release];
    [super dealloc];
}

- (NSView *)filterView
{
    return view;
}

- (NSString *)filterName
{
    return @"Imbrication Limit";
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
    [self calcPopUp];
    [super hierarchyChanged];
}

- (void)calcPopUp
{
    NSEnumerator *typeEnum;
    PajeEntityType *selectedEntityType;
    PajeEntityType *entityType;

    selectedEntityType = [self selectedEntityType];
    [entityTypePopUp removeAllItems];
    typeEnum = [[self allEntityTypes] objectEnumerator];
    while ((entityType = [typeEnum nextObject]) != nil) {
        // only states have indentationLevel
        if ([self drawingTypeForEntityType:entityType]
            == PajeStateDrawingType) {
            [entityTypePopUp addItemWithTitle:[entityType name]];
            [[entityTypePopUp lastItem] setRepresentedObject:entityType];
        }
    }
    if ([entityTypePopUp numberOfItems] > 0) {
        if (selectedEntityType != nil) {
            [entityTypePopUp selectItemWithTitle:[selectedEntityType name]];
        }
        if ([entityTypePopUp selectedItem] == nil) {
            [entityTypePopUp selectItemAtIndex:0];
        }
    }
    [self synchronizeValues];
}

- (void)synchronizeValues
{
    PajeEntityType *selectedEntityType;

    selectedEntityType = [self selectedEntityType];
    if (selectedEntityType == nil) {
        [minField setIntValue:0];
        [maxField setIntValue:0];
        [minField setEnabled:NO];
        [maxField setEnabled:NO];
        [minStepper setEnabled:NO];
        [maxStepper setEnabled:NO];
    } else {
        NSString *value;
        NSRange range;
        value = [limits objectForKey:[selectedEntityType name]];
        if (value) {
            range = [value rangeValue];
        } else {
            range = NSMakeRange(0,0);
        }
        [minField setIntValue:range.location];
        [maxField setIntValue:range.length];
        [minStepper setIntValue:range.location];
        [maxStepper setIntValue:range.length];
        [minField setEnabled:YES];
        [maxField setEnabled:YES];
        [minStepper setEnabled:YES];
        [maxStepper setEnabled:YES];
	[minStepper setValueWraps:NO];
	[maxStepper setValueWraps:NO];
    }
}

- (PajeEntityType *)selectedEntityType
{
    return [[entityTypePopUp selectedItem] representedObject];
}



//
//
//

- (void)readDefaults
{
    NSString *defaultName = [NSStringFromClass([self class]) stringByAppendingString:@" Limits"];
    NSDictionary *limitsDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultName];
    [limits release];
    if (limitsDict != nil)
        limits = [limitsDict mutableCopy];
    else
        limits = [[NSMutableDictionary alloc] init];
}

- (void)registerDefaults
{
    NSString *defaultName = [NSStringFromClass([self class]) stringByAppendingString:@" Limits"];
    [[NSUserDefaults standardUserDefaults] setObject:limits forKey:defaultName];
}


//
// Handle interface messages
//
- (IBAction)entityTypeSelected:(id)sender
{
    [self synchronizeValues];
}

- (void)_valueChanged
{
    PajeEntityType *selectedEntityType;
    NSRange ran;
    selectedEntityType = [self selectedEntityType];
    ran.location = [minField intValue];
    ran.length = [maxField intValue];
    if ((ran.location == 0) && (ran.length == 0)) {
        [limits removeObjectForKey:[selectedEntityType name]];
    } else {
        [limits setObject:[NSString stringWithRange:ran]
                   forKey:[selectedEntityType name]];
    }
    [self registerDefaults];
    [self dataChangedForEntityType:selectedEntityType];
}

- (IBAction)minValueChanged:(id)sender
{
    [minField setIntValue:[sender intValue]];
    [minStepper setIntValue:[sender intValue]];
    [self _valueChanged];
}

- (IBAction)maxValueChanged:(id)sender
{
    [maxField setIntValue:[sender intValue]];
    [maxStepper setIntValue:[sender intValue]];
    [self _valueChanged];
}


//
// interact with interface
//

- (void)viewWillBeSelected:(NSView *)selectedView
// message sent by PajeController when a view will be selected for display
{
    [self synchronizeValues];        
}


//
// Trace messages that are filtered
//

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
{
    NSString *val;
    int min, max;
    NSRange ran;
    NSEnumerator *origEnum;
    origEnum = [inputComponent enumeratorOfEntitiesTyped:entityType
                                             inContainer:container
                                                fromTime:start
                                                  toTime:end];
    val = [limits objectForKey:[entityType name]];
    if (val == nil)
        return origEnum;
    ran = [val rangeValue];
    min = ran.location;
    max = ran.length;
    return [ImbricationFilteringEnumerator enumeratorWithEnumerator:origEnum
                                                     inputComponent:inputComponent
                                                           minValue:min
                                                           maxValue:max];
}


- (int)imbricationLevelForEntity:(PajeEntity *)entity;
{
    int origValue;
    NSString *val;
    NSRange ran;

    origValue = [inputComponent imbricationLevelForEntity:entity];
    val = [limits objectForKey:[[self entityTypeForEntity:entity] name]];

    if (val) {
        ran = [val rangeValue];
        if (origValue > ran.length) origValue = ran.length;
        origValue -= ran.location;
    }
    return origValue;
}


@end
