/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
#include "ReduceEntityType.h"
#include "ReduceEntity.h"
#include "../General/Macros.h"
#include "../General/NSUserDefaults+Additions.h"

#include <math.h>

@implementation ReduceEntityType

+ (ReduceEntityType *)typeFromDictionary:(NSDictionary *)dict
                               component:(PajeFilter *)comp
{
    ReduceEntityType *newType;
    NSString *n;
    PajeContainerType *cont;
    PajeEntityType *red;
    NSEnumerator *en;
    NSString *nameToFilter;
    Class reductionClass;

    cont = (PajeContainerType *)[comp entityTypeWithName:[dict objectForKey:@"ContainerType"]];
    if (cont == nil)
        return nil;

    red = [comp entityTypeWithName:[dict objectForKey:@"EntityTypeToReduce"]];
    if (red == nil)
        return nil;
    
    n = [dict objectForKey:@"EntityName"];
    if (n == nil)
        return nil;

    newType = [self typeWithName:n
                   containerType:cont
                       component:comp];
    if (newType == nil)
        return nil;

    [newType setEntityTypeToReduce:red];

    reductionClass = NSClassFromString([dict objectForKey:@"ReductionClass"]);
    if (reductionClass == Nil) {
        reductionClass = [CountReduceEntity class];
    }
    [newType setEntityClass:reductionClass];

    en = [[dict objectForKey:@"ValuesToFilter"] objectEnumerator];
    while ((nameToFilter = [en nextObject]) != nil) {
        [newType addValueToFilter:nameToFilter];
    }
    return newType;
}

+ (ReduceEntityType *)typeWithName:(NSString *)n
                     containerType:(PajeContainerType *)cont
                         component:(PajeFilter *)comp
{
    return [[[self alloc] initWithName:n
                         containerType:cont
                             component:comp] autorelease];
}

- (id)initWithName:(NSString *)n
     containerType:(PajeContainerType *)type
         component:(PajeFilter *)comp
{
    // super adds self as a subtype of containertype.
    // call init with nil as containerType so as to not do that;
    // initialize containerType after it.
    self = [super initWithName:n containerType:nil event:nil];
    if (self != nil) {
        containerType = type;
        component = comp;
        filterValues = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    Assign(filterValues, nil);
    Assign(entityTypeToReduce, nil);
    Assign(array, nil);
    [super dealloc];
}

- (PajeFilter *)component
{
    return component;
}

- (NSDictionary *)dictionaryForDefaults
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [self name], @"EntityName",
        [[self containerType] name], @"ContainerType",
        [[self entityTypeToReduce] name], @"EntityTypeToReduce",
        [filterValues allObjects], @"ValuesToFilter",
        NSStringFromClass(entityClass), @"ReductionClass",
        nil];
}

- (void)setName:(NSString *)n
{
    Assign(name, n);
}

- (void)setContainerType:(PajeContainerType *)newContainerType
{
    NSString *defaultName;

    Assign(containerType, newContainerType);

    defaultName = [[self name] stringByAppendingString:@"ContainerType"];
    [[NSUserDefaults standardUserDefaults] setObject:[containerType name]
                                              forKey:defaultName];

    minValue = HUGE_VAL;
    maxValue = -HUGE_VAL;
    Assign(array, nil);
}

- (void)setEntityClass:(Class)c
{
    entityClass = c;
    minValue = HUGE_VAL;
    maxValue = -HUGE_VAL;
    if (array != nil) {
        [entityClass getMinValue:&minValue
                        maxValue:&maxValue
                        forArray:array
                   pajeComponent:component];
    }
}

- (Class)entityClass
{
    return entityClass;
}

- (PajeDrawingType)drawingType
{
    return PajeVariableDrawingType;
}

- (void)setEntityTypeToReduce:(PajeEntityType *)newEntityTypeToReduce
{
    Assign(entityTypeToReduce, newEntityTypeToReduce);

    [filterValues removeAllObjects];
    Assign(array, nil);
    minValue = HUGE_VAL;
    maxValue = -HUGE_VAL;
}

