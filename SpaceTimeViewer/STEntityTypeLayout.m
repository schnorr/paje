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
#include "STEntityTypeLayout.h"
#include "../General/NSUserDefaults+Colors.h"
#include "../General/Macros.h"
#include "STController.h"

// 25.aug.2004 BS  creation



@implementation STEntityTypeLayout

+ (Class)classForDrawingType:(PajeDrawingType)dtype
{
    switch (dtype) {
    case PajeEventDrawingType:     return [STEventTypeLayout class];
    case PajeStateDrawingType:     return [STStateTypeLayout class];
    case PajeLinkDrawingType:      return [STLinkTypeLayout class];
    case PajeVariableDrawingType:  return [STVariableTypeLayout class];
    case PajeContainerDrawingType: return [STContainerTypeLayout class];
    }
    NSAssert1(0, @"Invalid drawing type %d", dtype);
}

+ (STEntityTypeLayout *)descriptorWithEntityType:(PajeEntityType *)etype
                                     drawingType:(PajeDrawingType)dtype
                             containerDescriptor:(STContainerTypeLayout *)cDesc
                                      controller:(STController *)controller
{
    return [[[[self classForDrawingType:dtype] alloc]
                    initWithEntityType:etype
                   containerDescriptor:cDesc
                            controller:controller] autorelease];
}

- (NSString *)defaultKeyForKey:(NSString *)key
{
    return [[entityType description] stringByAppendingString:key];
}

- (void)registerDefaultsWithController:(STController *)controller
{
    id tHeight;
    id tShape;

    tHeight = [controller valueOfFieldNamed:@"Height" forEntityType:entityType];
    if (tHeight == nil) {
        tHeight = [NSNumber numberWithInt:6];
    }

    tShape = [controller valueOfFieldNamed:@"Shape" forEntityType:entityType];
    if (tShape == nil) {
        tShape = @"PSNoShape";
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            tHeight, [self defaultKeyForKey:@"Height"],
            tShape, [self defaultKeyForKey:@" Path Function"],
            @"PSFillAndFrameBlack",
                [self defaultKeyForKey:@" Draw Function"],
            @"PSFillAndFrameWhite",
                [self defaultKeyForKey:@" Highlight Function"],
            nil]];
}

- (float)defaultFloatForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] 
                floatForKey:[self defaultKeyForKey:key]];
}

- (void)setDefaultFloat:(float)value forKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] 
                setFloat:value forKey:[self defaultKeyForKey:key]];
}

- (NSString *)defaultStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] 
                stringForKey:[self defaultKeyForKey:key]];
}

- (void)setDefaultString:(NSString *)value forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] 
                setObject:value forKey:[self defaultKeyForKey:key]];
}

- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller
{
    self = [super init];
    if (self != nil) {
        NSString *name;

        Assign(entityType, etype);

        rectInContainer = [[NSMutableDictionary alloc] init];

        [self registerDefaultsWithController:controller];

        height = [self defaultFloatForKey:@"Height"];

        name = [self defaultStringForKey:@" Path Function"];
        Assign(shapeFunction, [ShapeFunction shapeFunctionWithName:name]);
        
        name = [self defaultStringForKey:@" Draw Function"];
        Assign(drawFunction, [DrawFunction drawFunctionWithName:name]);

        name = [self defaultStringForKey:@" Highlight Function"];
        Assign(highlightFunction, [DrawFunction drawFunctionWithName:name]);

        containerDescriptor = cDesc;
        [containerDescriptor addSubtype:self];
    }
    return self;
}

- (void)removeContainerDescriptor
{
    containerDescriptor = nil;
}

- (void)dealloc
{
    Assign(entityType, nil);
    Assign(shapeFunction, nil);
    Assign(drawFunction, nil);
    Assign(highlightFunction, nil);
    Assign(rectInContainer, nil);
    [super dealloc];
}

// accessor methods
- (PajeEntityType *)entityType
{
    return entityType;
}

- (void)setShapeFunction:(ShapeFunction *)f
{
    Assign(shapeFunction, f);
    [self setDefaultString:[f name] forKey:@" Path Function"];
}

- (void)setDrawFunction:(DrawFunction *)f
{
    Assign(drawFunction, f);
    [self setDefaultString:[f name] forKey:@" Draw Function"];
}

