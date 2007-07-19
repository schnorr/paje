#ifndef _AggregateValue_h_
#define _AggregateValue_h_

/* AggregateValue
 * A value that aggregates other values
 */

#include "../PajeSimulator/UserValue.h"

@interface AggregateValue : PajeEntity
{
	// From UserValue
    double value;
    NSDate *startTime;
    NSDate *endTime;

    double minValue;
    double maxValue;
    int condensedEntitiesCount;
}

+ (PajeEntity *)entityWithEntities:(NSArray *)entities;
- (id)initWithEntities:(NSArray *)entities;

- (BOOL)isAggregate;

- (unsigned)condensedEntitiesCount;

- (NSColor *)color;
@end

#endif
