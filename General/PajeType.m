/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
// PajeType
//
// represents the type of (user created) entities and containers
//

#include <Foundation/Foundation.h>
#include "PajeType.h"
#include "Macros.h"
#include "NSUserDefaults+Additions.h"
#include "PajeContainer.h"
#include "CStringCallBacks.h"

@implementation PajeEntityType

+ (PajeEntityType *)typeWithId:(NSString *)i
                   description:(NSString *)d
                 containerType:(PajeContainerType *)type
                         event:(PajeEvent *)e
{
    return [[[self alloc] initWithId:i
                         description:d
                       containerType:type
                               event:e] autorelease];
}

- (id)initWithId:(NSString *)i
     description:(NSString *)d
   containerType:(PajeContainerType *)type
           event:(PajeEvent *)e
{
    if (self == [super init]) {
        NSColor *c;
        Assign(ident, i);
        Assign(description, d);
        containerType = type;
        [containerType addContainedType:self];
        c = [[NSUserDefaults standardUserDefaults]
                   colorForKey:[description stringByAppendingString:@" Color"]];
        if (c == nil) {
            c = [e colorForFieldId:PajeColorFieldId];
        }
        if (c == nil) {
            c = [NSColor whiteColor];
        }
        Assign(color, c);
        //FIXME: should get other fields from event (e.g. layout)
        fieldNames = [[NSMutableSet alloc] init];
        knownEventTypes = NSCreateHashTable(CStringHashCallBacks, 50);
    }
    return self;
}

- (void)dealloc
{
    Assign(ident, nil);
    Assign(description, nil);
    containerType = nil;
    Assign(color, nil);
    Assign(fieldNames, nil);
    NSFreeHashTable(knownEventTypes);
    [super dealloc];
}

- (BOOL)isContainer
{
    return NO;
}

- (NSArray *)allValues
{
    return [NSArray array];
}

- (NSString *)ident
{
    return ident;
}

- (PajeContainerType *)containerType
{
    if (containerType == nil) return (id)self;    //HACK
    return containerType;
}

- (PajeDrawingType)drawingType
{
    [self _subclassResponsibility:_cmd];
    return PajeNonDrawingType;
}


- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSString *)description
{
    return description;
}

- (NSColor *)colorForValue:(id)value
{
    return [self color];
}
- (void)setColor:(NSColor*)c
        forValue:(id)value
{
    [self setColor:c];
}

- (NSColor *)color
{
    return color;
}

- (void)setColor:(NSColor*)c
{
    Assign(color, c);
    [[NSUserDefaults standardUserDefaults]
            setColor:color
              forKey:[description stringByAppendingString:@" Color"]];
}

- (id)valueOfFieldNamed:(NSString *)n
{
    // FIXME: may have fields on event that created type
    return nil;
}


- (void)addFieldNames:(NSArray *)names
{
    [fieldNames addObjectsFromArray:names];
}

- (NSArray *)fieldNames
{
    return [fieldNames allObjects];
}

- (double)minValue
{
    return 0.0;
}

- (double)maxValue
{
    return 0.0;
}


- (BOOL)isKnownEventType:(const char *)type
{
    if (NSHashGet(knownEventTypes, type) != NULL) {
        return YES;
    }
    NSHashInsert(knownEventTypes, strdup(type));
    return NO;
}

- (unsigned)hash
{
    return [ident hash];
}

- (BOOL)isEqual:(id)other
{
    if ([other isKindOfClass:[PajeEntityType class]]) {
      return [ident isEqualToString: [(PajeEntityType *)other ident]];
    }else{
      return NO;
    }
}

- (NSComparisonResult)compare:(id)other
{
    if ([other isKindOfClass:[PajeEntityType class]]) {
      return [ident compare: [(PajeEntityType *)other ident]];
    }else{
      return NSOrderedSame;
    }
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:ident];
    [coder encodeObject:description];
    [coder encodeObject:containerType];
    [coder encodeObject:fieldNames];
    // FIXME: save other fields (from creation event, see -init)
}