- (void)setHighlightFunction:(DrawFunction *)f
{
    Assign(highlightFunction, f);
    [self setDefaultString:[f name] forKey:@" Highlight Function"];
}

- (ShapeFunction *)shapeFunction
{
    return shapeFunction;
}

- (DrawFunction *)drawFunction
{
    return drawFunction;
}

- (DrawFunction *)highlightFunction
{
    return highlightFunction;
}


- (void)setHeight:(float)val
{
    height = val;
    [self setDefaultFloat:height forKey:@"Height"];
}

- (float)height
{
    return height;
}


- (void)setOffset:(float)val
{
    offset = val;
}

- (float)offset
{
    return offset;
}

- (void)setDrawsName:(BOOL)draws
{
    drawsName = draws;
}

- (BOOL)drawsName
{
    return drawsName;
}

- (float)yInContainer:(id)container
{
    if (containerDescriptor != nil) {
        return NSMinY([containerDescriptor rectOfInstance:container]) + offset;
    } else {
        return offset;
    }
}

- (void)setRect:(NSRect)rect inContainer:(id)container
{
    [rectInContainer setObject:[NSValue valueWithRect:rect]
                         forKey:container];
}

- (NSRect)rectInContainer:(id)container;
{
    NSValue *value = [rectInContainer objectForKey:container];
    if (value != nil)
        return [value rectValue];
    else
        return NSZeroRect;
}

- (BOOL)intersectsRect:(NSRect)rect inContainer:(id)container
{
    return !NSIsEmptyRect(NSIntersectionRect(rect,
                                             [self rectInContainer:container]));
}

- (BOOL)isPoint:(NSPoint)point
    inContainer:(id)container
{
    return NSPointInRect(point, [self rectInContainer:container]);
}

- (void)reset
{
    [rectInContainer removeAllObjects];
}


// methods to be implemented by subclasses
- (PajeDrawingType)drawingType
{
    [self subclassResponsibility:_cmd];
    return PajeNonDrawingType;
}

- (BOOL)isContainer
{
    return NO;
}

// from NSObject protocol

- (unsigned int)hash
{
    return [entityType hash];
}

- (BOOL)isEqual:(id)other
{
    if (other == self || other == entityType) {
        return YES;
    }
    return [[entityType description] isEqual:[other description]];
}

- (NSString *)description
{
    return [entityType description];
}
@end



@implementation STEventTypeLayout

- (void)registerDefaultsWithController:(STController *)controller
{
    id tHeight;
    id tWidth;
    id tShape;

    [super registerDefaultsWithController:controller];

    tHeight = [controller valueOfFieldNamed:@"Height" forEntityType:entityType];
    if (tHeight == nil) {
        tHeight = [NSNumber numberWithInt:10];
    }

    tWidth = [controller valueOfFieldNamed:@"Width" forEntityType:entityType];
    if (tWidth == nil) {
        tWidth = [NSNumber numberWithInt:6];
    }

    tShape = [controller valueOfFieldNamed:@"Shape" forEntityType:entityType];
    if (tShape == nil) {
        tShape = @"PSPin";
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            tHeight, [self defaultKeyForKey:@"Height"],
            tWidth, [self defaultKeyForKey:@"Width"],
            tShape, [self defaultKeyForKey:@" Path Function"],
            @"PSFillAndFrameBlack",
                [self defaultKeyForKey:@" Draw Function"],
            @"PSFillAndFrameWhite",
                [self defaultKeyForKey:@" Highlight Function"],
            nil]];
}

- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller
{
    self = [super initWithEntityType:etype
                 containerDescriptor:cDesc
                          controller:controller];
    if (self != nil) {
        width = [self defaultFloatForKey:@"Width"];
    }
    return self;
}

- (PajeDrawingType)drawingType
{
    return PajeEventDrawingType;
}


- (void)setWidth:(float)val
{
    width = val;
    [self setDefaultFloat:width forKey:@"Width"];
}

- (float)width
{
    return width;
}

- (BOOL)isSupEvent
{
    return ([[self shapeFunction] topExtension] >= 0.5);
}

- (void)setRect:(NSRect)rect inContainer:(id)container
{
    if ([self isSupEvent]) {
        rect.origin.y -= rect.size.height;
    }
    rect.origin.x -= width * (1 - [shapeFunction rightExtension]);
    rect.size.width += width;
    [super setRect:rect inContainer:container];
}
@end



