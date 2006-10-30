#include "AggregateValue.h"

#include "../General/Macros.h"

#include <math.h>

@implementation AggregateValue

+ (PajeEntity *)entityWithEntities:(NSArray *)entities
{
    return [[[self alloc] initWithEntities:entities] autorelease];
}

- (id)initWithEntities:(NSArray *)entities
{
    NSEnumerator *entityEnum;
    PajeEntity *entity;
    PajeEntity *lastEntity;
    NSDate *t1;
    NSDate *t2;
    double sum = 0;
    double min = HUGE_VAL;
    double max = -HUGE_VAL;
    int ct = 0;
    
    entityEnum = [entities objectEnumerator];
    entity = [entityEnum nextObject];

    NSParameterAssert(entity != nil);
    
    t1 = [entity startTime];
    do {
        double v;
        v = [entity minValue];
        if (v < min) min = v;
        v = [entity maxValue];
        if (v > max) max = v;
        v = [entity doubleValue];
        sum += v * [entity duration];
        lastEntity = entity;
        ct += [entity condensedEntitiesCount];
    } while ((entity = [entityEnum nextObject]) != nil);
    t2 = [lastEntity endTime];
    

    self = [super initWithType:[lastEntity entityType]
                   doubleValue:sum / [t2 timeIntervalSinceDate:t1]
                     container:[lastEntity container]
                     startTime:t1
                       endTime:t2];
    if (self != nil) {
        minValue = min;
        maxValue = max;
        condensedEntitiesCount = ct;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (double)maxValue
{
    return maxValue;
}

- (double)minValue
{
    return minValue;
}

- (BOOL)isAggregate
{
    return YES;
}

- (unsigned)condensedEntitiesCount
{
    return condensedEntitiesCount;
}

- (NSColor *)color
{
    return [NSColor whiteColor];
}

@end
