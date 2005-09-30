#include "EventAggregator.h"
#include "AggregateEvent.h"

#include "../General/Macros.h"

@implementation EntityAggregator
+ (EntityAggregator *)aggregatorWithMaxDuration:(double)duration
{
    [self subclassResponsibility:_cmd];
    return nil;
}
- (id)initWithMaxDuration:(double)duration
{
    [self subclassResponsibility:_cmd];
    return nil;
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
@end



@implementation EventAggregator

+ (EntityAggregator *)aggregatorWithMaxDuration:(double)duration
{
    return [[[self alloc] initWithMaxDuration:duration] autorelease];
}

- (id)initWithMaxDuration:(double)duration
{
    self = [super init];
    if (self != nil) {
        entities = [[NSMutableArray alloc] init];
        maxDuration = duration;
    }
    return self;

}

- (void)dealloc
{
    Assign(entities, nil);
    [super dealloc];
}

- (BOOL)addEntity:(PajeEntity *)entity
{
    double newDuration;

    if ([entity duration] > maxDuration) {
        return NO;
    }

    if ([entities count] == 0) {
        endTime = [entity time];
        [entities addObject:entity];
        return YES;
    }

    newDuration = [endTime timeIntervalSinceDate:[entity time]];
    if (newDuration <= maxDuration) {
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
    return event;
}
@end
