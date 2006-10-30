#ifndef _AggregateLink_h_
#define _AggregateLink_h_

#include "AggregateEvent.h"

/** AggregateLink
 *  Aggregates many smaller links, between specific pair of org-dest containers.
 */
@interface AggregateLink : AggregateEvent
{
    PajeContainer *sourceContainer;  // not retained
    PajeContainer *destContainer;    // not retained
}

/** returns a newly created aggregate link made from the entities array.
 */
+ (PajeEntity *)entityWithEntities:(NSArray *)entities;
- (id)initWithEntities:(NSArray *)entities;

- (double)subDurationAtIndex:(unsigned)i;
@end

#endif
