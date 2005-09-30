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
//#define COMPATIBILITY
#include "PajeFilter.h"
#include "../Paje/PajeTraceController.h"


@implementation PajeComponent

+ (PajeComponent *)componentWithController:(PajeTraceController *)c
{
    return [[[self alloc] initWithController:c] autorelease];
}

- (id)initWithController:(PajeTraceController *)c
{
    self = [super init];
    controller = c;
    outputSelector = @selector(inputEntity:);
    return self;
}

- (id)init
{
    NSLog(@"Shouldn't call init in a PajeComponent [%@]", self);
    NSAssert(0, @"Bye");
    self = [super init];
    NSLog(@"%@ no init", self);
    outputSelector = @selector(inputEntity:);
    return self;
}

- (void)dealloc
{
    [outputComponent release]; // HACK (see setOutputComponent:)
    [super dealloc];
}

- (void)setInputComponent:(id)component
{
    inputComponent = component;
}

- (void)setOutputComponent:(id)component
{
    if (outputComponent != nil) { // HACK
        if ([outputComponent isKindOfClass: [NSMutableArray class]]) {
            [(NSMutableArray *)outputComponent addObject:component];
        } else {
            [outputComponent release];
            outputComponent = [[NSMutableArray arrayWithObjects:outputComponent, component, nil] retain];
        }
    } else {
        outputComponent = [component retain];
    }
}

- (void)inputEntity:(id)entity
{
    NSAssert(0, @"should be implemented in subclass!");
}

- (void)outputEntity:(id)entity
{
    if ([outputComponent isKindOfClass:[NSArray class]]) // HACK
        [(NSArray*)outputComponent makeObjectsPerformSelector:outputSelector withObject:entity];
    else
        [outputComponent performSelector:outputSelector withObject:entity];
}

/* only for use by simulator */
- (NSString *)traceDescription
{
    return [inputComponent traceDescription];
}


- (void)registerFilter:(PajeFilter *)filter
{
    [controller registerFilter:filter];
}

- (NSString *)filterName
{
    return NSStringFromClass([self class]);
}

- (NSString *)toolName
{
    return [self filterName];
}

- (NSView *)filterView
{
    return nil;
}

- (NSString *)filterKeyEquivalent;
{
    return @"";
}

- (id)filterDelegate
{
    return nil;
}

- (void)registerTool:(id<PajeTool>)filter
{
    [controller registerTool:filter];
}
@end



@implementation PajeFilter

//
// Deal with notifications
//
- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
	[(NSArray *)outputComponent makeObjectsPerformSelector:_cmd 
                                                    withObject:entityType];
    } else {
        [outputComponent dataChangedForEntityType:entityType];
    }
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
	[(NSArray *)outputComponent makeObjectsPerformSelector:_cmd 
                                                    withObject:entityType];
    } else {
        [outputComponent colorChangedForEntityType:entityType];
    }
}

- (void)orderChangedForContainerType:(PajeEntityType *)containerType;
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
	[(NSArray *)outputComponent makeObjectsPerformSelector:_cmd 
                                                    withObject:containerType];
    } else {
        [outputComponent orderChangedForContainerType:containerType];
    }
}

- (void)hierarchyChanged
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
        [(NSArray*)outputComponent makeObjectsPerformSelector:_cmd];
    } else {
        [outputComponent hierarchyChanged];
    }
}

- (void)containerSelectionChanged
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
        [(NSArray*)outputComponent makeObjectsPerformSelector:_cmd];
    } else {
        [outputComponent containerSelectionChanged];
    }
}

- (void)timeSelectionChanged
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
        [(NSArray*)outputComponent makeObjectsPerformSelector:_cmd];
    } else {
        [outputComponent timeSelectionChanged];
    }
}

- (void)entitySelectionChanged
{
    if ([outputComponent isKindOfClass:[NSArray class]]) {
        [(NSArray*)outputComponent makeObjectsPerformSelector:_cmd];
    } else {
        [outputComponent entitySelectionChanged];
    }
}


//
// Filter commands
//

- (void)hideEntityType:(PajeEntityType *)entityType
{
    [inputComponent hideEntityType:entityType];
}

- (void)hideSelectedContainers
{
    [inputComponent hideSelectedContainers];
}

- (void)setSelectedContainers:(NSSet *)containers
{
    [inputComponent setSelectedContainers:containers];
}

