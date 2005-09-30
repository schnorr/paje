#ifndef _StateAggregator_h_
#define _StateAggregator_h_

#include "EventAggregator.h"

@interface StateAggregator : EntityAggregator
{
    int imbricationLevel;
}

+ (EntityAggregator *)aggregatorWithMaxDuration:(double)duration;
- (id)initWithMaxDuration:(double)duration;

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
@end

#endif
