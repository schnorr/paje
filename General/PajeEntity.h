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
#ifndef _PajeEntity_h_
#define _PajeEntity_h_

//
// PajeEntity
//
// Generic entities for Paje
//

#include "PajeType.h"

@class PajeContainer;

@interface PajeEntity : NSObject <PajeEntity>
{
    PajeEntityType *entityType;    // not retained
    NSString *name;
    PajeContainer *container;      // not retained
}

- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
         container:(PajeContainer *)c;

- (void)dealloc;

- (BOOL)isContainer;

- (NSString *)name;
- (PajeEntityType *)entityType;
- (void)setContainer:(PajeContainer *)c;
- (PajeContainer *)container;
- (BOOL)isContainedBy:(PajeContainer *)cont;

- (NSString *)description;

- (NSDate *)time;
- (NSDate *)startTime;
- (NSDate *)endTime;
- (NSDate *)firstTime;
- (NSDate *)lastTime;
- (NSNumber *)duration;

- (NSColor *)color;
- (void)setColor:(NSColor *)c;
- (void)takeColorFrom:(id)sender;

// for when there is one state inside another.
// only states can have this; others should return 0.
- (int)imbricationLevel;

- (NSArray *)fieldNames;
- (id)valueOfFieldNamed:(NSString *)fieldName;
@end

#endif
