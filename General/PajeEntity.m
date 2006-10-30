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
// PajeEntity
//
// Generic entities for Paje
//

#include "PajeEntity.h"
#include "PajeContainer.h"
#include "PajeEntityInspector.h"
#include "Macros.h"
#include "UniqueString.h"

@implementation PajeEntity
- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
         container:(PajeContainer *)c
{
    self = [super init];
    if (self != nil) {
        entityType = type;     // not retained
        Assign(name, U(n));
        container = c;         // not retained
    }
    return self;
}

- (void)dealloc
{
    // container and entityType are not retained
    Assign(name, nil);
    [super dealloc];
}

- (BOOL)isContainer
{
    return NO;
}

- (PajeDrawingType)drawingType
{
    return [entityType drawingType];
}

- (NSString *)name
{
    return name;
}

- (id)value
{
    return name;
}

- (PajeEntityType *)entityType
{
    return entityType;
}

- (PajeContainer *)container
{
    return container;
}

- (PajeContainer *)sourceContainer
{
    return [self container];
}

- (PajeContainer *)destContainer
{
    return [self container];
}

- (void)setContainer:(PajeContainer *)c
{
    container = c;
}

- (void)setEntityType:(PajeEntityType *)type
{
        entityType = type;
}

- (BOOL)isContainedBy:(PajeContainer *)cont
{
    if ((container == nil)) {
        return NO;
    }

    if ([cont isEqual:container]) {
        return YES;
    }

    if ([[cont entityType] isEqual:[container entityType]]) {
        return NO;
    }

    return [container isContainedBy:cont];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [%@ in %@-%@]",
        [self valueOfFieldNamed:@"Value"], [self entityType], [self startTime],
        [self endTime]];
    return [NSString stringWithFormat:@"%@ [%@ in %@ %@]",
        [self name], [self entityType],
        [[self container] entityType], [self container]];
    return [name description];
//    return [[NSDictionary dictionaryWithObjectsAndKeys:entityType, @"Type",
//    name, @"Name", container, @"Container", nil] description];
}

- (NSDate *)time
{
    [self _subclassResponsibility:_cmd];
    return nil;
}
- (NSDate *)startTime
{
    return [self time];
}
- (NSDate *)endTime
{
    return [self time];
}
- (NSDate *)firstTime
{
    return [[self startTime] earlierDate:[self endTime]];
}
- (NSDate *)lastTime
{
    return [[self startTime] laterDate:[self endTime]];
}

- (double)duration
{
    return [[self endTime] timeIntervalSinceDate:[self startTime]];
}

- (double)exclusiveDuration
{
    return [self duration];
}

- (BOOL)isAggregate
{
    return NO;
}

- (unsigned)subCount
{
    return 0;
}

- (id)subValueAtIndex:(unsigned)index
{
    return [self value];
}

- (NSColor *)subColorAtIndex:(unsigned)index
{
    return [self color];
}

- (double)subDurationAtIndex:(unsigned)index
{
    return [self duration];
}

- (unsigned)subCountAtIndex:(unsigned)index
{
    return 1;
}

- (CondensedEntitiesArray *)condensedEntities
{
    return nil;
}

- (unsigned)condensedEntitiesCount
{
    return 0;
}

- (NSColor *)color
{
    id value = [self value];
    NSColor *c = [entityType colorForValue:value];
    if (!c) {
        c = [NSColor yellowColor];
        [entityType setColor:c forValue:value];
    }
    return c;
}

- (void)setColor:(NSColor *)c
{
    [entityType setColor:c forValue:[self value]];
}

- (void)takeColorFrom:(id)sender
{
    [self setColor:[sender color]];
}

- (NSArray *)relatedEntities
{
    return [NSArray array];
}

- (int)imbricationLevel
{
    return 0;
}

- (double)doubleValue
{
    return 0.0;
}

- (double)minValue
{
    return 0.0;
}

- (double)maxValue
{
    return 0.0;
}

- (NSArray *)fieldNames
{
    return [NSMutableArray arrayWithObjects:
        @"EntityType", @"Name", @"Value", @"Container",
        @"StartTime", @"EndTime", @"Duration",
        nil];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    if ([fieldName isEqualToString:@"EntityType"]) {
        return [self entityType];
    } else if ([fieldName isEqualToString:@"Name"]) {
        return [self name];
    } else if ([fieldName isEqualToString:@"Value"]) {
        return [self value];
    } else if ([fieldName isEqualToString:@"Container"]) {
        return [self container];
    } else if ([fieldName isEqualToString:@"StartTime"]) {
        return [self startTime];
    } else if ([fieldName isEqualToString:@"EndTime"]) {
        return [self endTime];
    } else if ([fieldName isEqualToString:@"Duration"]) {
        return [NSNumber numberWithDouble:[self duration]];
    } else {
        return nil;
    }
}

- (NSComparisonResult)compare:(id)other
{
    return [[self name] compare:[(PajeEntity *)other name]];
}

- (unsigned)hash
{
    return [name hash];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) return YES;
    if (![other isKindOfClass:[PajeEntity class]]) return NO;
    return [entityType isEqual:[(PajeEntity *)other entityType]]
        && [name isEqual:[(PajeEntity *)other name]]
        && [container isEqual:[(PajeEntity *)other container]]
        && [[self startTime] isEqual:[(PajeEntity *)other startTime]]
        && [[self endTime] isEqual:[(PajeEntity *)other endTime]];
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    // entityType and container are not encoded. They must be set explicity
    // after decoding
    [coder encodeObject:name];
}

- (id)initWithCoder:(NSCoder *)coder
{
    id n;
    n = [coder decodeObject];
    return [self initWithType:nil
                         name:n
                    container:nil];
}

@end
