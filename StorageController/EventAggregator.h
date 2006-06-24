#ifndef _EventAggregator_h_
#define _EventAggregator_h_

#include <Foundation/Foundation.h>
#include "../General/PajeEntity.h"

@interface EntityAggregator : NSObject <NSCopying>
{
    NSMutableArray *entities;
    NSDate *startTime;      // not retained
    double aggregationDuration;
}

+ (EntityAggregator *)aggregatorWithAggregationDuration:(double)duration;
+ (EntityAggregator *)aggregatorWithEntities:(NSArray *)array
                         aggregationDuration:(double)duration;
- (id)initWithAggregationDuration:(double)duration;
- (id)initWithEntities:(NSArray *)array
   aggregationDuration:(double)duration;

- (double)aggregationDuration;

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
- (PajeEntity *)aggregateBefore:(NSDate *)limit;

- (NSArray *)entities;
- (int)entityCount;
@end


@interface EventAggregator : EntityAggregator
{
}

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
@end

#endif
