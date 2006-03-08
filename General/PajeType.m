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

@implementation PajeEntityType

+ (PajeEntityType *)typeWithName:(NSString *)n
                   containerType:(PajeContainerType *)type
                           event:(PajeEvent *)e
{
    return [[[self alloc] initWithName:n
                         containerType:type
                                 event:e] autorelease];
}

- (id)initWithName:(NSString *)n
     containerType:(PajeContainerType *)type
             event:(PajeEvent *)e
{
    if (self == [super init]) {
        NSColor *c;
        Assign(name, n);
        containerType = type;
	[containerType addContainedType:self];
        Assign(event, e);
        c = [[NSUserDefaults standardUserDefaults]
                         colorForKey:[name stringByAppendingString:@" Color"]];
        if (c == nil) {
            c = [event valueOfFieldNamed:@"Color"];
        }
        if (c == nil) {
            c = [NSColor whiteColor];
        }
        Assign(color, c);
        fieldNames = [[NSMutableSet alloc] init];
        knownEventTypes = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    Assign(name, nil);
    containerType = nil;
    Assign(color, nil);
    Assign(event, nil);
    Assign(fieldNames, nil);
    Assign(knownEventTypes, nil);
    [super dealloc];
}

- (BOOL)isContainer
{
    return NO;
}

- (NSArray *)allNames
{
    return [NSArray array];
}

- (NSString *)name
{
    return name;
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
    return [name description];
}

- (NSColor *)colorForName:(id)n
{
    return [self color];
}
- (void)setColor:(NSColor*)c forName:(id)n
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
            setColor:color forKey:[name stringByAppendingString:@" Color"]];
}

- (id)valueOfFieldNamed:(NSString *)n
{
    return [event valueOfFieldNamed:n];
}


- (void)addFieldNames:(NSArray *)names
{
    [fieldNames addObjectsFromArray:names];
}

- (NSArray *)fieldNames
{
    return [fieldNames allObjects];
}

- (BOOL)isKnownEventType:(id)type
{
    if ([knownEventTypes containsObject:type]) {
        return YES;
    }
    [knownEventTypes addObject:type];
    return NO;
}

- (unsigned)hash
{
    return [name hash];
}

- (BOOL)isEqual:(id)other
{
    if (other == self || other == name) return YES;
    return [other isEqual:name];
}

- (NSComparisonResult)compare:(id)other
{
    if ([other isKindOfClass:[PajeEntityType class]]) {
        return [name compare:[(PajeEntityType *)other name]];
    }
    return [super compare:other];
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:name];
    [coder encodeObject:containerType];
    [coder encodeObject:event];
    [coder encodeObject:fieldNames];
}

- (id)initWithCoder:(NSCoder *)coder
{
    id o1, o2, o3;
    o1 = [coder decodeObject];
    o2 = [coder decodeObject];
    o3 = [coder decodeObject];
    self = [self initWithName:o1
                containerType:o2
                        event:o3];
    Assign(fieldNames, [coder decodeObject]);
    return self;
}
@end


@implementation PajeContainerType
+ (PajeContainerType *)typeWithName:(NSString *)n
                      containerType:(PajeContainerType *)type
                              event:(PajeEvent *)e
{
    return [[[self alloc] initWithName:n
                         containerType:type
                                 event:e] autorelease];
}