@implementation STStateTypeLayout

- (void)registerDefaultsWithController:(STController *)controller
{
    id tHeight;
    id tInset;
    id tShape;

    [super registerDefaultsWithController:controller];

    tHeight = [controller valueOfFieldNamed:@"Height" forEntityType:entityType];
    if (tHeight == nil) {
        tHeight = [NSNumber numberWithInt:16];
    }

    tInset = [controller valueOfFieldNamed:@"Inset" forEntityType:entityType];
    if (tInset == nil) {
        tInset = [NSNumber numberWithInt:4];
    }

    tShape = [controller valueOfFieldNamed:@"Shape" forEntityType:entityType];
    if (tShape == nil) {
        tShape = @"PSRect";
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            tHeight, [self defaultKeyForKey:@"Height"],
            tInset, [self defaultKeyForKey:@"Inset"],
            tShape, [self defaultKeyForKey:@" Path Function"],
            @"PSFillAndFrameBlack",
                [self defaultKeyForKey:@" Draw Function"],
            @"PSFillAndFrameWhite",
                [self defaultKeyForKey:@" Highlight Function"],
            nil]];
}

- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller
{
    self = [super initWithEntityType:etype
                 containerDescriptor:cDesc
                          controller:controller];
    if (self != nil) {
        inset = [self defaultFloatForKey:@"Inset"];
    }
    return self;
}


- (PajeDrawingType)drawingType
{
    return PajeStateDrawingType;
}

- (void)setInsetAmount:(float)newInsetAmount
{
    inset = newInsetAmount;
    [self setDefaultFloat:inset forKey:@"Inset"];
}

- (float)insetAmount
{
    return inset;
}

@end


@implementation STLinkTypeLayout

- (void)registerDefaultsWithController:(STController *)controller
{
    id tLineWidth;
    id tShape;

    [super registerDefaultsWithController:controller];

    tLineWidth = [controller valueOfFieldNamed:@"LineWidth"
                                 forEntityType:entityType];
    if (tLineWidth == nil) {
        tLineWidth = [NSNumber numberWithInt:1];
    }

    tShape = [controller valueOfFieldNamed:@"Shape" forEntityType:entityType];
    if (tShape == nil) {
        tShape = @"PSArrow";
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            tLineWidth, [self defaultKeyForKey:@"LineWidth"],
            tShape, [self defaultKeyForKey:@" Path Function"],
            @"PSstroke",
                [self defaultKeyForKey:@" Draw Function"],
            @"PSFrameWhite",
                [self defaultKeyForKey:@" Highlight Function"],
            nil]];
}

- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller
{
    self = [super initWithEntityType:etype
                 containerDescriptor:cDesc
                          controller:controller];
    if (self != nil) {
        lineWidth = [self defaultFloatForKey:@"LineWidth"];
    }
    return self;
}


- (PajeDrawingType)drawingType
{
    return PajeLinkDrawingType;
}

- (void)setLineWidth:(float)val
{
    lineWidth = val;
    [self setDefaultFloat:lineWidth forKey:@"LineWidth"];
}

- (float)lineWidth
{
    return lineWidth;
}

- (void)setSourceOffset:(float)val
{
    offset = val;
}

- (float)sourceOffset
{
    return offset;
}

- (void)setDestOffset:(float)val
{
    destOffset = val;
}

- (float)destOffset
{
    return destOffset;
}

@end


@implementation STVariableTypeLayout

- (void)registerDefaultsWithController:(STController *)controller
{
    id tLineWidth;

    [super registerDefaultsWithController:controller];

    tLineWidth = [controller valueOfFieldNamed:@"LineWidth"
                                 forEntityType:entityType];
    if (tLineWidth == nil) {
        tLineWidth = [NSNumber numberWithInt:1];
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            tLineWidth, [self defaultKeyForKey:@"LineWidth"],
            @"PSNoShape", [self defaultKeyForKey:@" Path Function"],
            @"PSstroke",
                [self defaultKeyForKey:@" Draw Function"],
            @"PSFrameWhite",
                [self defaultKeyForKey:@" Highlight Function"],
            nil]];
}

- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller
{
    self = [super initWithEntityType:etype
                 containerDescriptor:cDesc
                          controller:controller];
    if (self != nil) {
        lineWidth = [self defaultFloatForKey:@"LineWidth"];
    }
    return self;
}


