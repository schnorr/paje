/*
    Copyright (c) 2005 Benhur Stein
    
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

#include "CondensedEntitiesArray.h"
#include "Association.h"
#include "Macros.h"

@implementation CondensedEntitiesArray
+ (CondensedEntitiesArray *)array
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        array = [[NSMutableArray alloc] init];
        sorted = YES;
        totalDuration = 0;
    }
    return self;
}

- (void)dealloc
{
    Assign(array, nil);
    [super dealloc];
}

- (unsigned)count
{
    return [array count];
}

- (void)sort
{
    [array sortUsingSelector:@selector(inverseDoubleValueComparison:)];
    sorted = YES;
}

- (NSString *)nameAtIndex:(unsigned)index
{
    if (!sorted) {
        [self sort];
    }
    return [(Association *)[array objectAtIndex:index] objectValue];
}

- (Association *)associationWithName:(NSString *)name
                             inRange:(NSRange)range
{
    unsigned index;
    unsigned last;
    last = NSMaxRange(range);
    for (index = range.location; index < last; index++) {
        Association *association;
        association = [array objectAtIndex:index];
        if ([[association objectValue] isEqual:name]) {
            return association;
        }
    }
    return nil;
}

// for states
- (void)addName:(NSString *)name duration:(double)duration
{
    Association *association;
    NSRange range;
    
    if (duration == 0) {
        return;
    }

    range = NSMakeRange(0, [array count]);

    association = [self associationWithName:name inRange:range];
    if (association != nil) {
        [association addDouble:duration];
    } else {
        association = [Association associationWithObject:name double:duration];
        [array addObject:association];
    }
    totalDuration += duration;

    sorted = NO;
}

- (double)durationAtIndex:(unsigned)index
{
    if (!sorted) {
        [self sort];
    }
    return [(Association *)[array objectAtIndex:index] doubleValue];
}


// for events
- (void)addName:(NSString *)name count:(unsigned)count
{
    [self addName:name duration:count];
}

- (unsigned)countAtIndex:(unsigned)index
{
    return [self durationAtIndex:index];
}

- (void)addArray:(CondensedEntitiesArray *)other
{
    unsigned count;
    unsigned i;
    NSRange range;
    
    if (other == nil) {
        return;
    }
    
    range = NSMakeRange(0, [array count]);

    count = [other count];
    for (i = 0; i < count; i++) {
        NSString *name;
        double duration;
        Association *association;

        name = [other nameAtIndex:i];
        duration = [other durationAtIndex:i];
        association = [self associationWithName:name inRange:range];
        if (association != nil) {
            [association addDouble:duration];
        } else {
            association = [Association associationWithObject:name
                                                      double:duration];
            [array addObject:association];
        }
    }
    totalDuration += [other totalDuration];

    sorted = NO;
}

- (double)totalDuration
{
    return totalDuration;
}

// NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeValuesOfObjCTypes:"@d", &array, &totalDuration];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self != nil) {
        [coder decodeValuesOfObjCTypes:"@d", &array, &totalDuration];
        sorted = NO;
    }
    return self;
}
@end