- (id)initWithName:(NSString *)n
     containerType:(PajeContainerType *)type
             event:(PajeEvent *)e
{
    self = [super initWithName:n containerType:type event:e];
    if (self != nil) {
        allInstances = [[NSMutableArray alloc] init];
        idToInstance = [[NSMutableDictionary alloc] init];
        containedTypes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    Assign(allInstances, nil);
    Assign(idToInstance, nil);
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
{
    NSString *containerName;
    NSString *containerAlias;
    
    [allInstances addObject:container];
    containerName = [container name];
    if (containerName != nil) {
        [idToInstance setObject:container forKey:containerName];
    }
    containerAlias = [container alias];
    if (containerAlias != nil && ![containerAlias isEqual:containerName]) {
        [idToInstance setObject:container forKey:containerAlias];
    }
}

- (PajeContainer *)instanceWithId:(NSString *)containerId
{
    if (containerId != nil) {
        return [idToInstance objectForKey:containerId];
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
    [coder encodeObject:idToInstance];
    [coder encodeObject:containedTypes];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(allInstances, [coder decodeObject]);
    Assign(idToInstance, [coder decodeObject]);
    Assign(containedTypes, [coder decodeObject]);
    return self;
}
@end





@implementation PajeCategorizedEntityType
- (id)initWithName:(NSString *)n
     containerType:(PajeContainerType *)type
             event:(PajeEvent *)e
{
    self = [super initWithName:n containerType:type event:e];
    if (self != nil) {
        Assign(aliases, [NSMutableDictionary dictionary]);
        allValues = [[NSMutableSet alloc] init];
        [self readDefaultColors];
    }
    return self;
}

- (void)dealloc
{
    Assign(aliases, nil);
    Assign(allValues, nil);
    Assign(nameToColor, nil);
    [super dealloc];
}

- (void)setValue:(id)value
           alias:(id)alias
{
    if (alias != nil) {
        [aliases setObject:value forKey:alias];
    }
    [allValues addObject:value];
}

- (void)setValue:(id)value
           alias:(id)alias
           color:(id)c
{
    if (alias != nil) {
        [aliases setObject:value forKey:alias];
    }
    [allValues addObject:value];
    [self setColor:c forName:value];
}

- (id)unaliasedValue:(id)v
{
    id value;
    value = [aliases objectForKey:v];
    if (value != nil) {
        return value;
    }
    // TODO should see if v is in allValues
    // return [allValues member];
    return v;
}

//FIXME should be allValues
- (NSArray *)allNames
{
    return [allValues allObjects];
}

- (NSColor *)colorForName:(id)n
{
    NSColor *c;
    c = [nameToColor objectForKey:n];
    if (c == nil) {
        c = [NSColor whiteColor];
    }
    return c;
}

- (void)setColor:(NSColor*)c forName:(id)n
{
    [nameToColor setObject:c forKey:n];
    [[NSUserDefaults standardUserDefaults]
        setColorDictionary:nameToColor
                    forKey:[name stringByAppendingString:@" Colors"]];
}

- (void)readDefaultColors
{
    NSMutableDictionary *dict;
    dict = [[[[NSUserDefaults standardUserDefaults]
        colorDictionaryForKey:[name stringByAppendingString:@" Colors"]] mutableCopy] autorelease];
    if (!dict)
        dict = [NSMutableDictionary dictionary];
    Assign(nameToColor, dict);
}


// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:aliases];
    [coder encodeObject:allValues];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(aliases, [coder decodeObject]);
    Assign(allValues, [coder decodeObject]);
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


@implementation PajeVariableType
+ (NSArray *)allNames
{
    return [NSArray array];
}

- (void)dealloc
{
    Assign(minValue, nil);
    Assign(maxValue, nil);
    [super dealloc];
}

- (PajeDrawingType)drawingType
{
    return PajeVariableDrawingType;
}

- (void)possibleNewMinValue:(NSNumber *)value
{
    if ((minValue == nil) || ([minValue compare:value] == NSOrderedDescending)) {
        Assign(minValue, value);
    }
}

- (void)possibleNewMaxValue:(NSNumber *)value
{

    if ((maxValue == nil) || ([maxValue compare:value] == NSOrderedAscending)) {
        Assign(maxValue, value);
    }
}

- (NSNumber *)minValue
{
    return minValue;
}

- (NSNumber *)maxValue
{
    return maxValue;
}


// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:minValue];
    [coder encodeObject:maxValue];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(minValue, [coder decodeObject]);
    Assign(maxValue, [coder decodeObject]);
    return self;
}
@end


@implementation PajeLinkType

+ (PajeLinkType *)typeWithName:(id)n
                 containerType:(PajeContainerType *)type
           sourceContainerType:(PajeContainerType *)sourceType
             destContainerType:(PajeContainerType *)destType
                         event:(PajeEvent *)e
{
    return [[[self alloc] initWithName:n
                         containerType:type
                   sourceContainerType:sourceType
                     destContainerType:destType
                                 event:e] autorelease];
}

-    (id)initWithName:(id)n
        containerType:(PajeContainerType *)type
  sourceContainerType:(PajeContainerType *)sourceType
    destContainerType:(PajeContainerType *)destType
                event:(PajeEvent *)e
{
    self = [super initWithName:n containerType:type event:e];
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
