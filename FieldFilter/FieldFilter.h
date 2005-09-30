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
#ifndef _FieldFilter_h_
#define _FieldFilter_h_

/* FieldFilter.h created by benhur on Sun 26-Dec-2004 */

#include <AppKit/AppKit.h>
#include "../General/FilteredEnumerator.h"
#include "../General/Protocols.h"
#include "../General/PajeFilter.h"

@interface FieldFilter : PajeFilter
{
    NSMutableDictionary *filterDescriptors;
    IBOutlet NSView *view;
    IBOutlet NSPopUpButton *entityTypePopUp;
    IBOutlet NSPopUpButton *fieldNamePopUp;
    IBOutlet NSPopUpButton *comparisionPopUp;
    IBOutlet NSTextField *valueField;
    IBOutlet NSMatrix *actionMatrix;
}

- (id)initWithController:(PajeTraceController *)c;
- (void)dealloc;

- (PajeEntityType *)selectedEntityType;

//
// Handle interface messages
//
- (IBAction)entityTypePopUpChanged:(id)sender;
- (IBAction)fieldNamePopUpChanged:(id)sender;
- (IBAction)comparisionPopUpChanged:(id)sender;
- (IBAction)valueChanged:(id)sender;

//
// interact with interface
//
- (void)viewWillBeSelected:(NSView *)view;


//
// PajeFilter messages that are filtered
//
- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration;
@end

#endif
