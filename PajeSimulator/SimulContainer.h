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
#ifndef _SimulContainer_h_
#define _SimulContainer_h_

//
// PajeContainer
//
// superclass for containers
//

#include <Foundation/Foundation.h>
#include "../General/PajeContainer.h"
#include "../General/PajeEvent.h"
#include "SimulChunk.h"

@class PajeSimul;

@interface SimulContainer : PajeContainer
{
    NSDate *creationTime;
    NSDate *lastTime;
    PajeSimul *simulator;
    NSString *alias;
    NSMutableDictionary *userEntities; // key = entityType
    NSMutableDictionary *minValues; // key = entityType
    NSMutableDictionary *maxValues; // key = entityType
    NSDictionary *extraFields;
    int logicalTime;
    BOOL isActive;
}

+ (SimulContainer *)containerWithType:(PajeEntityType *)type
                                 name:(NSString *)n
                                alias:(NSString *)a
                           container:(PajeContainer *)newcontainer
                        creationTime:(NSDate *)time
                               event:(PajeEvent *)event
                           simulator:(id)simul;
- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
             alias:(NSString *)a
         container:(PajeContainer *)c
      creationTime:(NSDate *)time
             event:(PajeEvent *)event
         simulator:(id)simul;

- (NSString *)alias;

- (NSDate *)startTime;
- (NSDate *)endTime;

- (void)stopWithEvent:(PajeEvent*)event;

- (BOOL)isStopped;
- (BOOL)isActive;

- (void)setLastTime:(NSDate *)time;

- (SimulChunk *)chunkOfType:(id)type;
- (SimulChunk *)previousChunkOfType:(id)type;

- (void)newEventWithType:(id)type
                   value:(id)value
               withEvent:(PajeEvent *)event;
- (void)setUserStateOfType:(PajeEntityType *)entityType
                   toValue:(id)value
                 withEvent:(PajeEvent *)event;
- (void)pushUserStateOfType:(PajeEntityType *)entityType
                      value:(id)value
                  withEvent:(PajeEvent *)event;
- (void)popUserStateOfType:(PajeEntityType *)entityType
                 withEvent:(PajeEvent *)event;
- (void)resetUserStateOfType:(PajeEntityType *)entityType
                 withEvent:(PajeEvent *)event;

- (void)setUserVariableOfType:(PajeVariableType *)entityType
                toDoubleValue:(double)value
                    withEvent:(PajeEvent *)event;
- (void)addUserVariableOfType:(PajeVariableType *)entityType
                  doubleValue:(double)value
                    withEvent:(PajeEvent *)event;
- (void)subUserVariableOfType:(PajeVariableType *)entityType
                  doubleValue:(double)value
                    withEvent:(PajeEvent *)event;

- (void)startUserLinkOfType:(PajeEntityType *)entityType
                      value:(id)entityName
            sourceContainer:(PajeContainer *)sourceContainer
                        key:(id)key
                  withEvent:(PajeEvent *)event;
- (void)endUserLinkOfType:(PajeEntityType *)entityType
                    value:(id)entityName
            destContainer:(PajeContainer *)destContainer
                      key:(id)key
                withEvent:(PajeEvent*)event;

- (double)minValueForEntityType:(PajeEntityType *)entityType;
- (double)maxValueForEntityType:(PajeEntityType *)entityType;

- (int)logicalTime;
- (void)setLogicalTime:(int)lt;

- (void)startChunk;
- (void)endOfChunkLast:(BOOL)last;

- (void)emptyChunk:(int)chunkNumber;

- (void)reset;

- (id)chunkState;
- (void)setChunkState:(id)state;
@end

#endif
