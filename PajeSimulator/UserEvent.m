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

    if (self) {
        Assign(event, e);
    }

    return self;
}

- (void)dealloc
{
    Assign(event, nil);

    [super dealloc];
}

- (NSDate *)time
{
    return [event time];
}

- (NSArray *)fieldNames
{
    return [[super fieldNames] arrayByAddingObjectsFromArray: [event fieldNames]];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id value;
    value = [super valueOfFieldNamed:fieldName];
    if (value != nil)
        return value;
    value = [event valueOfFieldNamed:fieldName];
    return value;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:event];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(event, [coder decodeObject]);
    return self;
}
@end
