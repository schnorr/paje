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
#ifndef _PajeFilter_h_
#define _PajeFilter_h_

/*
 * PajeFilter.h
 *
 * Base class of Paje filters.
 * Keeps the graph of filters;
 * forwards all notifications to following component;
 * forwards all queries to preceeding component.
 *
 * created by benhur on 11 may 1999
 */

#include <AppKit/AppKit.h>
#include "Protocols.h"
#include "PajeContainer.h"
//#include "../Paje/PajeTraceController.h"
@class PajeTraceController;

@class PajeFilter;
@interface PajeComponent : NSObject
{
    PajeFilter *outputComponent;
    PajeFilter *inputComponent;
    SEL outputSelector;
    PajeTraceController *controller;
}

+ (PajeComponent *)componentWithController:(PajeTraceController *)c;
- (id)initWithController:(PajeTraceController *)c;

- (void)setInputComponent:(PajeComponent *)component;
- (void)setOutputComponent:(PajeComponent *)component;

- (void)inputEntity:(id)entity;
- (void)outputEntity:(id)entity;

- (NSString *)traceDescription; /* only for use by simulator */

- (void)registerFilter:(PajeFilter *)filter;
- (void)registerTool:(id<PajeTool>)filter;

- (NSString *)toolName;
- (NSString *)filterName;
- (NSView *)filterView;
- (NSString *)filterKeyEquivalent;
- (id)filterDelegate;
@end

@interface PajeFilter : PajeComponent
{
}

//
// Notifications
// -----------------------------------------------------------------
// Messages sent by a filter to the filter after it in the filter chain.
// They are used to inform the filters (and visualisation modules) that
// something has changed. Default implementation just forwards the message.
// Filters can intercept a message if the change affects it and act accordingly.
// Viewers can intercept a message if the change means that something needs
// redrawing.
//

// Generic message. Used when something not specified in the other messages
// has changed. entityType can be nil if not only one entityType is affected.
- (void)dataChangedForEntityType:(PajeEntityType *)entityType;

// Message sent when the color of something of entityType has changed.
- (void)colorChangedForEntityType:(PajeEntityType *)entityType;

// Message sent when the order of the containers of some type has changed.
- (void)orderChangedForContainerType:(PajeEntityType *)containerType;

// Message sent when the hierarchy of types and/or containers has changed.
- (void)hierarchyChanged;

// Message sent when containers have been (de)selected.
- (void)containerSelectionChanged;

// Message sent when the selected time slice has changed (or deselected).
- (void)timeSelectionChanged;


//
// Commands
// -----------------------------------------------------------------
// Messages sent from a viewer or a filter to the preceeding filter.
// Generally used to cause some filter to change its configuration.
// Default implementation just forwards the message to the preceeding filter.
// First filter (StorageController for the time being) overrides the
// default implementation to ignore the message, generally.
//

// Command a filter to remove entityType from the type hierarchy.
- (void)hideEntityType:(PajeEntityType *)entityType;

// Command a filter to remove the selected containers from hierarchy
- (void)hideSelectedContainers;

// Command a filter to change the containers that are selected to the given set.
- (void)setSelectedContainers:(NSSet *)containers;

// Command a filter to change the selected time slice
- (void)setSelectionStartTime:(NSDate *)from endTime:(NSDate *)to;

// Command a filter to change the order of the given containers to that of
// the given array.
- (void)setOrder:(NSArray *)containers
ofContainersTyped:(PajeEntityType *)containerType
     inContainer:(PajeContainer *)container;

// Command a filter to change the color of the given entity.
- (void)setColor:(NSColor *)color
       forEntity:(id<PajeEntity>)entity;
       
// Command a filter to change the color of a given value of an entity type.
- (void)setColor:(NSColor *)color
         forName:(id)name
    ofEntityType:(PajeEntityType *)entityType;

// Command a filter to change the color for all entities of a given type
// (used for "variable" entity types).
- (void)setColor:(NSColor *)color
   forEntityType:(PajeEntityType *)entityType;

// Command a filter (StorageController) to verify that all entities on
// given time period are accessible.
- (void)verifyStartTime:(NSDate *)start endTime:(NSDate *)end;

// Command a filter to open an inspection window to inspect given entity.
- (void)inspectEntity:(id<PajeInspecting>)entity;


