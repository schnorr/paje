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
#ifndef _ReduceEntity_h_
#define _ReduceEntity_h_

//
// An entity that represents many others, reducing them.
// Subclasses can reduce by counting, summing, maxing, etc.
// Reduced entities are kept in an array that has also some global data.
// This entity only has a pointer to the array and an index to the correct entry.
//
// BS 2001.02.20 creation
//

#include "BusyArray.h"
#include "../General/PajeEntity.h"
#include "../General/PajeFilter.h"

@interface ReduceEntity : PajeEntity
{
    BusyArray *array;
    int index;
}

+ (ReduceEntity *)entityWithArray:(BusyArray *)a index:(int)i;

- (id)initWithArray:(BusyArray *)a index:(int)i;

- (PajeDrawingType)drawingType;
//- (ReduceEntityType *)entityType;

- (NSDate *)startTime;
- (NSDate *)endTime;
- (PajeContainer *)container;
- (NSString *)name;
- (id)value;
- (double)doubleValue;
//- (NSColor *)color;
- (NSArray *)relatedEntities;

+ (void)getMinValue:(double *)min
           maxValue:(double *)max
           forArray:(BusyArray *)a
      pajeComponent:(PajeFilter *)filter;

// to be implemented by subclasses
+ (NSString *)titleForPopUp;
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter;
@end

@interface CountReduceEntity : ReduceEntity
+ (NSString *)titleForPopUp;
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter;
@end
@interface SumReduceEntity : ReduceEntity
+ (NSString *)titleForPopUp;
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter;
@end
@interface AverageReduceEntity : ReduceEntity
+ (NSString *)titleForPopUp;
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter;
@end
@interface MaxReduceEntity : ReduceEntity
+ (NSString *)titleForPopUp;
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter;
@end
@interface MinReduceEntity : ReduceEntity
{double xval;}
+ (NSString *)titleForPopUp;
+ (double)valueForRelatedEntities:(NSArray *)entities
                    pajeComponent:(PajeFilter *)filter;
@end

#endif