- (PajeDrawingType)drawingType
{
    return PajeVariableDrawingType;
}

- (void)setLineWidth:(float)val
{
    lineWidth = val;
    [self setDefaultFloat:lineWidth forKey:@"LineWidth"];
}

- (float)lineWidth
{
    return lineWidth;
}


- (void)setMinValue:(float)val
{
    minValue = val;
}

- (float)minValue
{
    return minValue;
}

- (void)setMaxValue:(float)val
{
    maxValue = val;
}

- (float)maxValue
{
    return maxValue;
}

@end



@implementation STContainerTypeLayout

- (void)registerDefaultsWithController:(STController *)controller
{
    [super registerDefaultsWithController:controller];
    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"1", [self defaultKeyForKey:@"SiblingSeparation"],
            @"1", [self defaultKeyForKey:@"TypeSeparation"],
            nil]];
}

- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller
{
    self = [super initWithEntityType:etype
                 containerDescriptor:cDesc
                          controller:controller];
    if (self != nil) {

        rectsOfInstances = [[NSMutableDictionary alloc] init];

        eventSubtypes     = [[NSMutableArray alloc] init];
        supEventSubtypes  = [[NSMutableArray alloc] init];
        stateSubtypes     = [[NSMutableArray alloc] init];
        infEventSubtypes  = [[NSMutableArray alloc] init];
        variableSubtypes  = [[NSMutableArray alloc] init];
        linkSubtypes      = [[NSMutableArray alloc] init];
        containerSubtypes = [[NSMutableArray alloc] init];
        
        siblingSeparation = [self defaultFloatForKey:@"SiblingSeparation"];
        subtypeSeparation = [self defaultFloatForKey:@"SubtypeSeparation"];
    }
    return self;
}

- (void)dealloc
{
    [[self subtypes] makeObjectsPerformSelector:@selector(removeContainerDescriptor)];
    [rectsOfInstances release];

    [eventSubtypes     release];
    [supEventSubtypes  release];
    [stateSubtypes     release];
    [infEventSubtypes  release];
    [variableSubtypes  release];
    [linkSubtypes      release];
    [containerSubtypes release];

    [super dealloc];
}

- (PajeDrawingType)drawingType
{
    return PajeContainerDrawingType;
}

- (BOOL)isContainer
{
    return YES;
}
    
- (void)setSiblingSeparation:(float)val
{
    siblingSeparation = val;
    [self setDefaultFloat:siblingSeparation forKey:@"SiblingSeparation"];
}

- (float)siblingSeparation
{
    return siblingSeparation;
}

- (void)setSubtypeSeparation:(float)val;
{
    subtypeSeparation = val;
    [self setDefaultFloat:subtypeSeparation forKey:@"SubtypeSeparation"];
}

- (float)subtypeSeparation
{
    return subtypeSeparation;
}


- (void)setSupEventsOffset:(float)val;
{
    supEventsOffset = val;
}

- (float)supEventsOffset
{
    return supEventsOffset;
}


- (void)setInfEventsOffset:(float)val;
{
    infEventsOffset = val;
}

- (float)infEventsOffset
{
    return infEventsOffset;
}


- (void)setSubcontainersOffset:(float)val;
{
    subcontainersOffset = val;
}

- (float)subcontainersOffset
{
    return subcontainersOffset;
}

- (float)linkOffset
{
    return (supEventsOffset + infEventsOffset) / 2;
}

- (void)reset
{
    [super reset];
    [rectsOfInstances removeAllObjects];
}


- (void)setRect:(NSRect)rect ofInstance:(id)entity
{
    NSEnumerator *subtypeEnum;
    STEntityTypeLayout *subtype;

    [rectsOfInstances setObject:[NSValue valueWithRect:rect]
                         forKey:entity];

    /* set rects of links to be the container's */
    subtypeEnum = [linkSubtypes objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        [subtype setRect:rect inContainer:entity];
    }
}

- (NSRect)rectOfInstance:(id)entity
{
    NSValue *value = [rectsOfInstances objectForKey:entity];
    if (value != nil)
        return [value rectValue];
    else
        return NSZeroRect;
}

- (BOOL)isInstance:(id)entity inRect:(NSRect)rect
{
    return !NSIsEmptyRect(NSIntersectionRect(rect,
                                             [self rectOfInstance:entity]));
}

