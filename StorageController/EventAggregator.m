#include "EventAggregator.h"
#include "AggregateEvent.h"

#include "../General/Macros.h"

@implementation EntityAggregator
+ (EntityAggregator *)aggregatorForEntityType:(PajeEntityType *)entityType
                          aggregationDuration:(double)duration;
{
    Class subclass;
    switch ([entityType drawingType]) {
    case PajeEventDrawingType:
        subclass = [EventAggregator class];
        break;
    case PajeStateDrawingType:
        subclass = [StateAggregator class];
        break;
    case PajeVariableDrawingType:
        subclass = [ValueAggregator class];
        break;
    case PajeLinkDrawingType:
        subclass = [LinkAggregator class];
        break;
    default:
        NSWarnMLog(@"No support for creating aggregator of type %@", type);
        class = Nil;
    }

    return [[[subclass alloc] initWithAggregationDuration:duration] autorelease];
}

- (id)initWithAggregationDuration:(double)duration
{
    self = [super init];
    if (self != nil) {
        entities = [[NSMutableArray alloc] init];
        aggregationDuration = duration;
        aggregatedEntityClass = [[self class] aggregatedEntityClass];
    }
    return self;

}

+ (Class)aggregatedEntityClass
{
    [self _subclassResponsibility:_cmd];
    return Nil;
}

- (double)aggregationDuration
{
    return aggregationDuration;
}

- (void)dealloc
{
    Assign(entities, nil);
    [super dealloc];
}

- (BOOL)addEntity:(PajeEntity *)entity
{
    double newDuration;

    // cannot aggregate a too wide entity
    if ([entity duration] > aggregationDuration) {
        return NO;
    }

    // if there are no other entities, just add the new one
    if (earliestStartTime == nil) {
        earliestStartTime = [entity startTime];
        [entities addObject:entity];
        return YES;
    }

    // if adding the new entity would make this too wide, it cannot yet be
    // added -> must aggregate some and try again 
    newDuration = [[entity endTime] timeIntervalSinceDate:earliestStartTime];
    if (newDuration > aggregationDuration) {
        return NO;
    }

    [entities addObject:entity];
    return YES;
}


- (PajeEntity *)aggregate
{
    PajeEntity *entity;
    unsigned count;
    
    if (earliestStartTime == nil) {
        return nil;
    }

    count = [entities count];
    NSAssert(count != 0, NSInternalInconsistencyException);
    if (count > 1) {
        entity = [aggregatedEntityClass entityWithEntities:entities];
    } else {
        // FIXME: is this garanteed to be retained elsewhere?
        entity = [entities objectAtIndex:0];
    }
    [entities removeAllObjects];
    earliestStartTime = nil;
    return entity;
}


- (PajeEntity *)aggregateBefore:(NSDate *)limit
{
    if (earliestStartTime == nil) {
        return nil;
    }
    if ([limit timeIntervalSinceDate:earliestStartTime] < aggregationDuration) {
        return nil;
    }

    return [self aggregate];
}

- (NSArray *)entities
{
    return entities;
}

- (int)entityCount
{
    return [entities count];
}

- (id)copyWithZone:(NSZone *)z
{
    EntityAggregator *new;
    new = [[[self class] allocWithZone:z] init];
    new->entities = [entities mutableCopyWithZone:z];
    new->earliestStartTime = earliestStartTime;
    new->aggregationDuration = aggregationDuration;
    return new;
}

@end


#include "AggregateEvent.h"

@implementation EventAggregator
+ (Class)aggregatedEntityClass
{
    return [AggregateEvent class];
}
@end

#include "AggregateValue.h"

@implementation VariableAggregator
+ (Class)aggregatedEntityClass
{
    return [AggregateValue class];
}
@end

#include <math.h>
#include "AggregateLink.h"

@implementation LinkAggregator

+ (Class)aggregatedEntityClass
{
    return [AggregateLink class];
}

- (BOOL)addEntity:(PajeEntity *)entity
{
    double newDuration;
    NSDate *entityStartTime;
    NSDate *entityEndTime;

    entityStartTime = [entity startTime];
    entityEndTime = [entity endTime];

    // if there are no other entities, just add the new one
    if (earliestStartTime == nil) {
        latestStartTime = earliestStartTime = entityStartTime;
        earliestEndTime = entityEndTime;
        [entities addObject:entity];
        return YES;
    }

    // cannot aggregate if endTimes would span more than aggregationDuration
    newDuration = [entityEndTime timeIntervalSinceDate:earliestEndTime];
    if (newDuration > aggregationDuration) {
        return NO;
    }
    // cannot aggregate if startTimes would span more than aggregationDuration
    // entities are ordered by endTime, so startTime can come in any order
    newDuration = [entityStartTime timeIntervalSinceDate:earliestStartTime];
    if (fabs(newDuration) > aggregationDuration) {
        return NO;
    }
    newDuration = [entityStartTime timeIntervalSinceDate:latestStartTime];
    if (fabs(newDuration) > aggregationDuration) {
        return NO;
    }
    
    earliestStartTime = [earliestStartTime earlierDate:entityStartTime];
    latestStartTime = [latestStartTime laterDate:entityStartTime];

    [entities addObject:entity];
    return YES;
}


- (PajeEntity *)aggregateBefore:(NSDate *)limit
{
    if (earliestStartTime == nil) {
        return nil;
    }
    if ([limit timeIntervalSinceDate:earliestEndTime] < aggregationDuration) {
        return nil;
    }

    return [self aggregate];
}

- (id)copyWithZone:(NSZone *)z
{
    LinkAggregator *new;
    new = [self copyWithZone:z];
    new->latestStartTime = latestStartTime;
    new->earliestEndTime = earliestEndTime;
    return new;
}
@end