- (PajeEntityType *)entityTypeToReduce
{
    return entityTypeToReduce;
}

- (void)addValueToFilter:(id)value
{
    [filterValues addObject:value];
    Assign(array, nil);
    minValue = HUGE_VAL;
    maxValue = -HUGE_VAL;
}

- (void)addValuesToFilter:(NSArray *)values
{
    [filterValues addObjectsFromArray:values];
    Assign(array, nil);
    minValue = HUGE_VAL;
    maxValue = -HUGE_VAL;
}

- (void)removeValueFromFilter:(id)value
{
    [filterValues removeObject:value];
    Assign(array, nil);
    minValue = HUGE_VAL;
    maxValue = -HUGE_VAL;
}

- (NSSet *)filterValues
{
    return filterValues;
}


- (NSEnumerator *)enumeratorOfEntitiesInContainer:(PajeContainer *)container
                                         fromTime:(NSDate *)start
                                           toTime:(NSDate *)end
                                      minDuration:(double)minDuration
{
    NSEnumerator *origEnum;
    double min;
    double max;
    BOOL limitsChanged = NO;

    if (array != nil
        && [container isEqual:[array container]]
        && ![start isEarlierThanDate:[array startTime]]
        && ![end isLaterThanDate:[array endTime]]) {
        return [array reverseObjectEnumeratorOfClass:entityClass
                                            fromTime:start
                                              toTime:end];
    }

    if (array != nil) [array release];
    origEnum = [component enumeratorOfEntitiesTyped:entityTypeToReduce
                                        inContainer:container
                                           fromTime:start
                                             toTime:end
                                        minDuration:0];
    array = [[BusyArray alloc] initWithEntityType:self
                                        container:container
                                        startTime:start
                                          endTime:end
                                       enumerator:origEnum
                                      valueFilter:filterValues];

    [entityClass getMinValue:&min
                    maxValue:&max
                    forArray:array
               pajeComponent:component];
    if (min < minValue) {
        minValue = min;
        limitsChanged = YES;
    }
    if (max > maxValue) {
        maxValue = max;
        limitsChanged = YES;
    }
    if (limitsChanged) {
        [component limitsChangedForEntityType:self];
    }

    return [array reverseObjectEnumeratorOfClass:entityClass];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesInContainer:(PajeContainer *)container
                                                 fromTime:(NSDate *)start
                                                   toTime:(NSDate *)end
                                              minDuration:(double)minDuration
{
    NSEnumerator *origEnum;
    double min;
    double max;
    BOOL limitsChanged = NO;

    if (array != nil
        && [container isEqual:[array container]]
        && ![start isEarlierThanDate:[array startTime]]
        && ![end isLaterThanDate:[array endTime]]) {
        return [array completeObjectEnumeratorOfClass:entityClass
                                             fromTime:start
                                               toTime:end];
    }

    if (array != nil) [array release];
    origEnum = [component enumeratorOfEntitiesTyped:entityTypeToReduce
                                        inContainer:container
                                           fromTime:start
                                             toTime:end
                                        minDuration:0];
    array = [[BusyArray alloc] initWithEntityType:self
                                        container:container
                                        startTime:start
                                          endTime:end
                                       enumerator:origEnum
                                      valueFilter:filterValues];

    [entityClass getMinValue:&min
                    maxValue:&max
                    forArray:array
               pajeComponent:component];
    if (min < minValue) {
        minValue = min;
        limitsChanged = YES;
    }
    if (max > maxValue) {
        maxValue = max;
        limitsChanged = YES;
    }
    if (limitsChanged) {
        [component limitsChangedForEntityType:self];
    }

    return [array completeObjectEnumeratorOfClass:entityClass
                                         fromTime:start
                                           toTime:end];
}
@end
