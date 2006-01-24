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

- (id)containerOfNumber:(NSString *)containerNumber
                   type:(id)containerType
                inEvent:(PajeEvent *)event
{
    if (containerType == nil) {
        // GAMBIARRA, deveria procurar em todos os tipos
        // precisa disso por causa de PajeDestroyContainer, que antes
        // nao tinha o tipo do container a destruir
        return [userNumberToContainer objectForKey:containerNumber];
    }

    if (![containerType isKindOfClass:[PajeContainerType class]]) {
        return nil;
    }

    return [containerType instanceWithId:containerNumber];
}


- (void)pajeStartTrace:(PajeEvent *)event
{
    Assign(startTime, [event objectForKey:@"StartTime"]);
    Assign(endTime, [event objectForKey:@"EndTime"]);
}

- (void)pajeDefineContainerType:(PajeEvent *)event
{
    NSString *newContainerTypeAlias;
    NSString *containerTypeId;
    NSString *newContainerTypeName;

    PajeContainerType *containerType;
    PajeContainerType *newContainerType;

    // get fields from event
    newContainerTypeName   = [event objectForKey:@"Name"];
    newContainerTypeAlias  = [event objectForKey:@"Alias"];
    containerTypeId        = [event objectForKey:@"ContainerType"];

    // get fields with old names
    if (newContainerTypeName == nil) {
        newContainerTypeName   = [event objectForKey:@"NewName"];
    }
    if (newContainerTypeAlias == nil) {
        newContainerTypeAlias  = [event objectForKey:@"NewType"];
    }

    // verify presence of obligatory fields
    if (newContainerTypeName == nil) {
        [self error:@"Missing \"Name\" field" inEvent:event];
    }
    if (containerTypeId == nil) {
        [self error:@"Missing \"ContainerType\" field" inEvent:event];
    }

    containerType = [userTypes objectForKey:containerTypeId];
    if (!containerType) {
        [self error:@"Unknown container type" inEvent:event];
    }

    // new type should not exist
    if ([userTypes objectForKey:newContainerTypeName] != nil) {
        NSWarnLog(@"Redefining container type %@ with event %@",
                  newContainerTypeName, event);
        return;
    }
    if (newContainerTypeAlias != nil 
        && [userTypes objectForKey:newContainerTypeAlias] != nil) {
        NSWarnLog(@"Redefining container type alias %@ with event %@",
                  newContainerTypeAlias, event);
        return;
    }

    // create the new container type
    newContainerType = [PajeContainerType typeWithName:newContainerTypeName
                                         containerType:containerType
                                                 event:event];
    [userTypes setObject:newContainerType forKey:newContainerTypeName];
    if (newContainerTypeAlias != nil) {
        [userTypes setObject:newContainerType forKey:newContainerTypeAlias];
    }
}

- (void)pajeDefineLinkType:(PajeEvent *)event
{
    NSNumber *newEntityTypeAlias;
    NSNumber *containerTypeId;
    NSNumber *sourceContainerTypeId;
    NSNumber *destContainerTypeId;
    NSString *newEntityTypeName;

    PajeContainerType *containerType;
    PajeContainerType *sourceContainerType;
    PajeContainerType *destContainerType;
    PajeEntityType *newEntityType;

    // get fields from event
    newEntityTypeName         = [event objectForKey:@"Name"];
    newEntityTypeAlias        = [event objectForKey:@"Alias"];
    containerTypeId           = [event objectForKey:@"ContainerType"];
    sourceContainerTypeId     = [event objectForKey:@"SourceContainerType"];
    destContainerTypeId       = [event objectForKey:@"DestContainerType"];

    // old field names
    if (newEntityTypeName == nil) {
        newEntityTypeName         = [event objectForKey:@"NewName"];
    }
    if (newEntityTypeAlias == nil) {
        newEntityTypeAlias        = [event objectForKey:@"NewType"];
    }

    containerType = [userTypes objectForKey:containerTypeId];
    if (containerType == nil) {
        [self error:@"Unknown container type" inEvent:event];
    }

    sourceContainerType = [userTypes objectForKey:sourceContainerTypeId];
    if (sourceContainerType == nil) {
        [self error:@"Unknown source container type" inEvent:event];
    }

    if (destContainerTypeId == nil) {
        destContainerTypeId       = [event objectForKey:@"DestinContainerType"];
    }
    destContainerType = [userTypes objectForKey:destContainerTypeId];
    if (destContainerType == nil) {
        [self error:@"Unknown dest container type" inEvent:event];
    }

    // new type should not exist
    if ([userTypes objectForKey:newEntityTypeName] != nil) {
        NSWarnLog(@"Redefining entity type %@ with event %@",
                  newEntityTypeName, event);
        return;
    }
    if (newEntityTypeAlias != nil 
        && [userTypes objectForKey:newEntityTypeAlias] != nil) {
        NSWarnLog(@"Redefining entity type alias %@ with event %@",
                  newEntityTypeAlias, event);
        return;
    }

    newEntityType = [PajeLinkType typeWithName:newEntityTypeName
                                 containerType:containerType
                           sourceContainerType:sourceContainerType
                             destContainerType:destContainerType
                                         event:event];
    [userTypes setObject:newEntityType forKey:newEntityTypeName];
    if (newEntityTypeAlias != nil) {
        [userTypes setObject:newEntityType forKey:newEntityTypeAlias];
    }
}

