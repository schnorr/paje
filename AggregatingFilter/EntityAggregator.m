#include "EntityAggregator.h"
#include "../General/Macros.h"



@interface EventAggregator : EntityAggregator
@end

@interface StateAggregator : EntityAggregator <NSCopying>
{
    int imbricationLevel;
}

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
@end

@interface VariableAggregator : EntityAggregator
@end

@interface LinkAggregator : EntityAggregator <NSCopying>
{
    NSDate *earliestEndTime;    // not retained
    NSDate *latestStartTime;    // not retained
}

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregateBefore:(NSDate *)limit;
@end


#include "AggregateEvent.h"

@implementation EventAggregator
+ (Class)aggregatedEntityClass
{
    return [AggregateEvent class];
}
@end

#include "AggregateState.h"

@implementation StateAggregator

+ (Class)aggregatedEntityClass
{
    return [AggregateState class];
}

/* Try to aggregate one more state.
   Returns YES if state can be aggregated, NO if it cannot.
   States must be entered in endTime order.
*/
- (BOOL)addEntity:(PajeEntity *)entity
{
    int entityImbricationLevel;
    double newDuration;

    // cannot aggregate a too wide entity
    if ([entity duration] > aggregationDuration) {
        return NO;
    }

    // if there are no other entities, just add the new one
    if (earliestStartTime == nil) {
        earliestStartTime = [entity startTime];
        imbricationLevel = [entity imbricationLevel];
        [entities addObject:entity];
        return YES;
    }

    // if adding the new entity would make this too wide, it cannot yet be
    // added -> must aggregate some and try again 
    newDuration = [[entity endTime] timeIntervalSinceDate:earliestStartTime];
    if (newDuration > aggregationDuration) {
        return NO;
    }

    entityImbricationLevel = [entity imbricationLevel];

    if (entityImbricationLevel < imbricationLevel) {
        NSDate *entityStartTime = [entity startTime];
        PajeEntity *lastObject;
        // remove states that are inside new one (may happen when refilling)
        while ((lastObject = [entities lastObject]) != nil) {
            int lastImbricationLevel = [lastObject imbricationLevel];
            NSDate *lastStartTime = [lastObject startTime];
            if (lastImbricationLevel > entityImbricationLevel
                || (lastImbricationLevel == entityImbricationLevel 
                    && ![lastStartTime isEarlierThanDate:entityStartTime])) {
                [entities removeLastObject];
            } else {
                break;
            }
        }
        if ([entities count] == 0) {
            // new state will be first
            earliestStartTime = entityStartTime;
        }
        imbricationLevel = entityImbricationLevel;
        [entities addObject:entity];
        return YES;
    }

    if (entityImbricationLevel > imbricationLevel) {
        imbricationLevel = entityImbricationLevel;
        [entities addObject:entity];
        return YES;
    }

    // same imbrication level
    if ([entity isAggregate]) {
        // special case: reaggregating already aggregated state
        // (when refilling emptied chunk)
        NSDate *entityStartTime = [entity startTime];
        PajeEntity *lastObject;
        while ((lastObject = [entities lastObject]) != nil
               && ![[lastObject startTime] isEarlierThanDate:entityStartTime]) {
            [entities removeLastObject];
        }
        if ([entities count] == 0) {
            // new state will be first
            earliestStartTime = entityStartTime;
        }
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
    if (count == 1) {
        entity = [entities objectAtIndex:0];
        if ([entity subCount] > 0) {
            entity = [AggregateState entityWithEntities:entities];
        }
        [entities removeAllObjects];
        earliestStartTime = nil;
        return entity;
    }

    int firstImbricationLevel;
    int lastIndex;
    
    firstImbricationLevel = [[entities objectAtIndex:0] imbricationLevel];
    if (firstImbricationLevel == imbricationLevel) {
        lastIndex = count - 1;
    } else {
        lastIndex = 0;
        while (lastIndex < count - 1) {
            entity = [entities objectAtIndex:lastIndex + 1];
            if ([entity imbricationLevel] != firstImbricationLevel) {
                break;
            }
            lastIndex++;
        }
    }
    if (lastIndex == count - 1) {
        entity = [AggregateState entityWithEntities:entities];
        [entities removeAllObjects];
        earliestStartTime = nil;
    } else {
        NSRange r = NSMakeRange(0, lastIndex + 1);
        earliestStartTime = [entity startTime];
        entity = [AggregateState entityWithEntities:[entities subarrayWithRange:r]];
        [entities removeObjectsInRange:r];
    }
    return entity;
}

- (id)copyWithZone:(NSZone *)z
{
    StateAggregator *new;
    new = [super copyWithZone:z];
    new->imbricationLevel = imbricationLevel;
    return new;
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
        subclass = [VariableAggregator class];
        break;
    case PajeLinkDrawingType:
        subclass = [LinkAggregator class];
        break;
    default:
        NSWarnMLog(@"No support for creating aggregator of type %@", entityType);
        subclass = Nil;
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

