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
                          name:@""
                     container:[lastEntity container]];

    if (self != nil) {
        Assign(startTime, t1);
        Assign(endTime, t2);
        value = sum / [t2 timeIntervalSinceDate:t1];
        minValue = min;
        maxValue = max;
        condensedEntitiesCount = ct;
    }
    return self;
}

- (void)dealloc
{
    Assign(startTime, nil);
    Assign(endTime, nil);
    [super dealloc];
}

- (NSDate *)startTime
{
    return startTime;
}

- (NSDate *)endTime
{
    if (endTime != nil) {
        return endTime;
    }
    return [container endTime];
}

- (NSDate *)time
{
    return startTime;
}

- (void)setEndTime:(NSDate *)time
{
    Assign(endTime, time);
}

- (double)doubleValue
{
    return value;
}

- (id)value
{
    return [NSNumber numberWithDouble:value];
}

- (NSArray *)fieldNames
{
    return [[super fieldNames] arrayByAddingObject: @"Value"];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    id val;
    if ([fieldName isEqualToString:@"Value"]) {
        val = [NSNumber numberWithDouble:value];
    } else {
        val = [super valueOfFieldNamed:fieldName];
    }
    return val;
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
