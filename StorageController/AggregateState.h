#ifndef _AggregateState_h_
#define _AggregateState_h_

#include "AggregateEvent.h"

/** AggregateState
 *  Aggregates many smaller states.
 *  Keeps condensed data of them, in cummulated duration of each state name.
 */
@interface AggregateState : AggregateEvent
{
    int imbricationLevel;
}

/** returns a newly created aggregate state made from the entities array.
 *  entities must contain entities ordered by decreasing time, and they
 *  cannot overlap. All must have the same imbricationLevel.
 */
+ (AggregateState *)stateWithStates:(NSArray *)entities;
- (id)initWithEntities:(NSArray *)entities;

- (double)subDurationAtIndex:(unsigned)i;

- (int)imbricationLevel;
@end

#endif
