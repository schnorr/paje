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
        imbricationLevel = 0;
    }
    return self;
}
- (void)dealloc
{
    Assign(endEvent, nil);
    [super dealloc];
}

- (id)value
{
    return [super name];
}

- (void)setEndEvent:(PajeEvent *)e
{
    Assign(endEvent, e);
}

- (NSDate *)endTime
{
    if (endEvent != nil) {
        return [endEvent time];
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

- (NSArray *)fieldNames
{
    NSArray *localFields;
    localFields = [NSArray arrayWithObject:@"Imbrication Level"];
    localFields = [localFields arrayByAddingObjectsFromArray:[endEvent fieldNames]];
    return [[super fieldNames] arrayByAddingObjectsFromArray:localFields];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id value;
    if ([fieldName isEqual:@"Imbrication Level"])
        return [NSNumber numberWithInt:[self imbricationLevel]];
    value = [super valueOfFieldNamed:fieldName];
    if (value != nil)
        return value;
    value = [endEvent valueOfFieldNamed:fieldName];
    return value;
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:endEvent];
    [coder encodeObject:[NSNumber numberWithInt:imbricationLevel]];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(endEvent, [coder decodeObject]);
    imbricationLevel = [[coder decodeObject] intValue];
    return self;
}

@end

@implementation UserStateInspector
- (void)addLocalFields
{
    [super addLocalFields];
}
@end