//
// Queries
// -----------------------------------------------------------------
// Messages sent by viewers or filters to the filter preceeding it.
// These messages ask for some information about the loaded trace.
//

// The time period of the trace
- (NSDate *)startTime;
- (NSDate *)endTime;

// The group of containers that are selected
- (NSSet *)selectedContainers;

// The time selection
- (NSDate *)selectionStartTime;
- (NSDate *)selectionEndTime;

//
// Accessing entities
//

// The entity at the root of the hierarchy
- (PajeContainer *)rootInstance;

// Array of types that are directly under given type in hierarchy
- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType;

// The type that contains the given type
- (PajeEntityType *)containerTypeForType:(PajeEntityType *)entityType;

// All entities of a given type that are in a container. Container must be
// of a type ancestral of entityType in the hierarchy.
- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end;

// All containers of a given type contained by container. Container must be
// of a type ancestral of entityType in the hierarchy.
- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container;

// All values an entity of given type can have.
- (NSArray *)allNamesForEntityType:(PajeEntityType *)entityType;

// Textual description of an entity type.
- (NSString *)descriptionForEntityType:(PajeEntityType *)entityType;

// Minimum and maximum value of a "variable" entity type, globally or inside
// a container.
- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType;
- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType;
- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container;
- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container;

//- (BOOL)isHiddenEntityType:(PajeEntityType *)entityType;

// The drawing type of an entityType.
- (PajeDrawingType)drawingTypeForEntityType:(PajeEntityType *)entityType;

// Names of fields an entity of given type can have.
- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType;

// Names of fields an entity of given value and type can have.
- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
                                name:(NSString *)name;

// The value of the given named field for an entity type.
- (id)valueOfFieldNamed:(NSString *)fieldName
          forEntityType:(PajeEntityType *)entityType;

// Color of given value of entity type
- (NSColor *)colorForName:(NSString *)name
             ofEntityType:(PajeEntityType *)entityType;
             
// Color for all entities of given type (used for "variable" entity type).
- (NSColor *)colorForEntityType:(PajeEntityType *)entityType;

//
// Getting info from entity
//
- (NSArray *)fieldNamesForEntity:(id<PajeEntity>)entity;
- (id)valueOfFieldNamed:(NSString *)fieldName forEntity:(id<PajeEntity>)entity;

- (PajeContainer *)containerForEntity:(id<PajeEntity>)entity;
- (PajeEntityType *)entityTypeForEntity:(id<PajeEntity>)entity;
- (PajeContainer *)sourceContainerForEntity:(id<PajeLink>)entity;
- (PajeEntityType *)sourceEntityTypeForEntity:(id<PajeLink>)entity;
- (PajeContainer *)destContainerForEntity:(id<PajeLink>)entity;
- (PajeEntityType *)destEntityTypeForEntity:(id<PajeLink>)entity;
- (NSArray *)relatedEntitiesForEntity:(id<PajeEntity>)entity;
- (NSColor *)colorForEntity:(id<PajeEntity>)entity;
- (NSDate *)startTimeForEntity:(id<PajeEntity>)entity;
- (NSDate *)endTimeForEntity:(id<PajeEntity>)entity;
- (NSDate *)timeForEntity:(id<PajeEntity>)entity;
- (PajeDrawingType)drawingTypeForEntity:(id<PajeEntity>)entity;
- (NSString *)nameForEntity:(id<PajeEntity>)entity;
- (NSNumber *)valueForEntity:(id<PajeEntity>)entity; // for variables
- (NSString *)descriptionForEntity:(id<PajeEntity>)entity;
- (int)imbricationLevelForEntity:(id<PajeEntity>)entity;

- (BOOL)canHighlightEntity:(id<PajeEntity>)entity;

// configure filter
- (id)configuration;
- (void)setConfiguration:(id)config;
@end

@interface PajeFilter(AuxiliaryMethods)
- (PajeEntityType *)rootEntityType;
- (NSArray *)allEntityTypes;
- (BOOL)isContainerEntityType:(PajeEntityType *)entityType;

- (PajeEntityType *)entityTypeWithName:(NSString *)n;
- (PajeContainer *)containerWithName:(NSString *)n
                                type:(PajeEntityType *)t;
@end

#endif
