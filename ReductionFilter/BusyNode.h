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
#ifndef _BusyNode_h_
#define _BusyNode_h_

/* BusyNode.h created by benhur on Fri 27-Feb-1998 */

#include <AppKit/AppKit.h>
#include "BusyArray.h"
#include "ReduceEntityType.h"
#include "../General/PajeFilter.h"

@interface BusyNode : PajeFilter
{
    IBOutlet NSBox *view;           // NSBox that contains interface objects
    IBOutlet NSTextField *entityNameField; // name of new entity type
    IBOutlet NSButton *createEntityButton;
    IBOutlet NSButton *renameEntityButton;
    IBOutlet NSButton *deleteEntityButton;
    IBOutlet NSPopUpButton *entityNamePopUp; // name of new entity type
    IBOutlet NSPopUpButton *entityTypePopUp; // select entity type to count
    IBOutlet NSPopUpButton *groupByPopUp; // select grouping
    IBOutlet NSPopUpButton *reduceModePopUp; // select way to reduce
    IBOutlet NSMatrix *nameMatrix; // switches; select event names to count
    NSMutableDictionary *entityTypesDictionary;
    NSMutableSet *reduceEntityTypes;
    NSMutableDictionary *typesContainingReducedTypes;
}

- (id)initWithController:(PajeTraceController *)c;
- (void)dealloc;


//
// default read and write
//
- (void)readDefaults;
- (void)registerDefaults;

//
// update interface
//
- (void)calcEntityTypes;
- (void)calcEntityNamePopUp;
- (void)calcEntityTypePopUp;
- (void)calcGroupPopUp;
- (void)calcReduceModePopUp;
- (void)refreshMatrix;

//
// interaction with interface
//
- (IBAction)createEntityType:(id)sender;
- (IBAction)deleteEntityType:(id)sender;
- (IBAction)renameEntityType:(id)sender;
- (IBAction)entityNamePopUpChanged:(id)sender;
- (IBAction)entityTypePopUpChanged:(id)sender;
- (IBAction)groupByPopUpChanged:(id)sender;
- (IBAction)reduceModePopUpChanged:(id)sender;
- (IBAction)matrixChanged:(id)sender;


//
- (void)calcHierarchy;
- (void)addToHierarchy:(ReduceEntityType *)entityType;

//
// filtering
//
- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration;

@end

#endif
