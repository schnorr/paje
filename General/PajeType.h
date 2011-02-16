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
    NSString *uniqueAlias;
    PajeContainerType *containerType;
    NSColor *color;
    NSMutableSet *fieldNames;
    NSHashTable *knownEventTypes;
}

+ (PajeEntityType *)typeWithName:(NSString *)n
                       withAlias:(NSString *)a
                   containerType:(PajeContainerType *)type
                           event:(PajeEvent *)e;
- (id)initWithName:(NSString *)n
         withAlias:(NSString *)a
     containerType:(PajeContainerType *)type
             event:(PajeEvent *)e;

- (BOOL)isContainer;

- (NSString *)name;
- (NSString *)alias;
- (PajeContainerType *)containerType;

- (PajeDrawingType)drawingType;

- (NSColor *)colorForValue:(id)value;
- (void)setColor:(NSColor*)color forValue:(id)value;
- (NSColor *)color;
- (void)setColor:(NSColor*)color;
- (NSArray *)allValues;

- (double)minValue;
- (double)maxValue;

- (id)valueOfFieldNamed:(NSString *)n;

- (BOOL)isKnownEventType:(const char *)type;
- (void)addFieldNames:(NSArray *)names;
- (NSArray *)fieldNames;

- (NSComparisonResult)compare:(id)other;
@end


@interface PajeContainerType : PajeEntityType
{
    NSMutableArray *allInstances;
    NSMapTable *idToInstance;
    NSMutableArray *containedTypes;
}

+ (PajeContainerType *)typeWithName:(NSString *)n
                          withAlias:(NSString *)a
                      containerType:(PajeContainerType *)type
                              event:(PajeEvent *)e;

- (void)addInstance:(PajeContainer *)container
                id1:(const char *)id1
                id2:(const char *)id2;
- (PajeContainer *)instanceWithId:(const char *)containerId;
- (NSArray *)allInstances;
- (void)addContainedType:(PajeEntityType *)type;
- (NSArray *)containedTypes;
@end


@interface PajeCategorizedEntityType : PajeEntityType
{
    NSMapTable *aliasToValue;
    NSMutableDictionary *valueToColor;
}

- (void)setValue:(id)value
           alias:(const char *)alias;
- (void)setValue:(id)value
           alias:(const char *)alias
           color:(id)c;
- (id)valueForAlias:(const char *)alias;
- (NSArray *)allValues;

- (NSColor *)colorForValue:(id)value;
- (void)setColor:(NSColor*)color forValue:(id)value;
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
    double minValue;
    double maxValue;
}
- (PajeDrawingType)drawingType;
- (void)possibleNewMinValue:(double)value;
- (void)possibleNewMaxValue:(double)value;
- (double)minValue;
- (double)maxValue;
@end


@interface PajeLinkType : PajeCategorizedEntityType
{
    PajeContainerType *sourceContainerType; // not retained
    PajeContainerType *destContainerType;   // not retained
}

+ (PajeLinkType *)typeWithName:(id)n
                     withAlias:(id)a
                 containerType:(PajeContainerType *)type
           sourceContainerType:(PajeContainerType *)sourceType
             destContainerType:(PajeContainerType *)destType
                         event:(PajeEvent *)e;
-    (id)initWithName:(id)n
            withAlias:(id)a
        containerType:(PajeContainerType *)type
  sourceContainerType:(PajeContainerType *)sourceType
    destContainerType:(PajeContainerType *)destType
                event:(PajeEvent *)e;
- (PajeContainerType *)sourceContainerType;
- (PajeContainerType *)destContainerType;
- (PajeDrawingType)drawingType;
@end
#endif