- (BOOL)isPoint:(NSPoint)point inInstance:(id)entity;
{
    return NSPointInRect(point, [self rectOfInstance:entity]);
}

- (NSEnumerator *)instanceEnumerator
{
    return [rectsOfInstances keyEnumerator];
}

- (id)instanceWithPoint:(NSPoint)point
{
    NSEnumerator *ienum;
    id instance;

    ienum = [self instanceEnumerator];
    while ((instance = [ienum nextObject]) != nil) {
        if ([self isPoint:point inInstance:instance]) {
            break;
        }
    }
    return instance;
}

- (void)addSubtype:(STEntityTypeLayout *)subtype
{
    switch ([subtype drawingType]) {
    case PajeEventDrawingType:
        [eventSubtypes addObject:subtype];
        break;
    case PajeStateDrawingType:
        [stateSubtypes addObject:subtype];
        break;
    case PajeLinkDrawingType:
        [linkSubtypes addObject:subtype];
        break;
    case PajeVariableDrawingType:
        [variableSubtypes addObject:subtype];
        break;
    case PajeContainerDrawingType:
        [containerSubtypes addObject:subtype];
        break;
    default:
        NSAssert2(0, @"Invalid drawing type %d of %@", 
                     [subtype drawingType], subtype);
    }
}

- (NSArray *)subtypes
{
    NSMutableArray *array;
    
    array = [NSMutableArray array];
    [array addObjectsFromArray:stateSubtypes];
    [array addObjectsFromArray:variableSubtypes];
    [array addObjectsFromArray:supEventSubtypes];
    [array addObjectsFromArray:infEventSubtypes];
    [array addObjectsFromArray:containerSubtypes];
    [array addObjectsFromArray:linkSubtypes];
    return array;
}

- (float)getMaxHeight:(NSArray *)array
{
    NSEnumerator *subtypeEnum;
    STEntityTypeLayout *subtype;
    float max = 0;

    subtypeEnum = [array objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        float h = [subtype height];
        if (h > max) {
            max = h;
        }
    }
    
    return max;
}

- (void)setOffset:(float)val ofSubtypes:(NSArray *)subtypes
{
    NSEnumerator *subtypeEnum;
    STEntityTypeLayout *subtype;

    subtypeEnum = [subtypes objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        [subtype setOffset:val];
    }
}

- (void)setSupEventsOffset
{
    STEventTypeLayout *subtype;
    NSEnumerator *subtypeEnum;
    
    [supEventSubtypes removeAllObjects];
    [infEventSubtypes removeAllObjects];
    subtypeEnum = [eventSubtypes objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        if ([subtype isSupEvent] >= 0.5) {
            [supEventSubtypes addObject:subtype];
        } else {
            [infEventSubtypes addObject:subtype];
        }
    }
    supEventsOffset = [self getMaxHeight:supEventSubtypes];
    [self setOffset:supEventsOffset ofSubtypes:supEventSubtypes];
}

- (void)setStatesOffset
{
    NSEnumerator *subtypeEnum;
    STEntityTypeLayout *subtype;

    infEventsOffset = supEventsOffset;

    subtypeEnum = [stateSubtypes objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        if (infEventsOffset != supEventsOffset) {
            infEventsOffset += subtypeSeparation;
        }
        [subtype setOffset:infEventsOffset];
        infEventsOffset += [subtype height];
    }
}

- (void)setInfEventsOffset
{
    [self setOffset:infEventsOffset ofSubtypes:infEventSubtypes];

    subcontainersOffset = infEventsOffset
                        + [self getMaxHeight:infEventSubtypes];
}

- (void)setVariablesOffset
{
    if ([variableSubtypes count] != 0) {
        if (subcontainersOffset != 0) {
            subcontainersOffset += subtypeSeparation;
        }
        [self setOffset:subcontainersOffset ofSubtypes:variableSubtypes];
        subcontainersOffset += [self getMaxHeight:variableSubtypes];
    }

    if (([containerSubtypes count] != 0) && (subcontainersOffset != 0)) {
        subcontainersOffset += subtypeSeparation;
    }
}

- (void)setOffsets
{
    [self setSupEventsOffset];
    [self setStatesOffset];
    [self setInfEventsOffset];
    [self setVariablesOffset];
    [containerSubtypes makeObjectsPerformSelector:_cmd];
}

@end
