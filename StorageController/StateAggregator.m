#include "StateAggregator.h"
#include "AggregateState.h"

#include "../General/Macros.h"

@implementation StateAggregator

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
    if (startTime == nil) {
        startTime = [entity startTime];
        imbricationLevel = [entity imbricationLevel];
        [entities addObject:entity];
        return YES;
    }

    // if adding the new entity would make this too wide, it cannot yet be
    // added -> must aggregate some and try again 
    newDuration = [[entity endTime] timeIntervalSinceDate:startTime];
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
            startTime = entityStartTime;
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
            startTime = entityStartTime;
        }
    }
    [entities addObject:entity];
    return YES;
}


- (PajeEntity *)aggregate
{
    PajeEntity *state;
    unsigned count;
    
    if (startTime == nil) {
        return nil;
    }
    count = [entities count];
    if (count == 1) {
        state = [entities objectAtIndex:0];
        if ([state subCount] > 0) {
            state = [AggregateState stateWithStates:entities];
        }
        [entities removeAllObjects];
        startTime = nil;
        return state;
    }

    int firstImbricationLevel;
    int lastIndex;
    
    firstImbricationLevel = [[entities objectAtIndex:0] imbricationLevel];
    if (firstImbricationLevel == imbricationLevel) {
        lastIndex = count - 1;
    } else {
        lastIndex = 0;
        while (lastIndex < count - 1) {
            state = [entities objectAtIndex:lastIndex + 1];
            if ([state imbricationLevel] != firstImbricationLevel) {
                break;
            }
            lastIndex++;
        }
    }
    if (lastIndex == count - 1) {
        state = [AggregateState stateWithStates:entities];
        [entities removeAllObjects];
        startTime = nil;
    } else {
        NSRange r = NSMakeRange(0, lastIndex + 1);
        startTime = [state startTime];
        state = [AggregateState stateWithStates:[entities subarrayWithRange:r]];
        [entities removeObjectsInRange:r];
    }
    return state;
}

- (id)copyWithZone:(NSZone *)z
{
    StateAggregator *new;
    new = [super copyWithZone:z];
    new->imbricationLevel = imbricationLevel;
    return new;
}
@end
