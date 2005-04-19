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
#include "ReduceEntity.h"
#include "ReduceEntityType.h"
#include "../General/Macros.h"
#include "../General/NSObject+Additions.h"

@implementation ReduceEntity

+ (ReduceEntity *)entityWithArray:(BusyArray *)a index:(int)i
{
    return [[[self alloc] initWithArray:a index:i] autorelease];
}

- (id)initWithArray:(BusyArray *)a index:(int)i
{
    self = [super initWithType:[a entityType] name:@"" container:[a container]];
    if (self) {
        Assign(array, a);
        index = i;
    }
    // FIXME: temporary solution to get all fields' names
    [[a entityType] addFieldNames:[self fieldNames]];

    return self;
}

+ (PajeDrawingType)drawingType
{
    return PajeVariableDrawingType;
}

- (PajeDrawingType)drawingType
{
    return PajeVariableDrawingType;
}

- (ReduceEntityType *)xentityType
{
    return (ReduceEntityType *)[array entityType];
}

- (NSDate *)startTime
{
    return [[array objectAtIndex:index] time];
}

- (NSDate *)endTime;
{
    return [[array objectAtIndex:index+1] time];
}

- (PajeContainer *)container
{
    return [array container];
}

- (NSString *)name
{
    return [[self value] stringValue];
}

- (NSColor *)color
{
    // FIXME: should color be calculated from value? If so, who keeps the color limits?
    float x;
    x = ([[self value] floatValue] - [[(ReduceEntityType *)[self entityType] minValue] floatValue]);
    x /= ([[(ReduceEntityType *)[self entityType] maxValue] floatValue] - [[(ReduceEntityType *)[self entityType] minValue] floatValue]);
    return [[NSColor blueColor] blendedColorWithFraction:x ofColor:[NSColor redColor]];
}

- (NSArray *)relatedEntities
{
    return [[array objectAtIndex:index] allObjects];
}

+ (void)getMinValue:(NSNumber **)min
           maxValue:(NSNumber **)max
           forArray:(BusyArray *)a
      pajeComponent:(PajeFilter *)filter
{
    NSNumber *minValue = nil;
    NSNumber *maxValue = nil;
    NSNumber *v;
    int i;
    int c;

    c = [a count];
    for (i = 1; i < c; i++) {
        v = [self valueForRelatedEntities:[[a objectAtIndex:i] allObjects]
                            pajeComponent:filter];
        if ((minValue == nil) || ([minValue compare:v] == NSOrderedDescending))
            minValue = v;
        if ((maxValue == nil) || ([maxValue compare:v] == NSOrderedAscending))
            maxValue = v;
    }
    *min = minValue;
    *max = maxValue;
}

// to be implemented by subclasses
- (NSNumber *)value
{
    return [[self class] valueForRelatedEntities:[self relatedEntities]
                                   pajeComponent:[(ReduceEntityType *)[self entityType] component]];
    return nil;
}

// to be implemented by subclasses
+ (NSString *)titleForPopUp
{
    [self subclassResponsibility:_cmd];
    return nil;
}
+ (NSNumber *)valueForRelatedEntities:(NSArray *)entities
                        pajeComponent:(PajeFilter *)filter
{
    [self subclassResponsibility:_cmd];
    return nil;
}
@end

@implementation CountReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Count";
}
+ (NSNumber *)valueForRelatedEntities:(NSArray *)entities
                        pajeComponent:(PajeFilter *)filter
{
    return [NSNumber numberWithInt:[entities count]];
}
@end

@implementation SumReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Sum";
}
+ (NSNumber *)valueForRelatedEntities:(NSArray *)entities
                        pajeComponent:(PajeFilter *)filter
{
    double sum = 0.0;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        sum += [[filter valueForEntity:entity] doubleValue];
    }
    return [NSNumber numberWithDouble:sum];
}
@end
@implementation AverageReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Average";
}
+ (NSNumber *)valueForRelatedEntities:(NSArray *)entities
                        pajeComponent:(PajeFilter *)filter
{
    double sum = 0.0;
    int n=0;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        sum += [[filter valueForEntity:entity] doubleValue];
        n++;
    }
    if (n != 0)
        return [NSNumber numberWithDouble:sum/n];
    else
        return [NSNumber numberWithDouble:sum];
}
@end
@implementation MinReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Min";
}
+ (NSNumber *)valueForRelatedEntities:(NSArray *)entities
                        pajeComponent:(PajeFilter *)filter
{
    NSNumber *val = nil;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        NSNumber *newval;
        newval = [filter valueForEntity:entity];
        if (val == nil || [val compare:newval] == NSOrderedDescending) {
            Assign(val, newval);
        }
    }
    if (val != nil)
        return [val autorelease];
    else
        return [NSNumber numberWithDouble:0];
}
- (NSNumber *)value
{
    if (!xval) Assign(xval, [super value]);
    return xval;
}
- (NSArray *)relatedEntities
{
    NSNumber *val = nil;
    PajeEntity *entity, *me=nil;
    NSEnumerator *entityEnum;

    entityEnum = [[super relatedEntities] objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        NSNumber *newval;
        newval = [[(ReduceEntityType *)[self entityType] component] valueForEntity:entity];
        if (val == nil || [val compare:newval] == NSOrderedDescending) {
            val = newval;
            me = entity;
        }
    }
    if (me != nil)
        return [NSArray arrayWithObject:me];
    else
        return [NSArray array];
}
@end
@implementation MaxReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Max";
}
+ (NSNumber *)valueForRelatedEntities:(NSArray *)entities
                        pajeComponent:(PajeFilter *)filter
{
    NSNumber *val = nil;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        NSNumber *newval;
        newval = [filter valueForEntity:entity];
        if (val == nil || [val compare:newval] == NSOrderedAscending) {
            Assign(val, newval);
        }
    }
    if (val != nil)
        return [val autorelease];
    else
        return [NSNumber numberWithDouble:0];
}
@end
