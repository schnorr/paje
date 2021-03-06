/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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
#ifndef _BusyArray_h_
#define _BusyArray_h_

// BusyState
//
// Has a state of a node
// (start and end time, and active states in this time slice).

// 19980302 BS  creation

#include <Foundation/Foundation.h>
#include "../General/Protocols.h"

#include "../A0bSimul.bproj/A0State.h"

extern NSString *BusyStateEntityType;

@interface BusyState : /*NSObject <PajeState>*/A0State
{
    NSDate *startTime;
    NSDate *endTime;
    id container;
//    NSArray *relatedEntities;
}

+ (BusyState *)stateWithStartTime:(NSDate *)start
                          endTime:(NSDate *)end
                        container:(PajeContainer *)cont
                  relatedEntities:(NSArray *)related;
- (id)initWithStartTime:(NSDate *)start
                endTime:(NSDate *)end
              container:(PajeContainer *)cont
        relatedEntities:(NSArray *)related;
- (void)dealloc;

+ (PajeDrawingType)drawingType;
+ (NSString *)entityType;

- (PajeDrawingType)drawingType;
- (NSString *)entityType;

- (NSNumber *)value;

- (NSDate *)startTime;
- (NSDate *)endTime;
- (id)container;
- (NSString *)name;
- (NSColor *)color;
- (NSArray *)relatedEntities;
- (void)inspect;
@end

#endif
