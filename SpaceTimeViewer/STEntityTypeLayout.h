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
#ifndef _STEntityTypeLayout_h_
#define _STEntityTypeLayout_h_

// Paje
// ----
// STEntityTypeLayout.h
// holds the layout of an entity type, with information
// on how and where to draw one entity of this type.

// 25.aug.2004 BS  creation


#include <Foundation/Foundation.h>
#include "../General/Protocols.h"
#include "../General/PajeContainer.h"
#include "Shape.h"

@class STContainerTypeLayout;
@class STController;

@interface STEntityTypeLayout : NSObject
{
    PajeEntityType *entityType;

    ShapeFunction *shapeFunction;
    // pointer to function that creates a path of the entity representation.
    DrawFunction *drawFunction;
    // pointer to function that draws a path created by pathFunction.
    DrawFunction *highlightFunction;
    // pointer to function that highlights a path created by pathFunction.

    float height;
    float offset;   // from start of container 
                    // alternatively, could be rectincontainer (like container)
    BOOL drawsName;
                    
    STContainerTypeLayout *containerDescriptor;
    NSMutableDictionary *rectInContainer;
}

+ (STEntityTypeLayout *)descriptorWithEntityType:(PajeEntityType *)etype
                                     drawingType:(PajeDrawingType)dtype
                             containerDescriptor:(STContainerTypeLayout *)cDesc
                                      controller:(STController *)controller;
- (id)initWithEntityType:(PajeEntityType *)etype
     containerDescriptor:(STContainerTypeLayout *)cDesc
              controller:(STController *)controller;

- (void)registerDefaultsWithController:(STController *)controller;
- (NSString *)defaultKeyForKey:(NSString*)key;
- (float)defaultFloatForKey:(NSString *)key;
- (void)setDefaultFloat:(float)val forKey:(NSString *)key;

// accessor methods
- (PajeEntityType *)entityType;

- (void)setShapeFunction:(ShapeFunction *)f;
- (void)setDrawFunction:(DrawFunction *)f;
- (void)setHighlightFunction:(DrawFunction *)f;
- (ShapeFunction *)shapeFunction;
- (DrawFunction *)drawFunction;
- (DrawFunction *)highlightFunction;

- (void)setHeight:(float)newHeight;
- (float)height;

- (void)setDrawsName:(BOOL)draws;
- (BOOL)drawsName;

- (void)setOffset:(float)val;
- (float)offset;
- (float)yInContainer:(id)container;

- (void)setRect:(NSRect)rect inContainer:(id)container;
- (NSRect)rectInContainer:(id)container;
- (BOOL)intersectsRect:(NSRect)rect inContainer:(id)container;
- (BOOL)isPoint:(NSPoint)point
    inContainer:(id)container;
- (void)reset;

// methods to be implemented by subclasses
- (PajeDrawingType)drawingType;
- (BOOL)isContainer;

// from NSObject protocol
- (unsigned int)hash;
- (BOOL)isEqual:(id)other;
- (NSString *)description;
@end


@interface STEventTypeLayout : STEntityTypeLayout
{
    float width;
}

- (void)setWidth:(float)val;
- (float)width;

- (BOOL)isSupEvent;
@end

@interface STStateTypeLayout : STEntityTypeLayout
{
    float inset;    // Number of points one entity should be shorter than
                    //   another when imbricated.
}

// Number of points one entity should be shorter than another when imbricated.
- (void)setInsetAmount:(float)newInsetAmount;
- (float)insetAmount;
@end


@interface STLinkTypeLayout : STEntityTypeLayout
{
    // sourceOffset is offset of superclass
//    float sourceOffset; // from start of container 
    float destOffset;
    float lineWidth;
}

- (void)setLineWidth:(float)val;
- (float)lineWidth;

- (void)setSourceOffset:(float)val;
- (float)sourceOffset;

- (void)setDestOffset:(float)val;
- (float)destOffset;

@end


@interface STVariableTypeLayout : STEntityTypeLayout
{
    float lineWidth;
    // mais coisas
}

- (void)setLineWidth:(float)val;
- (float)lineWidth;

@end


@interface STContainerTypeLayout : STEntityTypeLayout
{
    float supEventsOffset;  // base of superior events
    float infEventsOffset;  // base of inferior events
    float subcontainersOffset;  // start of subcontainers
    
    float siblingSeparation; // separation from other containers of same type
                             // in same container
    float subtypeSeparation; // separation between two subtypes

    NSMutableDictionary *rectsOfInstances;

    // Subtypes:
    NSMutableArray *eventSubtypes;
    NSMutableArray *supEventSubtypes;
    NSMutableArray *stateSubtypes;
    NSMutableArray *infEventSubtypes;
    NSMutableArray *variableSubtypes;
    NSMutableArray *linkSubtypes;
    NSMutableArray *containerSubtypes;
}
    
- (void)setSiblingSeparation:(float)val;
- (float)siblingSeparation;

- (void)setSubtypeSeparation:(float)val;
- (float)subtypeSeparation;

- (void)setSupEventsOffset:(float)val;
- (float)supEventsOffset;

- (void)setInfEventsOffset:(float)val;
- (float)infEventsOffset;

- (void)setSubcontainersOffset:(float)val;
- (float)subcontainersOffset;

- (float)linkOffset;

// rect of each instance of this type
- (void)setRect:(NSRect)rect ofInstance:(id)entity;
- (NSRect)rectOfInstance:(id)entity;
- (BOOL)isInstance:(id)entity inRect:(NSRect)rect;
- (BOOL)isPoint:(NSPoint)point inInstance:(id)entity;
- (id)instanceWithPoint:(NSPoint)point;

- (NSEnumerator *)instanceEnumerator;

- (void)addSubtype:(STEntityTypeLayout *)subtype;

- (NSArray *)subtypes;

- (void)setOffsets;
@end

#endif