- (void)_defineUserEntityType:(PajeEvent *)event
                  drawingType:(PajeDrawingType)drawingType
{
    NSNumber *newEntityTypeAlias;
    NSNumber *containerTypeId;
    NSString *newEntityTypeName;

    PajeContainerType *containerType;
    PajeEntityType *newEntityType;

    // get fields from event
    newEntityTypeName   = [event objectForKey:@"Name"];
    newEntityTypeAlias  = [event objectForKey:@"Alias"];
    containerTypeId     = [event objectForKey:@"ContainerType"];

    // old field names
    if (newEntityTypeName == nil) {
        newEntityTypeName   = [event objectForKey:@"NewName"];
    }
    if (newEntityTypeAlias == nil) {
        newEntityTypeAlias  = [event objectForKey:@"NewType"];
    }

    // new type should not exist
    if ([userTypes objectForKey:newEntityTypeName] != nil) {
        NSWarnLog(@"Redefining entity type %@ with event %@",
                  newEntityTypeName, event);
        return;
    }
    if (newEntityTypeAlias != nil 
        && [userTypes objectForKey:newEntityTypeAlias] != nil) {
        NSWarnLog(@"Redefining entity type alias %@ with event %@",
                  newEntityTypeAlias, event);
        return;
    }

    containerType = [userTypes objectForKey:containerTypeId];
    if (!containerType) {
        [self error:@"Unknown container type" inEvent:event];
    }

    switch (drawingType) {
    case PajeEventDrawingType:
        newEntityType = [PajeEventType typeWithName:newEntityTypeName
                                      containerType:containerType
                                              event:event];
        break;
    case PajeStateDrawingType:
        newEntityType = [PajeStateType typeWithName:newEntityTypeName
                                      containerType:containerType
                                              event:event];
        break;
    case PajeVariableDrawingType:
        newEntityType = [PajeVariableType typeWithName:newEntityTypeName
                                         containerType:containerType
                                                 event:event];
        break;
    default:
        [self error:@"Internal simulator error: unknown drawing type"
            inEvent:event];
    }

    [userTypes setObject:newEntityType forKey:newEntityTypeName];
    if (newEntityTypeAlias != nil) {
        [userTypes setObject:newEntityType forKey:newEntityTypeAlias];
    }
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
    NSString *newEntityValueAlias;
    NSString *entityTypeId;
    NSString *newEntityValueName;
    NSColor *color;

    PajeEntityType *entityType;

    // get fields from event
    newEntityValueName   = [event objectForKey:@"Name"];
    newEntityValueAlias  = [event objectForKey:@"Alias"];
    entityTypeId         = [event objectForKey:@"EntityType"];
    color                = [event objectForKey:@"Color"];
    if (entityTypeId == nil) {
        entityTypeId  = [event objectForKey:@"Type"];
    }

    // old field names
    if (newEntityValueName == nil) {
        newEntityValueName   = [event objectForKey:@"NewName"];
    }
    if (newEntityValueAlias == nil) {
        newEntityValueAlias  = [event objectForKey:@"NewValue"];
    }

    entityType = [userTypes objectForKey:entityTypeId];
    if (!entityType) {
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
    NSString *newContainerAlias;
    NSString *newContainerTypeId;
    NSString *containerId;
    NSString *newContainerName;

    PajeContainerType *typeOfNewContainer;
    PajeContainer *container;
    PajeContainer *newContainer;

    // get fields from event
    newContainerName       = [event objectForKey:@"Name"];
    newContainerAlias      = [event objectForKey:@"Alias"]; // optional
    newContainerTypeId     = [event objectForKey:@"Type"];
    containerId            = [event objectForKey:@"Container"];
    
    // get fields with old names
    if (newContainerName == nil) {
        newContainerName       = [event objectForKey:@"NewName"];
    }
    if (newContainerAlias == nil) {
        newContainerAlias      = [event objectForKey:@"NewContainer"];
    }
    if (newContainerTypeId == nil) {
        newContainerTypeId     = [event objectForKey:@"NewContainerType"];
    }

    if (newContainerName == nil) {
        [self error:@"Missing \"Name\" field" inEvent:event];
    }
    if (newContainerTypeId == nil) {
        [self error:@"Missing \"Type\" field" inEvent:event];
    }
    if (containerId == nil) {
        [self error:@"Missing \"Container\" field" inEvent:event];
    }

    typeOfNewContainer = [userTypes objectForKey:newContainerTypeId];
    if (!typeOfNewContainer) {
        [self error:@"Unknown container type" inEvent:event];
    }
    
    if ([self containerOfNumber:newContainerName 
                           type:typeOfNewContainer
                        inEvent:event] != nil) {
        NSWarnLog(@"Redefining container %@ in event %@",
                  newContainerName, event);
        return;
    }

    if (newContainerAlias == nil) {
        newContainerAlias      = newContainerName;
    }
    if (newContainerAlias != nil 
        && [self containerOfNumber:newContainerAlias 
                              type:typeOfNewContainer
                           inEvent:event] != nil) {
        NSWarnLog(@"Redefining container alias %@ in event %@",
                  newContainerAlias, event);
        return;
    }

    container = [self containerOfNumber:containerId
                                   type:[typeOfNewContainer containerType]
                                inEvent:event];
    if (container == nil) {
        [self error:@"Unknown container" inEvent:event];
    }
    
    newContainer = [SimulContainer containerWithType:typeOfNewContainer
                                                name:newContainerName
                                               alias:newContainerAlias
                                           container:container
                                        creationTime:[event time]
                                           simulator:self];
    [container addSubContainer:newContainer];
    [typeOfNewContainer addInstance:newContainer];

//    [userNumberToContainer setObject:newContainer forKey:newContainerName];
//    if (newContainerAlias != nil) {
        [userNumberToContainer setObject:newContainer forKey:newContainerAlias];
//    }
}

- (void)pajeDestroyContainer:(PajeEvent *)event
{
    NSString *containerId;
    NSString *containerTypeId;
    PajeContainerType *containerType;

    SimulContainer *container;

    // get fields from event
    containerId         = [event objectForKey:@"Name"];
    containerTypeId     = [event objectForKey:@"Type"];
    
    if (containerId == nil) {
        containerId     = [event objectForKey:@"Container"];
    }

    containerType = [userTypes objectForKey:containerTypeId];
    if (containerType == nil) {
        NSWarnLog(@"Unknown container type in event %@", event);
        //[self error:@"Unknown container type" inEvent:event];
    }
 
    container = [self containerOfNumber:containerId
                                   type:containerType
                                inEvent:event];
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
    NSString *entityTypeId;
    NSString *containerId;

    if (entityType != NULL) {
        entityTypeId  = [event objectForKey:@"EntityType"];
	if (entityTypeId == nil) {
            entityTypeId  = [event objectForKey:@"Type"];
	}
        *entityType = [userTypes objectForKey:entityTypeId];
        if (!*entityType) {
            [self error:@"Unknown entity type" inEvent:event];
        }
    }

    if (entityType != NULL && container != NULL) {
        containerId   = [event objectForKey:@"Container"];
        *container = [self containerOfNumber:containerId
                                        type:[*entityType containerType]
                                     inEvent:event];
        if (*container == nil) {
            [self error:@"Unknown container" inEvent:event];
        }
    }

    if (entityValue) {
        id value;
        value = [event objectForKey:@"Value"];
        if (entityType != NULL 
            && [*entityType isKindOfClass:[PajeCategorizedEntityType class]]) {
            PajeCategorizedEntityType *type = *entityType;
            value = [type unaliasedValue:value];
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

- (void)pajeSetVariable:(PajeEvent *)event
{
    PajeVariableType *entityType;
    SimulContainer *container;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    [container setUserVariableOfType:entityType
                             toValue:entityValue
                           withEvent:event];
}
- (void)pajeAddVariable:(PajeEvent *)event
{
    PajeVariableType *entityType;
    SimulContainer *container;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    [container addUserVariableOfType:entityType
                               value:entityValue
                           withEvent:event];
}
- (void)pajeSubVariable:(PajeEvent *)event
{
    PajeVariableType *entityType;
    SimulContainer *container;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    [container subUserVariableOfType:entityType
                               value:entityValue
                           withEvent:event];
}


- (void)pajeStartLink:(PajeEvent *)event
{
    NSString *sourceContainerNumber;
    PajeLinkType *entityType;
    SimulContainer *container;
    PajeContainer *sourceContainer;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    sourceContainerNumber = [event objectForKey:@"SourceContainer"];
    sourceContainer = [self containerOfNumber:sourceContainerNumber
                                         type:[entityType sourceContainerType]
                                      inEvent:event];
    if (sourceContainer == nil) {
        [self error:@"Unknown source container" inEvent:event];
        return;
    }

    [container startUserLinkOfType:entityType
                             value:entityValue
                   sourceContainer:sourceContainer
                               key:[event objectForKey:@"Key"]
                         withEvent:event];
}

- (void)pajeEndLink:(PajeEvent *)event
{
    NSString *destContainerNumber;
    PajeLinkType *entityType;
    SimulContainer *container;
    PajeContainer *destContainer;
    id entityValue;

    [self _getEntityType:&entityType
                   value:&entityValue
               container:&container
               fromEvent:event];

    destContainerNumber = [event objectForKey:@"DestContainer"];
    destContainer = [self containerOfNumber:destContainerNumber
                                       type:[entityType destContainerType]
                                    inEvent:event];
    if (destContainer == nil) {
        [self error:@"Unknown destination container" inEvent:event];
        return;
    }

    [container endUserLinkOfType:entityType
                           value:entityValue
                   destContainer:destContainer
                             key:[event objectForKey:@"Key"]
                       withEvent:event];
}

@end
