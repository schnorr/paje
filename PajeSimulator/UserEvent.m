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
// UserEvent
//
// Holds a generic user-generated event.
//

#include "UserEvent.h"
#include "../General/Macros.h"

@implementation UserEvent

+ (UserEvent *)eventWithType:(PajeEntityType *)type
                        name:(id)n
                   container:(PajeContainer *)c
                       event:(PajeEvent *)e
{
    return [[[self alloc] initWithType:type
                                  name:n
                             container:c
                                 event:e] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
              name:(id)n
         container:(PajeContainer *)c
             event:(PajeEvent *)e
{
    self = [super initWithType:type
                          name:n
                     container:c];

    if (self != nil) {
        if (e != nil) {
            [self setEvent:e];
        }
    }

    return self;
}

- (void)dealloc
{
    Assign(extraFields, nil);
    Assign(time, nil);

    [super dealloc];
}

- (void)setEvent:(PajeEvent *)e
{
    Assign(extraFields, [e extraFields]);
    if (![entityType isKnownEventType:[e cStringForFieldId:PajeEventIdFieldId]]) {
        [entityType addFieldNames:[e fieldNames]];
    }
    Assign(time, [e time]);
}

- (NSDate *)time
{
    return time;
}

- (NSArray *)fieldNames
{
    NSArray *fieldNames;
    fieldNames = [super fieldNames];
    fieldNames = [fieldNames arrayByAddingObject:@"Time"];
    if (extraFields != nil) {
        fieldNames = [fieldNames arrayByAddingObjectsFromArray:[extraFields allKeys]];
    }
    return fieldNames;
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id value = nil;

    if ([fieldName isEqualToString:@"Time"]) {
        value = time;
    } else if (extraFields != nil) {
        value = [extraFields objectForKey:fieldName];
    }
    
    if (value == nil) {
        value = [super valueOfFieldNamed:fieldName];
    }

    return value;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:extraFields];
    [coder encodeObject:time];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(extraFields, [coder decodeObject]);
    Assign(time, [coder decodeObject]);
    return self;
}
@end
