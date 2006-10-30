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

#include <math.h>

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

- (void)dealloc
{
    Assign(array, nil);
    [super dealloc];
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
    return [NSString stringWithFormat:@"%f", [self doubleValue]];
}

- (id)value
{
    return [NSString stringWithFormat:@"%f", [self doubleValue]];
}

- (NSColor *)color
{
    // FIXME: should color be calculated from value? If so, who keeps the color limits?
    float x;
    x = ([self doubleValue] - [[self entityType] minValue]);
    x /= ([[self entityType] maxValue] - [[self entityType] minValue]);
    return [[NSColor blueColor] blendedColorWithFraction:x
                                                 ofColor:[NSColor redColor]];
}

- (NSArray *)relatedEntities
{
    return [[array objectAtIndex:index] allObjects];
}

+ (void)getMinValue:(double *)min
           maxValue:(double *)max
           forArray:(BusyArray *)a
      pajeComponent:(PajeFilter *)filter
{
    double minValue = HUGE_VAL;
    double maxValue = -HUGE_VAL;
    double v;
    int i;
    int c;

    c = [a count];
    for (i = 1; i < c; i++) {
        v = [self valueForRelatedEntities:[[a objectAtIndex:i] allObjects]
                            pajeComponent:filter];
        if (v < minValue) {
            minValue = v;
        }
        if (v > maxValue) {
            maxValue = v;
        }
    }
    *min = minValue;
    *max = maxValue;
}

// to be implemented by subclasses
- (double)doubleValue
{
    return [[self class] valueForRelatedEntities:[self relatedEntities]
                                   pajeComponent:[(ReduceEntityType *)[self entityType] component]];
}

// to be implemented by subclasses
+ (NSString *)titleForPopUp
{
    [self subclassResponsibility:_cmd];
    return nil;
}
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter
{
    [self subclassResponsibility:_cmd];
    return 0.0;
}
@end

@implementation CountReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Count";
}
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter
{
    return (double)[entities count];
}
@end

@implementation SumReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Sum";
}
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter
{
    double sum = 0.0;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        sum += [filter doubleValueForEntity:entity];
    }
    return sum;
}
@end
@implementation AverageReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Average";
}
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter
{
    double sum = 0.0;
    int n = 0;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        sum += [filter doubleValueForEntity:entity];
        n++;
    }
    if (n == 0) {
        return 0.0;
    } else {
        return sum/n;
    }
}
@end
@implementation MinReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Min";
}
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter
{
    double val = HUGE_VAL;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        double newval;
        newval = [filter doubleValueForEntity:entity];
        if (newval < val) {
            val = newval;
        }
    }
    return val;
}
- (double)doubleValue
{
    if (xval == HUGE_VAL) {
        xval = [super doubleValue];
    }
    return xval;
}
- (NSArray *)relatedEntities
{
    double val = HUGE_VAL;
    PajeEntity *entity;
    NSEnumerator *entityEnum;
    NSMutableArray *a = [NSMutableArray array];

    entityEnum = [[super relatedEntities] objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        double newval;
        newval = [[(ReduceEntityType *)[self entityType] component] doubleValueForEntity:entity];
        if (newval < val) {
            val = newval;
            [a removeAllObjects];
            [a addObject:entity];
        } else if (newval == val) {
            [a addObject:entity];
        }
    }
    return a;
}
@end
@implementation MaxReduceEntity
+ (NSString *)titleForPopUp
{
    return @"Max";
}
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter
{
    double val = -HUGE_VAL;
    PajeEntity *entity;
    NSEnumerator *entityEnum;

    entityEnum = [entities objectEnumerator];
    while ((entity = [entityEnum nextObject]) != nil) {
        double newval;
        newval = [filter doubleValueForEntity:entity];
        if (newval > val) {
            val = newval;
        }
    }
    return val;
}
@end
