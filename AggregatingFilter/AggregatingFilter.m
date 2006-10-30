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
  /*
   * AggregatingFilter.m
   *
   * Component that aggregates individual entities that are too small to 
   * display into AggregatedEntities.
   *
   * 19970423 BS  creation
   */

#include "AggregatingFilter.h"
#include "../General/MultiEnumerator.h"
#include "../General/PajeEntity.h"
#include "../General/Macros.h"
#include "../General/NSDate+Additions.h"

#include "AggregatingChunkArray.h"

#include <math.h>
double log2(double);
double pow(double, double);
#define DURtoSLOT(dur)  (log2(dur) + 15)
#define SLOTtoDUR(slot) pow(2.0, (slot) - 15.0)

@implementation AggregatingFilter

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self != nil) {
        entityLists = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [entityLists release];

    [super dealloc];
}


- (NSString *)filterName
{
    return @"AggregatingFilter";
}

- (NSDictionary *)configuration
{
    return nil;
}

- (void)setConfiguration:(NSDictionary *)config
{
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    [entityLists removeObjectForKey:entityType];
    [super dataChangedForEntityType:entityType];
}

- (ChunkArray *)chunkArrayForEntityType:(PajeEntityType *)entityType
                              container:(PajeContainer *)container
                            minDuration:(double)minDuration
{
    NSMutableDictionary *dict;
    dict = [entityLists objectForKey:entityType];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
        [entityLists setObject:dict forKey:entityType];
    }
    
    NSMutableArray *array;
    array = [dict objectForKey:container];
    if (array == nil) {
        array = [NSMutableArray array];
        [dict setObject:array forKey:container];
    }

    ChunkArray *chunks;
    int index = DURtoSLOT(minDuration);
    while (index >= [array count]) {
        chunks = [AggregatingChunkArray
                       arrayWithEntityType:entityType
                                 container:container
                                dataSource:self
                       aggregatingDuration:SLOTtoDUR([array count])];
        [array addObject:chunks];
    }
    chunks = [array objectAtIndex:index];
    return chunks;
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)entityType
                                inContainer:(PajeContainer *)container
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
                                minDuration:(double)minDuration
{
    // if container does not contain entityType's directly,
    // try containers in-between.
    // FIXME: shouldn't this be in PajeFilter?
    if (![[self containerTypeForType:entityType]
                isEqual:[self entityTypeForEntity:container]]) {
        NSEnumerator *subcontainerEnum;
        id subcontainer;
        MultiEnumerator *multiEnum;
        PajeEntityType *parentType;

        parentType = [entityType containerType];
        subcontainerEnum = [self enumeratorOfContainersTyped:parentType
                                                 inContainer:container];
        multiEnum = [MultiEnumerator enumerator];
        while ((subcontainer = [subcontainerEnum nextObject]) != nil) {
            NSEnumerator *en;
            en = [self enumeratorOfEntitiesTyped:entityType
                                    inContainer:subcontainer
                                       fromTime:start
                                         toTime:end
                                    minDuration:minDuration];
            if (en != nil) {
                [multiEnum addEnumerator:en];
            }
        }
        return multiEnum;
    }

    PajeDrawingType drawingType;
    drawingType = [self drawingTypeForEntityType:entityType];
    if ((   drawingType != PajeStateDrawingType
         && drawingType != PajeEventDrawingType
         && drawingType != PajeVariableDrawingType
         && drawingType != PajeLinkDrawingType)
        || DURtoSLOT(minDuration) < 0) {
        return [super enumeratorOfEntitiesTyped:entityType
                                    inContainer:container
                                       fromTime:start
                                         toTime:end
                                    minDuration:minDuration];
    }

    ChunkArray *chunks;
    chunks = [self chunkArrayForEntityType:entityType
                                 container:container
                               minDuration:minDuration];
    if (chunks != nil) {
        return [chunks enumeratorOfEntitiesFromTime:start toTime:end];
    }

    return nil;    
}


- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)entityType
                                        inContainer:(PajeContainer *)container
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
                                        minDuration:(double)minDuration
{
    // if container does not contain entityType's directly,
    // try containers in-between.
    // FIXME: shouldn't this be in PajeFilter?
    if (![[self containerTypeForType:entityType]
                isEqual:[self entityTypeForEntity:container]]) {
        NSEnumerator *subcontainerEnum;
        id subcontainer;
        MultiEnumerator *multiEnum;
        PajeEntityType *parentType;

        parentType = [entityType containerType];
        subcontainerEnum = [self enumeratorOfContainersTyped:parentType
                                                 inContainer:container];
        multiEnum = [MultiEnumerator enumerator];
        while ((subcontainer = [subcontainerEnum nextObject]) != nil) {
            NSEnumerator *en;
            en = [self enumeratorOfCompleteEntitiesTyped:entityType
                                             inContainer:subcontainer
                                                fromTime:start
                                                  toTime:end
                                             minDuration:minDuration];
            if (en != nil) {
                [multiEnum addEnumerator:en];
            }
        }
        return multiEnum;
    }

    PajeDrawingType drawingType;
    drawingType = [self drawingTypeForEntityType:entityType];
    if ((   drawingType != PajeStateDrawingType
         && drawingType != PajeEventDrawingType
         && drawingType != PajeVariableDrawingType
         && drawingType != PajeLinkDrawingType)
        || DURtoSLOT(minDuration) < 0) {
        return [super enumeratorOfCompleteEntitiesTyped:entityType
                                            inContainer:container
                                               fromTime:start
                                                 toTime:end
                                            minDuration:minDuration];
    }

    ChunkArray *chunks;

    chunks = [self chunkArrayForEntityType:entityType
                                 container:container
                               minDuration:minDuration];
    if (chunks != nil) {
        return [chunks enumeratorOfCompleteEntitiesFromTime:start toTime:end];
    }

    return nil;
}


- (NSEnumerator *)enumeratorOfContainersTyped:(PajeEntityType *)entityType
                                  inContainer:(PajeContainer *)container
{
    NSEnumerator *ienum;
    PajeContainer *instance;
    NSMutableArray *instancesInContainer = [NSMutableArray array];

    if ([entityType isContainer]) {
        PajeContainerType *containerType = (PajeContainerType *)entityType;
        ienum = [[containerType allInstances] objectEnumerator];
        while ((instance = [ienum nextObject]) != nil) {
            if ([instance isContainedBy:container]) {
                [instancesInContainer addObject:instance];
            }
        }
    }
    //[instancesInContainer sortUsingSelector:@selector(compare:)];
    return [instancesInContainer objectEnumerator];
}

@end
