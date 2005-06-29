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
#ifndef _PajeType_h_
#define _PajeType_h_

//
// PajeType
//
// represents the type of (user created) entities and containers
//

#include <Foundation/Foundation.h>
#include "Protocols.h"
#include "PajeEvent.h"

@class PajeContainerType;

@interface PajeEntityType : NSObject <NSCoding>
{
    NSString *name;
    PajeContainerType *containerType;
    NSColor *color;
    PajeEvent *event;
    NSMutableSet *fieldNames;
}

+ (id/*PajeEntityType **/)typeWithName:(NSString *)n
                   containerType:(PajeContainerType *)type
                           event:(PajeEvent *)e;
- (id)initWithName:(NSString *)n
     containerType:(PajeContainerType *)type
             event:(PajeEvent *)e;

- (BOOL)isContainer;

- (NSString *)name;
- (PajeContainerType *)containerType;

- (PajeDrawingType)drawingType;

- (NSColor *)colorForName:(id)n;
- (void)setColor:(NSColor*)color forName:(id)n;
- (NSColor *)color;
- (void)setColor:(NSColor*)color;
- (NSArray *)allNames;

- (id)valueOfFieldNamed:(NSString *)n;

- (void)addFieldNames:(NSArray *)names;
- (NSArray *)fieldNames;

- (NSComparisonResult)compare:(id)other;
@end


@interface PajeContainerType : PajeEntityType
{
    NSMutableArray *allInstances;
    NSMutableDictionary *idToInstance;
    NSMutableArray *containedTypes;
}

- (void)addInstance:(PajeContainer *)instance;
- (PajeContainer *)instanceWithId:(NSString *)containerId;
- (NSArray *)allInstances;
- (void)addContainedType:(PajeEntityType *)type;
- (NSArray *)containedTypes;
@end


@interface PajeCategorizedEntityType : PajeEntityType
{
    NSMutableDictionary *aliases;
    NSMutableSet *allValues;
    NSMutableDictionary *nameToColor;
}

- (void)setValue:(id)n
           alias:(id)v;
- (void)setValue:(id)value
           alias:(id)alias
           color:(id)c;
- (id)unaliasedValue:(id)v;
- (NSArray *)allNames;

- (NSColor *)colorForName:(id)n;
- (void)setColor:(NSColor*)color forName:(id)n;
- (void)readDefaultColors;
@end



@interface PajeEventType : PajeCategorizedEntityType
- (PajeDrawingType)drawingType;
@end


@interface PajeStateType : PajeCategorizedEntityType
- (PajeDrawingType)drawingType;
@end


@interface PajeVariableType : PajeEntityType
{
    NSNumber *minValue;
    NSNumber *maxValue;
}
- (PajeDrawingType)drawingType;
- (void)possibleNewMinValue:(NSNumber *)value;
- (void)possibleNewMaxValue:(NSNumber *)value;
- (NSNumber *)minValue;
- (NSNumber *)maxValue;
@end


@interface PajeLinkType : PajeCategorizedEntityType
{
    PajeContainerType *sourceContainerType; // not retained
    PajeContainerType *destContainerType;   // not retained
}

+ (PajeLinkType *)typeWithName:(id)n
                 containerType:(PajeContainerType *)type
           sourceContainerType:(PajeContainerType *)sourceType
             destContainerType:(PajeContainerType *)destType
                         event:(PajeEvent *)e;
-    (id)initWithName:(id)n
        containerType:(PajeContainerType *)type
  sourceContainerType:(PajeContainerType *)sourceType
    destContainerType:(PajeContainerType *)destType
                event:(PajeEvent *)e;
- (PajeContainerType *)sourceContainerType;
- (PajeContainerType *)destContainerType;
- (PajeDrawingType)drawingType;
@end
#endif
