#ifndef _AggregateEvent_h_
#define _AggregateEvent_h_

/* AggregateEvent
 * An event that aggregates other events
 */

#include "../General/PajeEntity.h"
#include "../General/PajeContainer.h"
#include "../General/CondensedEntitiesArray.h"

@interface AggregateEvent : PajeEntity
{
    CondensedEntitiesArray *condensedArray;
    unsigned condensedEntitiesCount;
    NSDate *startTime;
    NSDate *endTime;
}

+ (PajeEntity *)entityWithEntities:(NSArray *)entities;
- (id)initWithEntities:(NSArray *)entities;

- (BOOL)isAggregate;

- (NSDate *)startTime;
- (NSDate *)endTime;
- (double)exclusiveDuration;

- (unsigned)condensedEntitiesCount;

- (unsigned)subCount;
- (NSString *)subNameAtIndex:(unsigned)i;
- (NSColor *)subColorAtIndex:(unsigned)i;
- (unsigned)subCountAtIndex:(unsigned)i;
- (double)subDurationAtIndex:(unsigned)i;
- (CondensedEntitiesArray *)condensedEntities;

- (NSColor *)color;
@end

#endif
