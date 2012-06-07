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
/* PajeSimul+Events.m created by benhur on 12-nov-2002 (from A0bSimul) */

#include "PajeSimul.h"
#include "SimulContainer.h"
#include "../General/PajeType.h"
#include "UserEvent.h"
#include "../General/Macros.h"

@implementation PajeSimul (UserEvents)
//
// User defined entities
//

- (id)containerForId:(const char *)containerId
                type:(PajeContainerType *)containerType
{
    if (containerType == nil) {
        // Unknown type, search in all types.
        NSEnumerator *types;
        types = [NSAllMapTableValues(userTypes) objectEnumerator];
        while ((containerType = [types nextObject]) != nil) {
            if (![containerType isKindOfClass:[PajeContainerType class]]) {
                continue;
            }
            id container = [containerType instanceWithId:containerId];
            if (container != nil) {
                return container;
            }
        }
        return nil;
    }

    //if (![containerType isKindOfClass:[PajeContainerType class]]) {
    //    return nil;
    //}

    return [containerType instanceWithId:containerId];
}


- (void)pajeStartTrace:(PajeEvent *)event
{
//OLDEVENT    Assign(startTime, [event objectForKey:@"StartTime"]);
//OLDEVENT    Assign(endTime, [event objectForKey:@"EndTime"]);
}

- (void)pajeDefineContainerType:(PajeEvent *)event
{
    const char *containerTypeId;
    const char *newContainerTypeName;
    const char *newContainerTypeAlias;
    const char *newContainerTypeId;

    PajeContainerType *containerType;
    PajeContainerType *newContainerType;

    if (replaying) return;

    // get fields from event
    newContainerTypeName  = [event cStringForFieldId:PajeNameFieldId];
    newContainerTypeAlias = [event cStringForFieldId:PajeAliasFieldId];
    containerTypeId       = [event cStringForFieldId:PajeTypeFieldId];

    // verify presence of obligatory fields
    if (newContainerTypeName == NULL) {
        [self error:@"Missing \"Name\" field" inEvent:event];
    }
    if (containerTypeId == NULL) {
        [self error:@"Missing \"ContainerType\" field" inEvent:event];
    }

    containerType = [self typeForId:containerTypeId];
    if (containerType == nil) {
        [self error:@"Unknown container type" inEvent:event];
    }

    // if there is no alias, new type will be referenced by name
    if (newContainerTypeAlias != NULL) {
        newContainerTypeId = newContainerTypeAlias;
    } else {
        newContainerTypeId = newContainerTypeName;
    }
    // new type should not exist (but may, if replaying)
    if ([self typeForId:newContainerTypeId] != nil) {
        NSWarnLog(@"Redefining container type '%s' with event %@",
                  newContainerTypeId, event);
        return;
    }

    // create the new container type
    NSString *newContainerTypeNameO, *newContainerTypeIdO;
    newContainerTypeNameO = [NSString stringWithCString:newContainerTypeName];
    newContainerTypeIdO = [NSString stringWithCString:newContainerTypeId];
    newContainerType = [PajeContainerType typeWithId:newContainerTypeIdO
                                         description:newContainerTypeNameO
                                       containerType:containerType
                                               event:event];
    [self setType:newContainerType forId:newContainerTypeId];
    [(PajeFilter *)outputComponent hierarchyChanged];
}

