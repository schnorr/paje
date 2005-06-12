/*
    Copyright (c) 1998--2005 Benhur Stein
    
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

@interface PajeSimul : PajeComponent <PajeSimulator>
{
    NSString *name;
    PajeContainer *rootContainer;
    NSMutableDictionary *invocationTable;

    /* PajeContainerType's and PajeEntityTypes's mapped by name and alias */
    NSMutableDictionary *userTypes;

    /* PajeContainers mapped by name and alias (used only when containerType is
       not known, like in old PajeDestroyContainer events */
    NSMutableDictionary *userNumberToContainer;

    NSDate *startTime;
    NSDate *endTime;
    NSDate *currentTime;

    int eventCount;
    
    /* arrays of entities related to a key */
    NSMutableDictionary *relatedEntities;
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

- (int)eventCount;

- (void)encodeCheckPointWithCoder:(NSCoder *)coder;
- (void)decodeCheckPointWithCoder:(NSCoder *)coder;
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

- (void)pajeSetVariable:(PajeEvent *)event;
- (void)pajeAddVariable:(PajeEvent *)event;
- (void)pajeSubVariable:(PajeEvent *)event;

- (void)pajeStartLink:(PajeEvent *)event;
- (void)pajeEndLink:(PajeEvent *)event;
@end

#endif
