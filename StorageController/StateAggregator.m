#include "StateAggregator.h"
#include "AggregateState.h"

#include "../General/Macros.h"

@implementation StateAggregator
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

/* entity should be on the same imbricationLevel as the first.
   While simulator doesn't make condensed info, it should get bigger
   imbricationLevels as well */
- (BOOL)addEntity:(PajeEntity *)entity
{
    int entityImbricationLevel;
    double newDuration;

    if ([entity duration] > maxDuration) {
        return NO;
    }

    entityImbricationLevel = [entity imbricationLevel];
    if ([entities count] == 0) {
        endTime = [entity endTime];
        imbricationLevel = entityImbricationLevel;
        [entities addObject:entity];
        return YES;
    }

    if (entityImbricationLevel < imbricationLevel) {
        return NO;
    }
    if (entityImbricationLevel > imbricationLevel) {
        return YES;
    }

    newDuration = [endTime timeIntervalSinceDate:[entity startTime]];
    if (newDuration <= maxDuration) {
        [entities addObject:entity];
        return YES;
    } else {
        return NO;
    }
}

- (PajeEntity *)aggregate
{
    PajeEntity *state;
    unsigned count;
    
    count = [entities count];
    if (count == 0) {
        return nil;
    }
    if (count > 1) {
        state = [AggregateState stateWithStates:entities];
    } else {
        state = [entities objectAtIndex:0];
        if ([state subCount] > 0) {
            state = [AggregateState stateWithStates:entities];
        }
    }
    [entities removeAllObjects];
    return state;
}
@end
