#include "EventAggregator.h"
#include "AggregateEvent.h"

#include "../General/Macros.h"

@implementation EntityAggregator
+ (EntityAggregator *)aggregatorWithAggregationDuration:(double)duration
{
    return [[[self alloc] initWithAggregationDuration:duration] autorelease];
}

+ (EntityAggregator *)aggregatorWithEntities:(NSArray *)array
                         aggregationDuration:(double)duration
{
    return [[[self alloc] initWithEntities:array
                       aggregationDuration:duration] autorelease];
}

- (id)initWithAggregationDuration:(double)duration
{
    self = [super init];
    if (self != nil) {
        entities = [[NSMutableArray alloc] init];
        aggregationDuration = duration;
    }
    return self;

}

- (id)initWithEntities:(NSArray *)array
   aggregationDuration:(double)duration
{
    self = [super init];
    if (self != nil) {
        entities = [array mutableCopy];
        aggregationDuration = duration;
    }
    return self;

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
    [self subclassResponsibility:_cmd];
    return NO;
}

- (PajeEntity *)aggregate
{
    [self subclassResponsibility:_cmd];
    return nil;
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
    new->startTime = startTime;
    new->aggregationDuration = aggregationDuration;
    return new;
}

@end



@implementation EventAggregator

- (BOOL)addEntity:(PajeEntity *)entity
{
    double newDuration;

    if ([entity duration] > aggregationDuration) {
        return NO;
    }

    if ([entities count] == 0) {
        startTime = [entity time];
        [entities addObject:entity];
        return YES;
    }

    newDuration = [[entity time] timeIntervalSinceDate:startTime];
    if (newDuration <= aggregationDuration) {
        [entities addObject:entity];
        return YES;
    } else {
        return NO;
    }
}

- (PajeEntity *)aggregate
{
    PajeEntity *event;
    unsigned count;
    
    count = [entities count];
    if (count == 0) {
        return nil;
    }
    if (count > 1) {
        event = [AggregateEvent eventWithEvents:entities];
    } else {
        event = [entities objectAtIndex:0];
    }
    [entities removeAllObjects];
    startTime = nil;
    return event;
}
@end
