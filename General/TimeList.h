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
#ifndef _TimeList_h_
#define _TimeList_h_

// 

#include <Foundation/Foundation.h>
#include "PSortedArray.h"
#include "Protocols.h"

@interface TimeList: NSMutableDictionary
{
    NSMutableDictionary *intervalMap; // contains one array for each TIMEINTERVAL
                                      // (depending on -firstTime). Each array
                                      // is ordered by -lastTime.
    NSNumber *firstKey;               // smallest key in map
}

+ timeList;
- init;

- (unsigned)count;
- (id)objectForKey:(id)key;
- (NSEnumerator *)timeEnumeratorFromTime:(NSDate *)start
                                  toTime:(NSDate *)end;
- (void)addObject:(id <PajeTiming>)anObject;
- (void)objectChangedEndTime:(id <PajeTiming>)anObject;
- (id)firstKey;

- (void)removeObjectsBeforeTime:(NSDate *)time;
- (void)removeObjectsAfterTime:(NSDate *)time;
@end

#endif
