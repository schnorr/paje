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
- (void)registerTool:(PajeFilter *)filter;

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
//
- (void)dataChangedForEntityType:(PajeEntityType *)entityType;
- (void)colorChangedForEntityType:(PajeEntityType *)entityType;
- (void)orderChangedForContainerType:(PajeEntityType *)containerType;
- (void)hierarchyChanged;
- (void)containerSelectionChanged;
- (void)timeSelectionChanged;

//
// Commands
// -----------------------------------------------------------------
//

- (void)hideEntityType:(PajeEntityType *)entityType;
- (void)hideSelectedContainers;
- (void)setSelectedContainers:(NSSet *)containers;
- (void)setSelectionStartTime:(NSDate *)from endTime:(NSDate *)to;
- (void)setOrder:(NSArray *)containers
ofContainersTyped:(PajeEntityType *)containerType
     inContainer:(PajeContainer *)container;

- (void)setColor:(NSColor *)color
       forEntity:(id<PajeEntity>)entity;
- (void)setColor:(NSColor *)color
         forName:(id)name
    ofEntityType:(PajeEntityType *)entityType;
- (void)setColor:(NSColor *)color
   forEntityType:(PajeEntityType *)entityType;

- (void)verifyStartTime:(NSDate *)start endTime:(NSDate *)end;

//
// Inspecting an entity
//
- (void)inspectEntity:(id<PajeInspecting>)entity;


//
// Queries
// -----------------------------------------------------------------
//

- (NSDate *)startTime;
- (NSDate *)endTime;

- (NSSet *)selectedContainers;

- (NSDate *)selectionStartTime;
- (NSDate *)selectionEndTime;

//
// Accessing entities
//
- (PajeContainer *)rootInstance;

- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType;
- (PajeEntityType *)containerTypeForType:(PajeEntityType *)entityType;

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end;

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container;

- (NSArray *)allNamesForEntityType:(PajeEntityType *)entityType;
- (NSString *)descriptionForEntityType:(PajeEntityType *)entityType;

- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType;
- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType;
- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container;
- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container;

//- (BOOL)isHiddenEntityType:(PajeEntityType *)entityType;
- (PajeDrawingType)drawingTypeForEntityType:(PajeEntityType *)entityType;
- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType;
- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
                                name:(NSString *)name;
- (id)valueOfFieldNamed:(NSString *)fieldName
          forEntityType:(PajeEntityType *)entityType;

// Colors
// - when each entity name has a different color
- (NSColor *)colorForName:(NSString *)name
             ofEntityType:(PajeEntityType *)entityType;
// - when there's one color for entity type (variables)
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
@end

#endif