- (void)setOrder:(NSArray *)containers
ofContainersTyped:(PajeEntityType *)containerType
     inContainer:(PajeContainer *)container
{
    [inputComponent setOrder:containers
           ofContainersTyped:containerType
                 inContainer:container];
}

- (void)setSelectionStartTime:(NSDate *)from
                      endTime:(NSDate *)to
{
    [inputComponent setSelectionStartTime:from
                                  endTime:to];
}

- (void)setColor:(NSColor *)color
         forName:(NSString *)name
    ofEntityType:(PajeEntityType *)entityType
{
    [inputComponent setColor:color
                     forName:name
                ofEntityType:entityType];
}

- (void)setColor:(NSColor *)color
   forEntityType:(PajeEntityType *)entityType
{
    [inputComponent setColor:color
               forEntityType:entityType];
}

- (void)setColor:(NSColor *)color forEntity:(id<PajeEntity>)entity;
{
    [inputComponent setColor:color
                   forEntity:entity];
}


- (void)verifyStartTime:(NSDate *)start endTime:(NSDate *)end
{
    [inputComponent verifyStartTime:start endTime:end];
}



//
// Inspecting an entity
//
- (void)inspectEntity:(id<PajeEntity>)entity
{
    [inputComponent inspectEntity:entity];
}


//
// Deal with queries
//

//
// Accessing entities
//


- (NSDate *)startTime
{
    return [inputComponent startTime];
}

- (NSDate *)endTime
{
    return [inputComponent endTime];
}
- (PajeContainer *)rootInstance
{
    return [inputComponent rootInstance];
}

- (NSDate *)selectionStartTime
{
    return [inputComponent selectionStartTime];
}

- (NSDate *)selectionEndTime
{
    return [inputComponent selectionEndTime];
}

- (NSSet *)selectedContainers
{
    return [inputComponent selectedContainers];
}

- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
    return [inputComponent containedTypesForContainerType:containerType];
}

- (PajeEntityType *)containerTypeForType:(PajeEntityType *)entityType
{
    return [inputComponent containerTypeForType:entityType];
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
    return [inputComponent enumeratorOfEntitiesTyped:entityType
                                         inContainer:container
                                            fromTime:start
                                              toTime:end
                                         minDuration:minDuration];
}

- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container
{
    return [inputComponent enumeratorOfContainersTyped:entityType
                                           inContainer:container];
}

- (NSArray *)allNamesForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent allNamesForEntityType:entityType];
}

- (NSString *)descriptionForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent descriptionForEntityType:entityType];
}

- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent minValueForEntityType:entityType];
}

- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent maxValueForEntityType:entityType];
}

- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container
{
    return [inputComponent minValueForEntityType:entityType
                                     inContainer:container];
}

- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container
{
    return [inputComponent maxValueForEntityType:entityType
                                     inContainer:container];
}



- (BOOL)isHiddenEntityType:(PajeEntityType *)entityType
{
    return [inputComponent isHiddenEntityType:entityType];
}

- (PajeDrawingType)drawingTypeForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent drawingTypeForEntityType:entityType];
}

- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent fieldNamesForEntityType:entityType];
}

- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
                                name:(NSString *)name
{
    return [inputComponent fieldNamesForEntityType:entityType name:name];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
          forEntityType:(PajeEntityType *)entityType
{
    return [inputComponent valueOfFieldNamed:fieldName
                               forEntityType:entityType];
}

- (NSColor *)colorForName:(NSString *)name ofEntityType:(PajeEntityType *)entityType
{
    return [inputComponent colorForName:name ofEntityType:entityType];
}

- (NSColor *)colorForEntityType:(PajeEntityType *)entityType
{
    return [inputComponent colorForEntityType:entityType];
}

//
// Getting info from entity
//
- (NSArray *)fieldNamesForEntity:(id<PajeEntity>)entity
{
    return [inputComponent fieldNamesForEntity:entity];
}

- (id)valueOfFieldNamed:(NSString *)fieldName forEntity:(id<PajeEntity>)entity
{
    return [inputComponent valueOfFieldNamed:fieldName forEntity:entity];
}


- (PajeContainer *)containerForEntity:(id<PajeEntity>)entity
{
    return [inputComponent containerForEntity:entity];
}

- (PajeEntityType *)entityTypeForEntity:(id<PajeEntity>)entity
{
    return [inputComponent entityTypeForEntity:entity];
}

- (PajeContainer *)sourceContainerForEntity:(id<PajeLink>)entity
{
    return [inputComponent sourceContainerForEntity:entity];
}

- (PajeEntityType *)sourceEntityTypeForEntity:(id<PajeLink>)entity
{
    return [inputComponent sourceEntityTypeForEntity:entity];
}

- (PajeContainer *)destContainerForEntity:(id<PajeLink>)entity
{
    return [inputComponent destContainerForEntity:entity];
}

- (PajeEntityType *)destEntityTypeForEntity:(id<PajeLink>)entity
{
    return [inputComponent destEntityTypeForEntity:entity];
}

- (NSArray *)relatedEntitiesForEntity:(id<PajeEntity>)entity
{
    return [inputComponent relatedEntitiesForEntity:entity];
}

- (NSColor *)colorForEntity:(id<PajeEntity>)entity
{
    return [inputComponent colorForEntity:entity];
}

- (NSDate *)startTimeForEntity:(id<PajeEntity>)entity
{
    return [inputComponent startTimeForEntity:entity];
}

- (NSDate *)endTimeForEntity:(id<PajeEntity>)entity
{
    return [inputComponent endTimeForEntity:entity];
}

- (NSDate *)timeForEntity:(id<PajeEntity>)entity
{
    return [inputComponent timeForEntity:entity];
}

- (double)durationForEntity:(id<PajeEntity>)entity
{
    return [inputComponent durationForEntity:entity];
}

- (PajeDrawingType)drawingTypeForEntity:(id<PajeEntity>)entity
{
    return [inputComponent drawingTypeForEntity:entity];
}

- (NSString *)nameForEntity:(id<PajeEntity>)entity
{
    return [inputComponent nameForEntity:entity];
}

- (NSNumber *)valueForEntity:(id<PajeEntity>)entity // for variables
{
    return [inputComponent valueForEntity:entity];
}

- (NSString *)descriptionForEntity:(id<PajeEntity>)entity
{
    return [inputComponent descriptionForEntity:entity];
}

- (int)imbricationLevelForEntity:(id<PajeEntity>)entity
{
    return [inputComponent imbricationLevelForEntity:entity];
}



- (BOOL)canHighlightEntity:(id<PajeEntity>)entity
{
    return [inputComponent canHighlightEntity:entity];
}

- (BOOL)isSelectedEntity:(id<PajeEntity>)entity
{
    return [inputComponent isSelectedEntity:entity];
}


// configure filter
- (id)configuration
{
    return nil;
}

- (void)setConfiguration:(id)config
{
}

@end

@implementation PajeFilter(AuxiliaryMethods)
- (PajeEntityType *)rootEntityType
{
    return [self entityTypeForEntity:[self rootInstance]];
}

- (NSArray *)allEntityTypes
{
    NSMutableArray *allEntityTypes;
    int index;
    id rootEntityType = [self rootEntityType];
    
    if (rootEntityType == nil) {
        return [NSArray array];
    }
    
    allEntityTypes = [NSMutableArray arrayWithObject:rootEntityType];
    index = 0;
    while (index < [allEntityTypes count]) {
        [allEntityTypes addObjectsFromArray:[self containedTypesForContainerType:[allEntityTypes objectAtIndex:index]]];
        index++;
    }
    return allEntityTypes;
}

- (BOOL)isContainerEntityType:(PajeEntityType *)entityType
{
    return [self drawingTypeForEntityType:entityType]
           == PajeContainerDrawingType;
}

- (PajeEntityType *)entityTypeWithName:(NSString *)n
{
    NSEnumerator *entityTypeEnum;
    PajeEntityType *entityType;
    
    entityTypeEnum = [[self allEntityTypes] objectEnumerator];
    while ((entityType = [entityTypeEnum nextObject]) != nil) {
        if ([n isEqual:[self descriptionForEntityType:entityType]]) {
            break;
        }
    }
    return entityType;
}

- (PajeContainer *)containerWithName:(NSString *)n
                                type:(PajeEntityType *)t
{
    NSEnumerator *containerEnum;
    PajeContainer *container;
    
    containerEnum = [self enumeratorOfContainersTyped:t
                                          inContainer:[self rootInstance]];
    while ((container = [containerEnum nextObject]) != nil) {
        if ([n isEqual:[self nameForEntity:container]]) {
            break;
        }
    }
    return container;
}

@end
