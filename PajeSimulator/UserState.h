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
#ifndef _UserState_h_
#define _UserState_h_
//
// UserState
//
// holds a user-definable state
//

#include "UserEvent.h"
#include "../General/CondensedEntitiesArray.h"

@interface UserState : UserEvent
{
    PajeEvent *endEvent;
    int imbricationLevel;
    double innerDuration;
    CondensedEntitiesArray *innerStates;
    unsigned condensedEntitiesCount;
}

+ (UserState *)stateOfType:(PajeEntityType *)type
                     value:(id)v
                 container:(PajeContainer *)c
                startEvent:(PajeEvent *)e;
- (id)initWithType:(PajeEntityType *)type
             value:(id)v
         container:(PajeContainer *)c
        startEvent:(PajeEvent *)e;
- (void)dealloc;

- (void)setEndEvent:(PajeEvent *)event;

- (id)value;

- (NSDate *)endTime;

- (void)setImbricationLevel:(int)level;
- (int)imbricationLevel;

- (double)exclusiveDuration;
- (double)inclusiveDuration;

- (void)addInnerState:(UserState *)innerState;
- (CondensedEntitiesArray *)condensedEntities;
- (unsigned)condensedEntitiesCount;
- (unsigned)subCount;
- (NSString *)subNameAtIndex:(unsigned)i;
- (double)subDurationAtIndex:(unsigned)i;
- (NSColor *)subColorAtIndex:(unsigned)i;
@end

#endif
