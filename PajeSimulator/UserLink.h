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
#ifndef _UserLink_h_
#define _UserLink_h_
//
// UserEvent
//
// holds a user-definable link
//

#include "UserState.h"

@interface UserLink : UserState
{
    id key;
    PajeContainer *sourceContainer;
    PajeContainer *destContainer;
    int startLogicalTime;
    int endLogicalTime;
}

+ (UserLink *)linkOfType:(PajeEntityType *)type
                   value:(id)v
                     key:(id)k
               container:(PajeContainer *)c
         sourceContainer:(PajeContainer *)sc
             sourceEvent:(PajeEvent *)e;
+ (UserLink *)linkOfType:(PajeEntityType *)type
                   value:(id)v
                     key:(id)k
               container:(PajeContainer *)c
           destContainer:(PajeContainer *)dc
               destEvent:(PajeEvent *)e;
- (id)initWithType:(PajeEntityType *)type
             value:(id)v
               key:(id)k
         container:(PajeContainer *)c
   sourceContainer:(PajeContainer *)sc
       sourceEvent:(PajeEvent *)e;
- (id)initWithType:(PajeEntityType *)type
             value:(id)v
               key:(id)k
         container:(PajeContainer *)c
     destContainer:(PajeContainer *)dc
         destEvent:(PajeEvent *)e;
- (void)dealloc;

- (void)setSourceContainer:(PajeContainer *)sc
               sourceEvent:(PajeEvent *)e;
- (void)setDestContainer:(PajeContainer *)dc
               destEvent:(PajeEvent *)e;

- (BOOL)canBeEndedWithValue:(id)v key:(id)k;
- (BOOL)canBeStartedWithValue:(id)v key:(id)k;

- (PajeContainer *)sourceContainer;
- (PajeContainer *)destContainer;

- (void)setStartLogicalTime:(int)t;
- (void)setEndLogicalTime:(int)t;
- (int)startLogicalTime;
- (int)endLogicalTime;
@end

@interface UserLinkInspector : UserStateInspector
@end

#endif