- (void)pajeDefineLinkType:(PajeEvent *)event
{
    const char *containerTypeId;
    const char *sourceContainerTypeId;
    const char *destContainerTypeId;
    const char *newEntityTypeName;
    const char *newEntityTypeAlias;
    const char *newEntityTypeId;

    PajeContainerType *containerType;
    PajeContainerType *sourceContainerType;
    PajeContainerType *destContainerType;
    PajeEntityType *newEntityType;

    if (replaying) return;

    // get fields from event
    newEntityTypeName     = [event cStringForFieldId:PajeNameFieldId];
    newEntityTypeAlias    = [event cStringForFieldId:PajeAliasFieldId];
    containerTypeId       = [event cStringForFieldId:PajeTypeFieldId];
    sourceContainerTypeId = [event cStringForFieldId:PajeStartContainerTypeFieldId];
    destContainerTypeId   = [event cStringForFieldId:PajeEndContainerTypeFieldId];

    containerType = [self typeForId:containerTypeId];
    if (containerType == nil) {
        [self error:@"Unknown container type" inEvent:event];
    }

    sourceContainerType = [self typeForId:sourceContainerTypeId];
    if (sourceContainerType == nil) {
        [self error:@"Unknown source container type" inEvent:event];
    }

    destContainerType = [self typeForId:destContainerTypeId];
    if (destContainerType == nil) {
        [self error:@"Unknown dest container type" inEvent:event];
    }

    // if there is no alias, new type will be referenced by name
    if (newEntityTypeAlias != NULL) {
        newEntityTypeId = newEntityTypeAlias;
    } else {
        newEntityTypeId = newEntityTypeName;
    }
    // new type should not exist
    if ([self typeForId:newEntityTypeId] != nil) {
        NSWarnLog(@"Redefining entity type id '%s' with event %@",
                  newEntityTypeId, event);
        return;
    }

    NSString *newEntityTypeNameO, *newEntityTypeIdO;
    newEntityTypeNameO = [NSString stringWithCString:newEntityTypeName];
    newEntityTypeIdO = [NSString stringWithCString:newEntityTypeId];
    newEntityType = [PajeLinkType typeWithId:newEntityTypeIdO
                                 description:newEntityTypeNameO
                               containerType:containerType
                         sourceContainerType:sourceContainerType
                           destContainerType:destContainerType
                                       event:event];
    [self setType:newEntityType forId:newEntityTypeId];

    [(PajeFilter *)outputComponent hierarchyChanged];
}

- (void)_defineUserEntityType:(PajeEvent *)event
                  drawingType:(PajeDrawingType)drawingType
{
    const char *containerTypeId;
    const char *newEntityTypeName;
    const char *newEntityTypeAlias;
    const char *newEntityTypeId;

    PajeContainerType *containerType = nil;
    PajeEntityType *newEntityType = nil;

    if (replaying) return;

    // get fields from event
    newEntityTypeName  = [event cStringForFieldId:PajeNameFieldId];
    newEntityTypeAlias = [event cStringForFieldId:PajeAliasFieldId];
    containerTypeId    = [event cStringForFieldId:PajeTypeFieldId];

    // if there is no alias, new type will be referenced by name
    if (newEntityTypeAlias != NULL) {
        newEntityTypeId = newEntityTypeAlias;
    } else {
        newEntityTypeId = newEntityTypeName;
    }
    // new type should not exist
    if ([self typeForId:newEntityTypeId] != nil) {
        NSWarnLog(@"Redefining entity type id '%s' with event %@",
                  newEntityTypeId, event);
        return;
    }

    containerType = [self typeForId:containerTypeId];
    if (containerType == nil) {
        [self error:@"Unknown container type" inEvent:event];
    }

    NSString *newEntityTypeNameO, *newEntityTypeIdO;
    newEntityTypeNameO = [NSString stringWithCString:newEntityTypeName];
    newEntityTypeIdO = [NSString stringWithCString:newEntityTypeId];
    switch (drawingType) {
    case PajeEventDrawingType:
        newEntityType = [PajeEventType typeWithId:newEntityTypeIdO
                                      description:newEntityTypeNameO
                                    containerType:containerType
                                            event:event];
        break;
    case PajeStateDrawingType:
        newEntityType = [PajeStateType typeWithId:newEntityTypeIdO
                                      description:newEntityTypeNameO
                                    containerType:containerType
                                            event:event];
        break;
    case PajeVariableDrawingType:
        newEntityType = [PajeVariableType typeWithId:newEntityTypeIdO
                                         description:newEntityTypeNameO
                                       containerType:containerType
                                               event:event];
        break;
    default:
        [self error:@"Internal simulator error: unknown drawing type"
            inEvent:event];
    }

    [self setType:newEntityType forId:newEntityTypeId];

    [(PajeFilter *)outputComponent hierarchyChanged];
}

- (void)pajeDefineEventType:(PajeEvent *)event
{
    [self _defineUserEntityType:event drawingType:PajeEventDrawingType];
}

- (void)pajeDefineStateType:(PajeEvent *)event
{
    [self _defineUserEntityType:event drawingType:PajeStateDrawingType];
}

- (void)pajeDefineVariableType:(PajeEvent *)event
{
    [self _defineUserEntityType:event drawingType:PajeVariableDrawingType];
}


