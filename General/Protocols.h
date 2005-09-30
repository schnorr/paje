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
#ifndef _Protocols_h_
#define _Protocols_h_

/* Protocols.h
 *
 * Defines the protocols used in the Paje environment. 
 *
 * 19970421 BS	creation
 */

#include "FoundationAdditions.h"

@class NSColor, NSNumber, NSArray, NSDate, PajeEntityType, PajeContainer;

// drawing types of entities
typedef enum {
    PajeEventDrawingType,    // when there is only one time and one container
    PajeStateDrawingType,    // when there are two times and one container
    PajeLinkDrawingType,     // when there are two times and two containers
    PajeVariableDrawingType, // when there is a value associated between 2 times 1 ctr
    PajeContainerDrawingType,
    PajeNonDrawingType,
} PajeDrawingType;

@protocol PajeTiming
// the time an entity starts, ends
- (NSDate *)startTime;
- (NSDate *)endTime;
// the only time of an entity (an event), or it's startTime
- (NSDate *)time;
// like startTime and endTime, but firstTime is always before lastTime
// (for cases in which clocks are not synchronized and a message arrives 
// before beeing sent).
- (NSDate *)firstTime;
- (NSDate *)lastTime;
- (double)duration;
@end

@protocol PajeEntity <PajeTiming, NSCoding>
- (NSString *)name;
- (PajeEntityType *)entityType;
- (NSArray *)relatedEntities;
- (NSColor *)color;
//- (id)node;
- (void)setColor:(NSColor *)color;

- (PajeDrawingType)drawingType;
//- (id)hierarchy;
- (PajeContainer *)container;
- (int)imbricationLevel;

- (NSArray *)fieldNames;
- (id)valueOfFieldNamed:(NSString *)fieldName;

// When the entity has subentities
- (BOOL)isAggregate;
- (unsigned)subCount;
- (NSColor *)subColorAtIndex:(unsigned)index;
- (NSString *)subNameAtIndex:(unsigned)index;
- (double)subDurationAtIndex:(unsigned)index;
- (unsigned)subCountAtIndex:(unsigned)index;
@end

@protocol PajeEntityType
- (NSArray *)allNames;
- (NSColor *)colorForName:(NSString *)name;
- (void)setColor:(NSColor*)c forName:(NSString *)name;
@end

@protocol PajeEvent <PajeEntity>
//- (id)thread;
@end

@protocol PajeState <PajeEvent>
@end

@protocol PajeComm <PajeState>
//- (id)sourceNode;
//- (id)destNode;
//- (id)sourceThread;
//- (id)destThread;
@end

@protocol PajeVariable <PajeEntity>
- (id)value;
@end

@protocol PajeLink <PajeComm>
- (PajeEntityType *)sourceEntityType;
- (PajeEntityType *)destEntityType;
- (PajeContainer *)sourceContainer;
- (PajeContainer *)destContainer;
@end

@protocol PajeComponent <NSObject>
- (void)setOutputComponent:(id<PajeComponent>)comp;
- (void)encodeCheckPointWithCoder:(NSCoder *)coder;
- (void)decodeCheckPointWithCoder:(NSCoder *)coder;
@end

@protocol PajeTool
- (NSString *)toolName;
- (void)activateTool:(id)sender;
@end

/*
@protocol PajeReader <PajeComponent>
- (BOOL)readNextEvent;
- (NSDictionary *)setInputFilename:(NSString *)filename;
- (NSString *)inputFilename;
- (NSDate *)currentTime;
- (id <PajeEvent>)readEvent;
@end
*/
/*
   Reader
   - (void)readEvent;
   - (void)readNextEvent;
   - (void)readUntilTime:(NSDate *)t
   - (void)decodeCheckPointWithCoder:(NSCoder *)c
   - (void)encodeCheckPointWithCoder:(NSCoder *)c
   - (void)setInputFileName:(NSString *)filename

   Trace
   - (void)removeObjectsBeforeTime:(NSDate *)t

 */

@protocol PajeReader
- (void)setInputFilename:(NSString *)filename;
- (NSString *)inputFilename;
- (void)readNextChunk;
- (BOOL)hasMoreData;
@end

@protocol PajeSimulator
- (int)eventCount;
- (NSDate *)currentTime;
@end

@protocol PajeStorageController
- (void)removeObjectsBeforeTime:(NSDate *)time;
- (void)removeObjectsAfterTime:(NSDate *)time;
@end



@protocol PajeInspector
+ (id <PajeInspector>)inspector;
- (void)inspect:(id)sender;
@end

#endif
