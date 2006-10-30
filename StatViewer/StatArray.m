/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
/* StatArray.m created by benhur on Fri 26-Sep-1997 */

#include "StatArray.h"
#include "../General/Macros.h"

@interface StatStateArray : StatArray
{
    CondensedEntitiesArray *condensedArray;
    NSDate *startTime;
    NSDate *endTime;
}

- (id)initWithName:(NSString *)theName
              type:(PajeEntityType *)type
         startTime:(NSDate *)start
           endTime:(NSDate *)end
            filter:(PajeFilter *)f
  entityEnumerator:(NSEnumerator *)en;

- (void)addEntitiesFromEnumerator:(NSEnumerator *)enumerator;
@end

@implementation StatArray

+ (StatArray *)stateArrayWithName:(NSString *)theName
                             type:(PajeEntityType *)type
                        startTime:(NSDate *)start
                          endTime:(NSDate *)end
                           filter:(PajeFilter *)f
                 entityEnumerator:(NSEnumerator *)en
{
    return [[[StatStateArray alloc] initWithName:theName
                                            type:type
                                       startTime:start
                                         endTime:end
                                          filter:f
                                entityEnumerator:en] autorelease];
}

- (id)initWithName:(NSString *)theName
              type:(PajeEntityType *)type
            filter:(PajeFilter *)f
{
    self = [super init];
    if (self != nil) {
        Assign(name, theName);
        Assign(entityType, type);
        filter = f;
    }
    return self;
}

- (void)dealloc
{
    Assign(name, nil);
    Assign(entityType, nil);
    [super dealloc];
}

- (NSString *)name
{
    return name;
}

- (double)totalValue
{
    [self subclassResponsibility:_cmd];
    return 0;
}

- (double)maxValue
{
    [self subclassResponsibility:_cmd];
    return 0;
}

- (double)minValue
{
    [self subclassResponsibility:_cmd];
    return 0;
}

- (unsigned)subCount
{
    [self subclassResponsibility:_cmd];
    return 0;
}

- (id)subValueAtIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
    return nil;
}

- (NSColor *)subColorAtIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
    return nil;
}

- (double)subDoubleValueAtIndex:(unsigned)index
{
    [self subclassResponsibility:_cmd];
    return 0;
}

@end



@implementation StatStateArray
- (id)initWithName:(NSString *)theName
              type:(PajeEntityType *)type
         startTime:(NSDate *)start
           endTime:(NSDate *)end
            filter:(PajeFilter *)f
  entityEnumerator:(NSEnumerator *)en
{
    self = [super initWithName:theName
                          type:type
                        filter:f];
    if (self != nil) {
        Assign(startTime, start);
        Assign(endTime, end);
        condensedArray = [[CondensedEntitiesArray alloc] init];
        [self addEntitiesFromEnumerator:en];
    }
    return self;
}

- (void)dealloc
{
    Assign(condensedArray, nil);
    Assign(startTime, nil);
    Assign(endTime, nil);
    [super dealloc];
}


- (void)addEntitiesFromEnumerator:(NSEnumerator *)enumerator
{
    PajeEntity *entity;
    int top = -1;
    BOOL incomplete[100];
    NSDate *start[100];
    NSString *names[100];
    double duration[100];

    while ((entity = [enumerator nextObject]) != nil) {
        NSDate *entityStart;
        NSDate *entityEnd;
        BOOL entityIsAggregate;
        BOOL entityIsIncomplete;
        double entityDuration;
        double entityDurationInSelection;
        
        entityStart = [filter startTimeForEntity:entity];
        entityEnd = [filter endTimeForEntity:entity];
        if ([entityStart isLaterThanDate:endTime]
            || [entityEnd isEarlierThanDate:startTime]) {
            continue;
        }
        //entityDuration = [filter durationForEntity:entity];
        entityDuration = [entity duration];
        entityIsAggregate = [filter isAggregateEntity:entity];
        
        while (top >= 0 && [entityEnd isEarlierThanDate:start[top]]) {
            if (incomplete[top] && duration[top] > 0) {
                [condensedArray addValue:names[top]
                                duration:duration[top]];
            }
            top--;
        }

        entityIsIncomplete = NO;
        entityDurationInSelection = entityDuration;
        if ([entityStart isEarlierThanDate:startTime]) {
            entityIsIncomplete = YES;
            entityDurationInSelection
                              -= [startTime timeIntervalSinceDate:entityStart];
        }
        if ([entityEnd isLaterThanDate:endTime]) {
            entityIsIncomplete = YES;
            entityDurationInSelection
                              -= [entityEnd timeIntervalSinceDate:endTime];
        }
        
        if (!entityIsAggregate) {
            id entityValue;
            entityValue = [filter valueForEntity:entity];

            if (top >= 0 && incomplete[top]) {
                duration[top] -= entityDurationInSelection;
            }
            top++;
            incomplete[top] = entityIsIncomplete;
            start[top] = entityStart;
            if (entityIsIncomplete) {
                names[top] = entityValue;
                duration[top] = entityDurationInSelection;
            } else {
                double entityExclusiveDuration;
                //entityExclusiveDuration = [filter exclusiveDurationForEntity:entity];
                entityExclusiveDuration = [entity exclusiveDuration];
                [condensedArray addValue:entityValue
                                duration:entityExclusiveDuration];
            }
            //condensedEntitiesCount ++;
        } else {
            double correctionFactor;
            double correctedDuration;
            double entityExclusiveDuration;
            //entityExclusiveDuration = [filter exclusiveDurationForEntity:entity];
            entityExclusiveDuration = [entity exclusiveDuration];
            correctionFactor = entityDurationInSelection / entityDuration;
            correctedDuration = (entityDuration - entityExclusiveDuration)
                              * correctionFactor;
            if (correctedDuration > entityDurationInSelection) {
                correctedDuration = entityDurationInSelection;
            }
            if (top >= 0 && incomplete[top]) {
                duration[top] -= correctedDuration;
            }
            // BUG: should be corrected by correctionFactor
            [condensedArray addArray:[entity condensedEntities]];
            //[condensedArray addArray:[filter condensedEntitiesForEntity:entity]];
            //condensedEntitiesCount += [entity condensedEntitiesCount];
        }
        
    }
    while (top >= 0) {
        if (incomplete[top]
            && duration[top]/[endTime timeIntervalSinceDate:startTime] > 1e-5) {
            [condensedArray addValue:names[top]
                            duration:duration[top]];
        }
        top--;
    }
}


- (double)totalValue
{
    return [endTime timeIntervalSinceDate:startTime];
}

- (double)maxValue
{
    return [self subDoubleValueAtIndex:0];
}

- (double)minValue
{
    return [self subDoubleValueAtIndex:[self subCount] - 1];
}


- (unsigned)subCount
{
    return [condensedArray count];
}

- (id)subValueAtIndex:(unsigned)i
{
    return [condensedArray valueAtIndex:i];
}

- (NSColor *)subColorAtIndex:(unsigned)i
{
    return [filter colorForValue:[condensedArray valueAtIndex:i]
                    ofEntityType:entityType];
}

- (double)subDoubleValueAtIndex:(unsigned)i
{
    return [condensedArray durationAtIndex:i];
}
@end
