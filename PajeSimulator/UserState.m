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
#include "UserState.h"
#include "../General/Macros.h"

@implementation UserState

+ (UserState *)stateOfType:(PajeEntityType *)type
                     value:(id)v
                 container:(PajeContainer *)c
                startEvent:(PajeEvent *)e
{
    return [[[self alloc] initWithType:type
                                 value:v
                             container:c
                            startEvent:e] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
             value:(id)v
         container:(PajeContainer *)c
        startEvent:(PajeEvent *)e
{
    self = [super initWithType:type
                          name:v
                     container:c
                         event:e];
    if (self != nil) {
        endTime = nil;
        imbricationLevel = 0;
        innerStates = nil;
        innerDuration = 0;
    }
    return self;
}
- (void)dealloc
{
    Assign(endTime, nil);
    Assign(innerStates, nil);
    [super dealloc];
}

- (void)setEndEvent:(PajeEvent *)e
{
    // should get extra fields?
    Assign(endTime, [e time]);
}

- (NSDate *)endTime
{
    if (endTime != nil) {
        return endTime;
    }
    return [container endTime];
}

- (void)setImbricationLevel:(int)level
{
    imbricationLevel = level;
}

- (int)imbricationLevel
{
    return imbricationLevel;
}

- (double)exclusiveDuration
{
    return [self duration] - innerDuration;
}

- (double)inclusiveDuration
{
    return [self duration];
}

- (unsigned)condensedEntitiesCount
{
    return condensedEntitiesCount;
}

- (void)addInnerState:(UserState *)innerState
{
    innerDuration += [innerState duration];
    if (innerStates == nil) {
        innerStates = [[CondensedEntitiesArray alloc] init];
    }
    [innerStates addArray:[innerState condensedEntities]];
    [innerStates addValue:[innerState value]
                 duration:[innerState exclusiveDuration]];
    condensedEntitiesCount += [innerState condensedEntitiesCount] + 1;
}

- (CondensedEntitiesArray *)condensedEntities
{
    return innerStates;
}

- (unsigned)subCount
{
    return [innerStates count];
}

- (id)subValueAtIndex:(unsigned)i
{
    return [innerStates valueAtIndex:i];
}

- (NSColor *)subColorAtIndex:(unsigned)i
{
    return [entityType colorForValue:[innerStates valueAtIndex:i]];
}

- (double)subDurationAtIndex:(unsigned)i
{
    return [innerStates durationAtIndex:i];
}


- (NSArray *)fieldNames
{
    NSMutableArray *localFields;
    localFields = [NSMutableArray arrayWithObjects:
                        @"Imbrication Level",
                        @"Exclusive Duration",
                        nil];
    [localFields addObjectsFromArray:[super fieldNames]];
    return localFields;
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id value;
    if ([fieldName isEqual:@"Imbrication Level"]) {
        return [NSNumber numberWithInt:[self imbricationLevel]];
    } else if ([fieldName isEqual:@"Exclusive Duration"]) {
        return [NSNumber numberWithDouble:[self exclusiveDuration]];
    }
    value = [super valueOfFieldNamed:fieldName];
    return value;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeValuesOfObjCTypes:"@id@i",
            &endTime, &imbricationLevel, &innerDuration,
            &innerStates, &condensedEntitiesCount];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    [coder decodeValuesOfObjCTypes:"@id@i",
            &endTime, &imbricationLevel, &innerDuration,
            &innerStates, &condensedEntitiesCount];
    return self;
}

@end