- (id)initWithCoder:(NSCoder *)coder
{
    id o1;
    id o2;
    id o3;
    o1 = [coder decodeObject];
    o2 = [coder decodeObject];
    o3 = [coder decodeObject];
    self = [self initWithId:o1
                description:o2
              containerType:o3
                      event:nil];
    Assign(fieldNames, [coder decodeObject]);
    return self;
}
@end


@implementation PajeContainerType
+ (PajeContainerType *)typeWithId:(NSString *)i
                      description:(NSString *)d
                    containerType:(PajeContainerType *)type
                            event:(PajeEvent *)e
{
    return [[[self alloc] initWithId:i
                         description:d
                       containerType:type
                               event:e] autorelease];
}

- (id)initWithId:(NSString *)i
     description:(NSString *)d
   containerType:(PajeContainerType *)type
           event:(PajeEvent *)e
{
    self = [super initWithId:i description: d containerType:type event:e];
    if (self != nil) {
        allInstances = [[NSMutableArray alloc] init];
        idToInstance = NSCreateMapTable(CStringMapKeyCallBacks,
                                        NSObjectMapValueCallBacks, 50);
        containedTypes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    Assign(allInstances, nil);
    NSFreeMapTable(idToInstance);
    Assign(containedTypes, nil);
    [super dealloc];
}

- (BOOL)isContainer
{
    return YES;
}

- (PajeDrawingType)drawingType
{
    return PajeContainerDrawingType;
}

- (void)addInstance:(PajeContainer *)container
                id1:(const char *)id1
                id2:(const char *)id2
{
    [allInstances addObject:container];
    if (id1 != NULL) {
        NSMapInsert(idToInstance, strdup(id1), container);
    }
    if (id2 != NULL && strcmp(id1, id2) != 0) {
        NSMapInsert(idToInstance, strdup(id2), container);
    }
}

- (PajeContainer *)instanceWithId:(const char *)containerId
{
    if (containerId != NULL) {
        return NSMapGet(idToInstance, containerId);
    }
    return nil;
}

- (NSArray *)allInstances
{
    return allInstances;
}

- (void)addContainedType:(PajeEntityType *)type
{
    [containedTypes addObject:type];
}

- (NSArray *)containedTypes
{
    return containedTypes;
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:allInstances];
//FIXME -- how to encode this? -- probably types should not leave memory
//    [coder encodeObject:idToInstance];
    [coder encodeObject:containedTypes];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(allInstances, [coder decodeObject]);
//FIXME
//    Assign(idToInstance, [coder decodeObject]);
    Assign(containedTypes, [coder decodeObject]);
    return self;
}
@end





@implementation PajeCategorizedEntityType
- (id)initWithId:(NSString *)i
     description:(NSString *)d
   containerType:(PajeContainerType *)type
           event:(PajeEvent *)e
{
    self = [super initWithId:i description:d containerType:type event:e];
    if (self != nil) {
        aliasToValue = NSCreateMapTable(CStringMapKeyCallBacks,
                                        NSObjectMapValueCallBacks, 50);
        [self readDefaultColors];
    }
    return self;
}

- (void)dealloc
{
    NSFreeMapTable(aliasToValue);
    Assign(valueToColor, nil);
    [super dealloc];
}

- (void)setValue:(id)value
           alias:(const char *)alias
{
    if (alias != NULL) {
        NSMapInsert(aliasToValue, strdup(alias), value);
    }
}

- (void)setValue:(id)value
           alias:(const char *)alias
           color:(id)c
{
    if (alias != NULL) {
        NSMapInsert(aliasToValue, strdup(alias), value);
    }
    [self setColor:c forValue:value];
}

- (id)valueForAlias:(const char *)alias
{
    id value;
    value = NSMapGet(aliasToValue, alias);
    if (value == nil) {
        value = [NSString stringWithCString:alias];
        NSMapInsert(aliasToValue, strdup(alias), value);
    }
    return value;
}

- (NSArray *)allValues
{
    return NSAllMapTableValues(aliasToValue);
}

