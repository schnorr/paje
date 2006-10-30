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
// holds a user-definable link
//

#include "UserLink.h"
#include "../General/Macros.h"
#include "../General/PajeContainer.h"


@implementation UserLink

+ (UserLink *)linkOfType:(PajeEntityType *)type
                   value:(id)v
                     key:(id)k
               container:(PajeContainer *)c
         sourceContainer:(PajeContainer *)sc
             sourceEvent:(PajeEvent *)e
{
    return [[[self alloc] initWithType:type
                                 value:v
                                   key:k
                             container:c
                       sourceContainer:sc
                           sourceEvent:e] autorelease];
}

+ (UserLink *)linkOfType:(PajeEntityType *)type
                   value:(id)v
                     key:(id)k
               container:(PajeContainer *)c
           destContainer:(PajeContainer *)dc
               destEvent:(PajeEvent *)e;
{
    return [[[self alloc] initWithType:type
                                 value:v
                                   key:k
                             container:c
                         destContainer:dc
                             destEvent:e] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
             value:(id)v
               key:(id)k
         container:(PajeContainer *)c
   sourceContainer:(PajeContainer *)sc
       sourceEvent:(PajeEvent *)e
{
    self = [super initWithType:type
                         value:v
                     container:c
                    startEvent:e];
    if (self != nil) {
        Assign(key, k);
        sourceContainer = sc;  // not retained
    }
    return self;
}

- (id)initWithType:(PajeEntityType *)type
             value:(id)v
               key:(id)k
         container:(PajeContainer *)c
     destContainer:(PajeContainer *)dc
         destEvent:(PajeEvent *)e
{
    self = [super initWithType:type
                         value:v
                     container:c
                    startEvent:nil];
    if (self != nil) {
        [self setEndEvent:e];
        Assign(key, k);
        destContainer = dc;  // not retained
    }
    return self;
}


- (void)dealloc
{
    Assign(key, nil);
    [super dealloc];
}

- (void)setSourceContainer:(PajeContainer *)sc
               sourceEvent:(PajeEvent *)e
{
    sourceContainer = sc;   // not retained
    [self setEvent:e];
}

- (void)setDestContainer:(PajeContainer *)dc
               destEvent:(PajeEvent *)e
{
    destContainer = dc;   // not retained
    [self setEndEvent:e];
}

- (BOOL)canBeEndedWithValue:(id)v key:(id)k
{
    return ((destContainer == nil)
            && [[self value] isEqual:v]
            && [key isEqual:k]);
}

- (BOOL)canBeStartedWithValue:(id)v key:(id)k
{
    return ((sourceContainer == nil)
            && [[self value] isEqual:v]
            && [key isEqual:k]);
}

- (PajeContainer *)container
{
    return container;
}
- (PajeContainer *)sourceContainer
{
    return sourceContainer;
}
- (PajeContainer *)destContainer
{
    return destContainer;
}

- (PajeEntityType *)sourceEntityType
{
    return [sourceContainer entityType];
}

- (PajeEntityType *)destEntityType
{
    return [destContainer entityType];
}

- (NSArray *)fieldNames
{
    NSArray *localFields;
    localFields = [NSArray arrayWithObjects:
        @"SourceContainer", @"DestContainer", @"Key",
        @"StartLogical", @"EndLogical",
        nil];
    return [[super fieldNames] arrayByAddingObjectsFromArray:localFields];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id value;
    if ([fieldName isEqual:@"SourceContainer"])
        return [self sourceContainer];
    else if ([fieldName isEqual:@"DestContainer"])
        return [self destContainer];
    else if ([fieldName isEqual:@"Key"])
        return key;
    else if ([fieldName isEqual:@"StartLogical"])
        return [NSString stringWithFormat:@"%d", [self startLogicalTime]];
    else if ([fieldName isEqual:@"EndLogical"])
        return [NSString stringWithFormat:@"%d", [self endLogicalTime]];
    else value = [super valueOfFieldNamed:fieldName];
    return value;
}

- (NSDate *)xendTime
{
//    if (endLogicalTime != nil)
//	return endLogicalTime;
    return [super endTime];
}

- (NSDate *)startTime
{
//if (startLogicalTime != nil)
//    return startLogicalTime;
    if (time != nil) {
        return [super startTime];
    } else if (sourceContainer != nil) {
        return [sourceContainer endTime];
    } else {
        return [self endTime];
    } 
}

- (void)setStartLogicalTime:(int)t
{
    startLogicalTime = t;
}
- (void)setEndLogicalTime:(int)t
{
    endLogicalTime = t;
}
- (int)startLogicalTime
{
    return startLogicalTime;
}
- (int)endLogicalTime
{
    return endLogicalTime;
}
@end
