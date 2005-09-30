#ifndef _EventAggregator_h_
#define _EventAggregator_h_

#include <Foundation/Foundation.h>
#include "../General/PajeEntity.h"

@interface EntityAggregator : NSObject
{
    NSMutableArray *entities;
    NSDate *endTime;
    double maxDuration;
}

+ (EntityAggregator *)aggregatorWithMaxDuration:(double)duration;
- (id)initWithMaxDuration:(double)duration;

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
@end


@interface EventAggregator : EntityAggregator
{
}

+ (EntityAggregator *)aggregatorWithMaxDuration:(double)duration;
- (id)initWithMaxDuration:(double)duration;

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
@end

#endif