- (void)pajeDefineEntityValue:(PajeEvent *)event
{
    const char *newEntityValueAlias;
    NSString *newEntityValueName;
    const char *entityTypeId;
    NSColor *color;

    PajeEntityType *entityType;

    if (replaying) return;

    // get fields from event
    newEntityValueName  = [event stringForFieldId:PajeNameFieldId];
    newEntityValueAlias = [event cStringForFieldId:PajeAliasFieldId];
    entityTypeId        = [event cStringForFieldId:PajeTypeFieldId];
    color               = [event colorForFieldId:PajeColorFieldId];

    entityType = [self typeForId:entityTypeId];
    if (entityType == nil) {
        [self error:@"Unknown entity type" inEvent:event];
    }

    if ([entityType drawingType] == PajeVariableDrawingType) {
        NSWarnLog(@"Values of variables cannot be named in event %@", event);
        return;
    }

    if (color != nil) {
        [(PajeEventType *)entityType setValue:newEntityValueName
                                        alias:newEntityValueAlias
                                        color:color];
    } else {
        [(PajeEventType *)entityType setValue:newEntityValueName
                                        alias:newEntityValueAlias];
    }
}



- (void)pajeCreateContainer:(PajeEvent *)event
{
    const char *newContainerTypeId;
    const char *containerId;
    const char *newContainerName;
    const char *newContainerAlias;
    const char *newContainerId;

    PajeContainerType *typeOfNewContainer;
    PajeContainer *container;
    PajeContainer *newContainer;

    if (replaying) return;

    // get fields from event
    newContainerName   = [event cStringForFieldId:PajeNameFieldId];
    newContainerAlias  = [event cStringForFieldId:PajeAliasFieldId];
    newContainerTypeId = [event cStringForFieldId:PajeTypeFieldId];
    containerId        = [event cStringForFieldId:PajeContainerFieldId];

    if (newContainerName == NULL) {
        [self error:@"Missing \"Name\" field" inEvent:event];
    }
    if (newContainerTypeId == NULL) {
        [self error:@"Missing \"Type\" field" inEvent:event];
    }
    if (containerId == NULL) {
        [self error:@"Missing \"Container\" field" inEvent:event];
    }

    typeOfNewContainer = [self typeForId:newContainerTypeId];
    if (!typeOfNewContainer) {
        [self error:@"Unknown container type" inEvent:event];
    }

    if (newContainerAlias != NULL) {
        newContainerId = newContainerAlias;
    } else {
        newContainerId = newContainerName;
    }
    if ([self containerForId:newContainerId
                        type:typeOfNewContainer] != nil) {
        NSWarnLog(@"Redefining container id '%s' in event %@",
                  newContainerId, event);
        return;
    }

    container = [self containerForId:containerId
                                type:[typeOfNewContainer containerType]];
    if (container == nil) {
        [self error:@"Unknown container" inEvent:event];
    }
    
    newContainer = [SimulContainer containerWithType:typeOfNewContainer
                                                name:[NSString stringWithCString:newContainerName]
                                               alias:[NSString stringWithCString:newContainerAlias]
                                           container:container
                                        creationTime:[event time]
                                               event: event
                                           simulator:self];
    [container addSubContainer:newContainer];
    [typeOfNewContainer addInstance:newContainer
                                id1:newContainerId id2:NULL];

    [(PajeFilter *)outputComponent hierarchyChanged];
}

- (void)pajeDestroyContainer:(PajeEvent *)event
{
    const char *containerId;
    const char *containerTypeId;
    PajeContainerType *containerType;

    SimulContainer *container;

//    if (replaying) return;

    // get fields from event
    containerId     = [event cStringForFieldId:PajeNameFieldId];
    if (containerId == NULL) {
        containerId = [event cStringForFieldId:PajeContainerFieldId];
    }
    containerTypeId = [event cStringForFieldId:PajeTypeFieldId];

    containerType = [self typeForId:containerTypeId];
    if (containerType == nil) {
        NSWarnLog(@"Unknown container type in event %@", event);
        //[self error:@"Unknown container type" inEvent:event];
    }
 
    container = [self containerForId:containerId
                                type:containerType];
    if (container == nil) {
        [self error:@"Unknown container" inEvent:event];
        return;
    }

    [container stopWithEvent:event];
}



- (void)_getEntityType:(PajeEntityType **)entityType
                 value:(id *)entityValue
             container:(PajeContainer **)container
             fromEvent:(PajeEvent *)event
{
    const char *entityTypeId;
    const char *containerId;

    if (entityType != NULL) {
        entityTypeId = [event cStringForFieldId:PajeTypeFieldId];
        *entityType = [self typeForId:entityTypeId];
        if (*entityType == nil) {
            [self error:@"Unknown entity type" inEvent:event];
        }
    }

    if (entityType != NULL && container != NULL) {
        containerId = [event cStringForFieldId:PajeContainerFieldId];
        *container = [self containerForId:containerId
                                     type:[*entityType containerType]];
        if (*container == nil) {
            [self error:@"Unknown container" inEvent:event];
        }
    }

    if (entityValue != NULL) {
        const char *csvalue;
        id value;
        csvalue = [event cStringForFieldId:PajeValueFieldId];
        if (entityType != NULL 
            && [*entityType isKindOfClass:[PajeCategorizedEntityType class]]) {
            PajeCategorizedEntityType *type = (id)*entityType;
            value = [type valueForAlias:csvalue];
        } else {
            value = [NSString stringWithCString:csvalue];
        }
        *entityValue = value;
    }
}

