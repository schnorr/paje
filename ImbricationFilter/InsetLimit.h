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
#ifndef _InsetLimit_h_
#define _InsetLimit_h_

/* InsetLimit.h created by benhur on 25-feb-2001 */

#include <AppKit/AppKit.h>
#include "../General/FilteredEnumerator.h"
#include "../General/Protocols.h"
#include "../General/PajeFilter.h"

@interface InsetLimit : PajeFilter
{
    NSMutableDictionary *limits;
    IBOutlet NSView *view;
    IBOutlet NSPopUpButton *entityTypePopUp;
    IBOutlet NSTextField *minField;
    IBOutlet NSTextField *maxField;
    IBOutlet NSStepper *minStepper;
    IBOutlet NSStepper *maxStepper;
}

- (id)initWithController:(PajeTraceController *)c;
- (void)dealloc;

// read and write defaults
- (void)readDefaults;
- (void)registerDefaults;


//
// Handle interface messages
//
- (IBAction)entityTypeSelected:(id)sender;
- (IBAction)minValueChanged:(id)sender;
- (IBAction)maxValueChanged:(id)sender;

//
// interact with interface
//
- (void)calcPopUp;
- (void)synchronizeValues;
- (PajeEntityType *)selectedEntityType;

- (void)viewWillBeSelected:(NSView *)view;


//
// methods to filter
//
- (void)hierarchyChanged;
- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end;
- (int)imbricationLevelForEntity:(PajeEntity *)entity;

@end

#endif
