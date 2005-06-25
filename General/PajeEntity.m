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

- (PajeEntityType *)entityType
{
    return entityType;
}

- (PajeContainer *)container
{
    return container;
}

- (void)setContainer:(PajeContainer *)c
{
    container = c;
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

- (NSNumber *)duration
{
    double duration;
    
    duration = [[self endTime] timeIntervalSinceDate:[self startTime]];
    return [NSNumber numberWithDouble:duration];
}

- (NSColor *)color
{
    NSString *n = [self name];
    NSColor *c = [entityType colorForName:n];
    if (!c) {
        c = [NSColor yellowColor];
        [entityType setColor:c forName:n];
    }
    return c;
}

- (void)setColor:(NSColor *)c
{
    [entityType setColor:c forName:[self name]];
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


- (NSArray *)fieldNames
{
    return [NSMutableArray arrayWithObjects:
        @"EntityType", @"Name", @"Container",
        @"StartTime", @"EndTime", @"Duration",
        nil];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    if ([fieldName isEqualToString:@"EntityType"]) {
        return [self entityType];
    } else if ([fieldName isEqualToString:@"Name"]) {
        return [self name];
    } else if ([fieldName isEqualToString:@"Container"]) {
        return [self container];
    } else if ([fieldName isEqualToString:@"StartTime"]) {
        return [self startTime];
    } else if ([fieldName isEqualToString:@"EndTime"]) {
        return [self endTime];
    } else if ([fieldName isEqualToString:@"Duration"]) {
        return [self duration];
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
        && [container isEqual:[(PajeEntity *)other container]];
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:entityType];
    [coder encodeObject:name];
    [coder encodeObject:container];
}

- (id)initWithCoder:(NSCoder *)coder
{
    id o1, o2, o3;
    o1 = [coder decodeObject];
    o2 = [coder decodeObject];
    o3 = [coder decodeObject];
    return [self initWithType:o1
                         name:o2
                    container:o3];
}
@end
