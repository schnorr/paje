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
#ifndef _BusyArray_h_
#define _BusyArray_h_

// BusyArray
//
// Array that keeps an ordered list (by time) of the occupation
// of a node, with a BusyDate for each time, representing how many
// threads (and which states) were busy between that time and the
// next time of the list. Receives PStates as input objects.
// Its enumerator returns PStates created to represent each of these
// time slices.

// 19980227 BS  creation

#include <Foundation/Foundation.h>
#include "../General/PSortedArray.h"
#include "BusyDate.h"
#include "../General/PajeContainer.h"

@interface BusyArray : PSortedArray
{
    PajeContainer *container;  // not retained
    PajeEntityType *entityType;
}

- (id)initWithEntityType:(PajeEntityType *)et
               container:(PajeContainer *)cont
               startTime:(NSDate *)startTime
                 endTime:(NSDate *)endTime;
- (id)initWithEntityType:(PajeEntityType *)et
               container:(PajeContainer *)cont
               startTime:(NSDate *)startTime
                 endTime:(NSDate *)endTime
              enumerator:(NSEnumerator *)enumerator
              nameFilter:(NSSet *)filter;

- (void)dealloc;

- (void)addEntity:(PajeEntity *)entity;

- (NSEnumerator *)objectEnumeratorOfClass:(Class)c;
- (NSEnumerator *)objectEnumeratorOfClass:(Class)c
                                 fromTime:(NSDate *)t1
                                   toTime:(NSDate *)t2;
- (NSEnumerator *)reverseObjectEnumeratorOfClass:(Class)c;
- (NSEnumerator *)reverseObjectEnumeratorOfClass:(Class)c
                                        fromTime:(NSDate *)t1
                                          toTime:(NSDate *)t2;

- (PajeContainer *)container;
- (PajeEntityType *)entityType;
- (NSDate *)startTime;
- (NSDate *)endTime;
@end

#endif
