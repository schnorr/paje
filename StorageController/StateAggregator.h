#ifndef _StateAggregator_h_
#define _StateAggregator_h_

#include "EventAggregator.h"

@interface StateAggregator : EntityAggregator <NSCopying>
{
    int imbricationLevel;
}

- (BOOL)addEntity:(PajeEntity *)entity;
- (PajeEntity *)aggregate;
@end

#endif
