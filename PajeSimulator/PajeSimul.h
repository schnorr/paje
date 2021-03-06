/*
    Copyright (c) 1998--2005 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
#ifndef _PajeSimul_h_
#define _PajeSimul_h_

/*
 * PajeSimul.h
 *
 * Interface of simulator for Paje traces.
 *
 * 20021107 BS  creation (from A0bSimul)
 */

#include <Foundation/Foundation.h>

#include "../General/PajeFilter.h"
#include "../General/PajeEvent.h"

@class SimulContainer;

@interface PajeSimul : PajeComponent <PajeSimulator>
{
    SimulContainer *rootContainer;
    IMP invocationTable[PajeEventIdCount];

    /* PajeContainerType's and PajeEntityTypes's mapped by name and alias */
    NSMapTable *userTypes;

    /* PajeContainers mapped by name and alias (used only when containerType is
       not known, like in old PajeDestroyContainer events */
    //NSMutableDictionary *userNumberToContainer;

    NSDate *startTime;
    NSDate *endTime;
    NSDate *currentTime;

    int eventCount;
    
    /* arrays of entities related to a key */
    NSMutableDictionary *relatedEntities;

    NSMutableArray *chunkInfo;
    unsigned currentChunkNumber;

    BOOL replaying;
    BOOL lastChunkSeen;
}

- (id)initWithController:(PajeTraceController *)c;

- (PajeContainerType *)rootContainerType;
- (PajeContainer *)rootContainer;

- (void)error:(NSString *)format, ...;
- (void)error:(NSString *)str inEvent:(PajeEvent *)event;

- (void)inputEntity:(PajeEvent *)event;

- (NSDate *)startTime;
- (NSDate *)endTime;
- (NSDate *)currentTime;

- (PajeEntityType *)entityTypeWithName:(NSString *)name;
- (id)typeForId:(const char *)typeId;
- (void)setType:(id)type forId:(const char *)typeId;

- (int)eventCount;

- (void)endOfChunkLast:(BOOL)last;
- (void)outputChunk:(id)entity;

- (id)chunkState;
- (void)setChunkState:(id)state;
- (int)currentChunkNumber;

- (void)getChunksUntilTime:(NSDate *)time;

- (void)notifyMissingChunk:(int)chunkNumber;

- (BOOL)isReplaying;
@end

@interface PajeSimul (UserEvents)
//
// User defined entities
//

- (void)pajeStartTrace:(PajeEvent *)event;

- (void)pajeDefineContainerType:(PajeEvent *)event;
- (void)pajeDefineLinkType:(PajeEvent *)event;
- (void)pajeDefineEventType:(PajeEvent *)event;
- (void)pajeDefineStateType:(PajeEvent *)event;
- (void)pajeDefineVariableType:(PajeEvent *)event;

- (void)pajeDefineEntityValue:(PajeEvent *)event;

- (void)pajeCreateContainer:(PajeEvent *)event;
- (void)pajeDestroyContainer:(PajeEvent *)event;

- (void)pajeNewEvent:(PajeEvent *)event;

- (void)pajeSetState:(PajeEvent *)event;
- (void)pajePushState:(PajeEvent *)event;
- (void)pajePopState:(PajeEvent *)event;
- (void)pajeResetState:(PajeEvent *)event;

- (void)pajeSetVariable:(PajeEvent *)event;
- (void)pajeAddVariable:(PajeEvent *)event;
- (void)pajeSubVariable:(PajeEvent *)event;

- (void)pajeStartLink:(PajeEvent *)event;
- (void)pajeEndLink:(PajeEvent *)event;

- (id)containerForId:(const char *)containerId
                type:(PajeContainerType *)containerType;
@end

#endif
