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
#include "ReduceEntityType.h"
#include "ReduceEntity.h"
#include "../General/Macros.h"

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
    if (reductionClass == Nil)
        reductionClass = [CountReduceEntity class];
    [newType setEntityClass:reductionClass];

    en = [[dict objectForKey:@"NamesToFilter"] objectEnumerator];
    while ((nameToFilter = [en nextObject]) != nil) {
        [newType addNameToFilter:nameToFilter];
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
    // init has been copied from super so as to not do that
    if (self == [super init]) {
        NSColor *c;
        Assign(name, n);
        containerType = type;
//	[containerType addContainedType:self];
        c = [[NSUserDefaults standardUserDefaults] colorForKey:[name stringByAppendingString:@" Color"]];
        if (c)
            Assign(color, c);
        else
            Assign(color, [NSColor blackColor]);
        component = comp;
        filterNames = [[NSMutableSet alloc] init];
    }
    return self;
    self = [super initWithName:n containerType:type];
    if (self) {
        component = comp;
        filterNames = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    Assign(filterNames, nil);
    Assign(entityTypeToReduce, nil);
    Assign(array, nil);
    Assign(minValue, nil);
    Assign(maxValue, nil);
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
        [filterNames allObjects], @"NamesToFilter",
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

    Assign(minValue, nil);
    Assign(maxValue, nil);
    Assign(array, nil);
}

- (void)setEntityClass:(Class)c
{
    entityClass = c;
    Assign(minValue, nil);
    Assign(maxValue, nil);
    if (array != nil) {
        [c getMinValue:&minValue maxValue:&maxValue forArray:array pajeComponent:component];
        [minValue retain];
        [maxValue retain];
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

    [filterNames removeAllObjects];
    Assign(array, nil);
    Assign(minValue, nil);
    Assign(maxValue, nil);
}
- (PajeEntityType *)entityTypeToReduce
{
    return entityTypeToReduce;
}

- (void)addNameToFilter:(NSString *)n
{
    [filterNames addObject:n];
    Assign(array, nil);
    Assign(minValue, nil);
    Assign(maxValue, nil);
}
- (void)addNamesToFilter:(NSArray *)names
{
    [filterNames addObjectsFromArray:names];
    Assign(array, nil);
    Assign(minValue, nil);
    Assign(maxValue, nil);
}

- (void)removeNameFromFilter:(NSString *)n
{
    [filterNames removeObject:n];
    Assign(array, nil);
    Assign(minValue, nil);
    Assign(maxValue, nil);
}
- (NSSet *)filterNames
{
    return filterNames;
}

- (NSNumber *)minValue
{
    return minValue;
}

- (NSNumber *)maxValue
{
    return maxValue;
}


- (NSEnumerator *)enumeratorOfEntitiesInContainer:(PajeContainer *)container
                                         fromTime:(NSDate *)start
                                           toTime:(NSDate *)end
{
    NSEnumerator *origEnum;
    NSNumber *min;
    NSNumber *max;
    BOOL limitsChanged = NO;

    if (array != nil
        && [container isEqual:[array container]]
        && ![start isEarlierThanDate:[array startTime]]
        && ![end isLaterThanDate:[array endTime]]) {
        return [array objectEnumeratorOfClass:entityClass
                                     fromTime:start toTime:end];
    }

    if (array) [array release];
    origEnum = [component enumeratorOfEntitiesTyped:entityTypeToReduce
                                        inContainer:container
                                           fromTime:start
                                             toTime:end];
    array = [[BusyArray alloc] initWithEntityType:self
                                        container:container
                                        startTime:start
                                          endTime:end
                                       enumerator:origEnum
                                       nameFilter:filterNames];

    [entityClass getMinValue:&min maxValue:&max forArray:array pajeComponent:component];
    if ((minValue == nil) || ([minValue compare:min] == NSOrderedDescending)) {
        Assign(minValue, min);
        limitsChanged = YES;
    }
    if ((maxValue == nil) || ([maxValue compare:max] == NSOrderedAscending)) {
        Assign(maxValue, max);
        limitsChanged = YES;
    }
    if (limitsChanged)
        [component dataChangedForEntityType:self];

    return [array objectEnumeratorOfClass:entityClass];
}
@end
