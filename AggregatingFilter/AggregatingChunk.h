/*
    Copyright (c) 2006 Benhur Stein
    
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
#ifndef _AggregatingChunk_h_ 
#define _AggregatingChunk_h_ 

#include "../General/EntityChunk.h"
#include "EntityAggregator.h"
#include "../PajeSimulator/SimulChunk.h"

@interface AggregatingChunk : EntityChunk
{
    EntityAggregator *aggregator;
    NSDate *latestTime;
    PajeEntity *lastEntity;
    double aggregationDuration;
}

+ (AggregatingChunk *)chunkWithEntityType:(PajeEntityType *)type
                                container:(PajeContainer *)pc
                      aggregationDuration:(double)duration;
- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
     aggregationDuration:(double)duration;

- (PajeEntity *)firstIncomplete;

- (BOOL)hasBeenAggregated:(PajeEntity *)entity;
- (BOOL)canFinishBeforeEntity:(PajeEntity *)entity;
        
//- (NSDate *)lastTime;

- (void)setLatestTime:(NSDate *)time;
- (NSDate *)latestTime;
- (NSDate *)continuationTime;
@end
#endif
