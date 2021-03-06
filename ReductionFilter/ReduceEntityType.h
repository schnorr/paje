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
#ifndef _ReduceEntityType_h_
#define _ReduceEntityType_h_

#include "../General/PajeFilter.h"
#include "../General/PajeType.h"
#include "BusyArray.h"

@interface ReduceEntityType : PajeVariableType
{
    PajeFilter *component;
    Class entityClass;
    PajeEntityType *entityTypeToReduce;
    NSMutableSet *filterValues;       // entity values that are reduced
    BusyArray *array;
}

+ (ReduceEntityType *)typeWithName:(NSString *)n
                     containerType:(PajeContainerType *)cont
                         component:(PajeFilter *)comp;
+ (ReduceEntityType *)typeFromDictionary:(NSDictionary *)dict
                               component:(PajeFilter *)comp;
- (id)initWithName:(NSString *)n
     containerType:(PajeContainerType *)cont
         component:(PajeFilter *)comp;

- (NSDictionary *)dictionaryForDefaults;
- (PajeFilter *)component;

- (void)setDescription:(NSString *)n;

- (void)setContainerType:(PajeContainerType *)newContainerType;

- (void)setEntityClass:(Class)c;
- (Class)entityClass;

- (void)setEntityTypeToReduce:(PajeEntityType *)newEntityTypeToReduce;
- (PajeEntityType *)entityTypeToReduce;

- (void)addValueToFilter:(id)value;
- (void)addValuesToFilter:(NSArray *)values;
- (void)removeValueFromFilter:(id)value;
- (NSSet *)filterValues;

- (NSEnumerator *)enumeratorOfEntitiesInContainer:(PajeContainer *)container
                                         fromTime:(NSDate *)start
                                           toTime:(NSDate *)end
                                      minDuration:(double)minDuration;
- (NSEnumerator *)enumeratorOfCompleteEntitiesInContainer:(PajeContainer *)container
                                                 fromTime:(NSDate *)start
                                                   toTime:(NSDate *)end
                                              minDuration:(double)minDuration;
@end

#endif
