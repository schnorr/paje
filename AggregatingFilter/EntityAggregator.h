#ifndef _EntityAggregator_h_
#define _EntityAggregator_h_

#include <Foundation/Foundation.h>
#include "../General/PajeEntity.h"

@interface EntityAggregator : NSObject <NSCopying>
{
    NSMutableArray *entities;
    NSDate *earliestStartTime;      // not retained
    double aggregationDuration;
    Class aggregatedEntityClass;
}

+ (EntityAggregator *)aggregatorForEntityType:(PajeEntityType *)entityType
                          aggregationDuration:(double)duration;
- (id)initWithAggregationDuration:(double)duration;

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregateEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
- (PajeEntity *)aggregateBefore:(NSDate *)limit;

- (int)entityCount;

- (double)aggregationDuration;
@end
#endif
