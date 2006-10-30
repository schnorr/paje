/*
    Copyright (c) 2006 Benhur Stein
    
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
#ifndef _AggregatingChunkArray_h_
#define _AggregatingChunkArray_h_

//
// AggregatingChunkArray
//
// contains an array of chunks, containing entities of a container.
// Those states are aggregated into one when many are within a certain 
// time interval. 
//
// Author: Benhur Stein
//


#include "ChunkArray.h"
#include "PajeFilter.h"
#include "EntityAggregator.h"

@interface AggregatingChunkArray : ChunkArray
{
    PajeEntityType *entityType;
    PajeContainer *container;
    PajeFilter *dataSource;
    EntityAggregator *aggregator;
    PajeEntity *lastEntity;
    NSDate *lastTime;
    BOOL finished;
}

+ (id)arrayWithEntityType:(PajeEntityType *)eType
                container:(PajeContainer *)c
               dataSource:(PajeFilter *)source
      aggregatingDuration:(double)duration;

- (id)initWithEntityType:(PajeEntityType *)eType
               container:(PajeContainer *)c
              dataSource:(PajeFilter *)source
     aggregatingDuration:(double)duration;

// returns YES if all entities of this container/type have been aggregated once.
- (BOOL)aggregationFinished;

- (NSEnumerator *)originalEnumeratorFromTime:(NSDate *)t1
                                      toTime:(NSDate *)t2
                                 minDuration:(double)duration;
- (NSEnumerator *)originalCompleteEnumeratorFromTime:(NSDate *)t1
                                              toTime:(NSDate *)t2
                                         minDuration:(double)duration;

// to be implemented by subclasses
- (void)aggregateEntitiesUntilTime:(NSDate *)time;
- (void)refillChunkAtIndex:(int)chunkIndex;
@end
#endif
