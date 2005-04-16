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
// 

#include "TimeList.h"
#include "Comparing.h"
#include "NSDate+Additions.h"

static double TimeListInterval = 0.0;
//#define TIMEINTERVAL    10000.0        // seconds in each array
#define TIMEtoKEY(time)                             \
[NSNumber numberWithInt:(int)([time timeIntervalSinceReferenceDate]/TimeListInterval/*TIMEINTERVAL*/)]

@interface TimeListEnumerator : NSEnumerator
{
    TimeList       *timeList;
    NSDate         *start, *end; // time limits of enumeration
    NSNumber       *key, *endKey;// key to current and last subarrays in timeList
    PSortedArray   *subarray;    // where we are currently taking objs from
    NSEnumerator   *enumerator;  // enumerator in this subarray
}
@end

@implementation TimeListEnumerator

- (id)initWithList:(TimeList *)list
          fromTime:(id)time1
            toTime:(id)time2
{
    [super init];
    timeList = [list retain];
    start = [time1 retain];
    end = [time2 retain];
    key = [[list firstKey] retain];
    endKey = [TIMEtoKEY(end) retain];
    enumerator = nil;
    return self;
}

- (void)dealloc
{
    [timeList release];
    [start release];
    [end release];
    [key release];
    [endKey release];
    [enumerator release];
    [super dealloc];
}

int delta_a_ctr;
double delta_a_time;
NSDate *delta_a_t0;
- (id)nextObject
// returns the next obj in array that doesn't end before the start of
// the enumeration nor starts after its end
{
    id<PajeTiming> obj;
    id oldKey;

    // if list is empty, key == nil
    if (key == nil) {
        return nil;
    }
    
    while (1) {
        // search in current subarray
        while (enumerator) {
            obj = [enumerator nextObject];
            if (obj == nil) {
                [enumerator release];
                enumerator = nil;
                continue;
            }
            // good if obj doesn't start after end
            if ([[obj firstTime] earlierDate:end] != end) {
                return obj;
            }
        }

//        delta_a_t0 = [NSDate new];
        // find next subarray
        do {
            // if next subarray starts after end of search, we're done
            if ([key compare:endKey] == NSOrderedDescending) // key > endKey
                return nil;
            
            // take next subarray
            subarray = [timeList objectForKey:key];
            oldKey = key;
            // this could be better done with an (ordered) enumerator of keys.
            key = [[NSNumber alloc] initWithInt:[oldKey intValue]+1];
            [oldKey release];
        } while (!subarray);
//        delta_a_time -= [delta_a_t0 timeIntervalSinceNow];
//        delta_a_ctr++;
//        if ((delta_a_ctr % 100)==0)
//            NSLog(@"DELTA_A: %d %f", delta_a_ctr, delta_a_time);
//        [delta_a_t0 release];
        
        // initialize enumerator for elements that end after start.
        enumerator = [[subarray objectEnumeratorAfterValue:(id<Comparing>)start] retain];
    }
    // NEVER REACHED
    return nil;
}

@end


@implementation TimeList;

- init
{
    if (TimeListInterval == 0.0) {
        TimeListInterval = [[[NSUserDefaults standardUserDefaults] stringForKey:@"TimeListInterval"] doubleValue];
        if (TimeListInterval == 0.0) {
            TimeListInterval = 10.0;
        }
    }
    intervalMap = [[NSMutableDictionary alloc] init];
    firstKey = nil;
    return self;
}

+ timeList
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    [intervalMap release];
    [firstKey release];
    [super dealloc];
}

- (unsigned) count
{
    return [intervalMap count];
}

- (id)objectForKey:(id)key
{
    return [intervalMap objectForKey:key];
}

- (NSEnumerator *)keyEnumerator
{
    return [intervalMap keyEnumerator];
}

- (void)addObject:(id <PajeTiming>)anObject
// insert anObject in the list.
// finds the right array to put it (depending on its firstTime),
// and inserts it in this array, in the order of its lastTime.
{
    id start = [anObject firstTime];
    id key = TIMEtoKEY(start);
    PSortedArray *array = [intervalMap objectForKey:key];
    
    // if we don't have the corresponding array to this firstTime, insert it.
    if (!array) {
        array = [PSortedArray sortedArrayWithSelector:@selector(lastTime)];
        [intervalMap setObject:array forKey:key];
        if (!firstKey || [firstKey compare:key] == NSOrderedDescending) {
            id oldKey = firstKey;
            firstKey = [key retain];
            [oldKey release];
        }
    }

    [array addObject:anObject];
}

- (void)objectChangedEndTime:(id <PajeTiming>)anObject
// must check if anObject should change its place
{
    id start = [anObject firstTime];
    id key = TIMEtoKEY(start);
    PSortedArray *array = [intervalMap objectForKey:key];

    // if we don't have the corresponding array to this firstTime, log.
    if (!array) {
        NSDebugMLog(@"object %@ not found while changing endTime");
        return;
    }

    [array verifyPositionOfObjectIdenticalTo:anObject];
}


- (id)firstKey
{
    return firstKey;
}

- (NSEnumerator *)timeEnumeratorFromTime:(id)start
                                  toTime:(id)end;
{
    return [[[TimeListEnumerator alloc]
                    initWithList:self
                        fromTime:start
                          toTime:end]
        autorelease];
}

- (void)removeObjectsBeforeTime:(NSDate *)time
// remove all objects whose lastTime is before time.
{
    NSEnumerator *e;
    id k;
    PSortedArray *array;

    e = [intervalMap keyEnumerator];
    while ((k = [e nextObject]) != nil) {
        array = [intervalMap objectForKey:k];
        [array removeObjectsBeforeValue:(id<Comparing>)time];
        if ([array count] == 0) {
            if ([k isEqual:firstKey]) {
                [firstKey release];
                firstKey = nil;
            }
            [intervalMap removeObjectForKey:k];
        }
    }
    if (nil == firstKey) {
        e = [intervalMap keyEnumerator];
        while ((k = [e nextObject]) != nil) {
            if (nil == firstKey || [k isLessThan:firstKey]) {
                [firstKey release];
                firstKey = [k retain];
            }
        }
    }
}

- (void)removeObjectsAfterTime:(NSDate *)time
// remove all objects whose firstTime is after time
{
    id key = TIMEtoKEY(time);
    PSortedArray *array;
    int count, i;
    NSEnumerator *e;
    id k;

    array = [intervalMap objectForKey:key];
    if (array) {
        count = [array count];
        for (i=0; i<count;) {
            if ([[[array objectAtIndex:i] firstTime] earlierDate:time] == time) {
                [array removeObjectAtIndex:i];
                count--;
            } else
                i++;
        }
        if ([array count] == 0) {
            [intervalMap removeObjectForKey:key];
        }
    }
    
    // remove all subarrays whose key is greater than key
    e = [intervalMap keyEnumerator];
    while ((k = [e nextObject]) != nil) {
        if ([k isGreaterThan:key]) {
            [intervalMap removeObjectForKey:k];
        }
    }

    if ([intervalMap count] == 0) {
        [firstKey release];
        firstKey = nil;
    }
}
@end