- (void)pajeNewEvent:(PajeEvent *)event
{
    PajeEventType *entityType;
    SimulContainer *container;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    [container newEventWithType:entityType
                          value:entityValue
                      withEvent:event];
}

- (void)pajeSetState:(PajeEvent *)event
{
    PajeStateType *entityType;
    SimulContainer *container;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];
    
    [container setUserStateOfType:entityType
                          toValue:entityValue
                        withEvent:event];
}

- (void)pajePushState:(PajeEvent *)event
{
    PajeStateType *entityType;
    SimulContainer *container;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    [container pushUserStateOfType:entityType
                             value:entityValue
                         withEvent:event];
}

- (void)pajePopState:(PajeEvent *)event
{
    PajeStateType *entityType;
    SimulContainer *container;

    [self _getEntityType:&entityType
                   value:NULL
               container:&container
               fromEvent:event];

    [container popUserStateOfType:entityType
                        withEvent:event];
}

- (void)pajeResetState:(PajeEvent *)event
{
    PajeStateType *entityType;
    SimulContainer *container;

    [self _getEntityType:&entityType
                   value:NULL
               container:&container
               fromEvent:event];

    [container resetUserStateOfType:entityType
                          withEvent:event];
}

- (void)pajeSetVariable:(PajeEvent *)event
{
    PajeVariableType *entityType;
    SimulContainer *container;
    double entityValue;

    [self _getEntityType:&entityType
                   value:NULL
               container:&container
               fromEvent:event];
    entityValue = [event doubleForFieldId:PajeValueFieldId];

    [container setUserVariableOfType:entityType
                       toDoubleValue:entityValue
                           withEvent:event];
}
- (void)pajeAddVariable:(PajeEvent *)event
{
    PajeVariableType *entityType;
    SimulContainer *container;
    double entityValue;

    [self _getEntityType:&entityType
                   value:NULL
               container:&container
               fromEvent:event];
    entityValue = [event doubleForFieldId:PajeValueFieldId];

    [container addUserVariableOfType:entityType
                         doubleValue:entityValue
                           withEvent:event];
}
- (void)pajeSubVariable:(PajeEvent *)event
{
    PajeVariableType *entityType;
    SimulContainer *container;
    double entityValue;

    [self _getEntityType:&entityType
                   value:NULL
               container:&container
               fromEvent:event];
    entityValue = [event doubleForFieldId:PajeValueFieldId];

    [container subUserVariableOfType:entityType
                         doubleValue:entityValue
                           withEvent:event];
}


- (void)pajeStartLink:(PajeEvent *)event
{
    const char *sourceContainerId;
    PajeLinkType *entityType;
    SimulContainer *container;
    PajeContainer *sourceContainer;
    id entityValue;
    id key;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    sourceContainerId = [event cStringForFieldId:PajeStartContainerFieldId];
    key               = [event stringForFieldId:PajeKeyFieldId];
    sourceContainer   = [self containerForId:sourceContainerId
                                        type:[entityType sourceContainerType]];
    if (sourceContainer == nil) {
        [self error:@"Unknown source container" inEvent:event];
        return;
    }

    [container startUserLinkOfType:entityType
                             value:entityValue
                   sourceContainer:sourceContainer
                               key:key
                         withEvent:event];
}

- (void)pajeEndLink:(PajeEvent *)event
{
    const char *destContainerNumber;
    PajeLinkType *entityType;
    SimulContainer *container;
    PajeContainer *destContainer;
    id entityValue;
    id key;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    destContainerNumber = [event cStringForFieldId:PajeEndContainerFieldId];
    key                 = [event stringForFieldId:PajeKeyFieldId];
    destContainer = [self containerForId:destContainerNumber
                                    type:[entityType destContainerType]];
    if (destContainer == nil) {
        [self error:@"Unknown destination container" inEvent:event];
        return;
    }

    [container endUserLinkOfType:entityType
                           value:entityValue
                   destContainer:destContainer
                             key:key
                       withEvent:event];
}

@end