- (NSColor *)colorForValue:(id)value
{
    NSAssert([value isKindOfClass: [NSString class]], 
             @"key must be of NSString class");
    NSString *key = [value stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSColor *colorForValue;
    colorForValue = [valueToColor objectForKey:key];
    if (colorForValue == nil) {
        colorForValue = [NSColor whiteColor];
    }
    return colorForValue;
}

- (void)setColor:(NSColor*)colorForValue
        forValue:(id)value
{
    NSAssert([value isKindOfClass: [NSString class]], 
             @"key must be of NSString class");
    NSString *key = [value stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [valueToColor setObject:colorForValue forKey:key];
    [[NSUserDefaults standardUserDefaults]
        setColorDictionary:valueToColor
                    forKey:[description stringByAppendingString:@" Colors"]];
}

- (void)readDefaultColors
{
    id defaultColors;
    NSMutableDictionary *dict;
    defaultColors = [[NSUserDefaults standardUserDefaults]
        colorDictionaryForKey:[description stringByAppendingString:@" Colors"]];
    if (defaultColors != nil) {
        dict = [[defaultColors mutableCopy] autorelease];
    } else {
        dict = [NSMutableDictionary dictionary];
    }
    Assign(valueToColor, dict);
}


// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    //FIXME [coder encodeObject:aliasToValue];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    //FIXME Assign(aliasToValue, [coder decodeObject]);
    [self readDefaultColors];
    return self;
}
@end



@implementation PajeEventType
- (PajeDrawingType)drawingType
{
    return PajeEventDrawingType;
}
@end


@implementation PajeStateType
- (PajeDrawingType)drawingType
{
    return PajeStateDrawingType;
}
@end

#include <math.h>

@implementation PajeVariableType
- (id)initWithId:(NSString *)i
     description:(NSString *)d
   containerType:(PajeContainerType *)type
           event:(PajeEvent *)e
{
    self = [super initWithId:i
                 description:d
               containerType:type
                       event:e];
    if (self != nil) {
        minValue = HUGE_VAL;
        maxValue = -HUGE_VAL;
    }
    return self;
}

+ (NSArray *)allValues
{
    return [NSArray array];
}

- (void)dealloc
{
    [super dealloc];
}

- (PajeDrawingType)drawingType
{
    return PajeVariableDrawingType;
}

- (void)possibleNewMinValue:(double)value
{
    if (value < minValue) {
        minValue = value;
    }
}

- (void)possibleNewMaxValue:(double)value
{

    if (value > maxValue) {
        maxValue = value;
    }
}

- (double)minValue
{
    return minValue;
}

- (double)maxValue
{
    return maxValue;
}


// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:[NSNumber numberWithDouble:minValue]];
    [coder encodeObject:[NSNumber numberWithDouble:maxValue]];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    minValue = [[coder decodeObject] doubleValue];
    maxValue = [[coder decodeObject] doubleValue];
    return self;
}
@end


@implementation PajeLinkType

+ (PajeLinkType *)typeWithId:(id)i
                 description:(id)d
               containerType:(PajeContainerType *)type
         sourceContainerType:(PajeContainerType *)sourceType
           destContainerType:(PajeContainerType *)destType
                         event:(PajeEvent *)e
{
    return [[[self alloc] initWithId:i
                         description:d
                       containerType:type
                 sourceContainerType:sourceType
                   destContainerType:destType
                               event:e] autorelease];
}

-    (id)initWithId:(id)i
        description:(id)d
      containerType:(PajeContainerType *)type
sourceContainerType:(PajeContainerType *)sourceType
  destContainerType:(PajeContainerType *)destType
              event:(PajeEvent *)e
{
    self = [super initWithId:i description:d containerType:type event:e];
    sourceContainerType = sourceType;
    destContainerType = destType;
    return self;
}

- (PajeContainerType *)sourceContainerType
{
    return sourceContainerType;
}

- (PajeContainerType *)destContainerType
{
    return destContainerType;
}

- (PajeDrawingType)drawingType
{
    return PajeLinkDrawingType;
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:sourceContainerType];
    [coder encodeObject:destContainerType];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(sourceContainerType, [coder decodeObject]);
    Assign(destContainerType, [coder decodeObject]);
    return self;
}
@end
