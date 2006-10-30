#include "AggregateLink.h"

#include "../General/Macros.h"

@implementation AggregateLink

+ (PajeEntity *)entityWithEntities:(NSArray *)entities
{
    return [[[self alloc] initWithEntities:entities] autorelease];
}

- (id)initWithEntities:(NSArray *)entities
{
    NSEnumerator *entityEnum;
    PajeEntity *entity;
    
    entityEnum = [entities reverseObjectEnumerator];
    entity = [entityEnum nextObject];

    NSParameterAssert(entity != nil);

    self = [super initWithType:[entity entityType]
                          name:@"AggregateLink"
                     container:[entity container]];
    if (self != nil) {
        sourceContainer = [entity sourceContainer];
        destContainer = [entity destContainer];
        condensedArray = [[CondensedEntitiesArray alloc] init];
        startTime = [entity startTime];
        endTime = [entity endTime];
        do {
            [condensedArray addArray:[entity condensedEntities]];
            condensedEntitiesCount += [entity condensedEntitiesCount];
            if (![entity isAggregate]) {
                [condensedArray addValue:[entity value]
                                duration:[entity doubleValue]];
                condensedEntitiesCount ++;
            }
            startTime = [startTime earlierDate:[entity startTime]];
            endTime = [endTime laterDate:[entity endTime]];
        } while ((entity = [entityEnum nextObject]) != nil);
        [startTime retain];
        [endTime retain];
    }
    return self;
}

- (double)subDurationAtIndex:(unsigned)i
{
    return [condensedArray durationAtIndex:i];
}

- (PajeContainer *)sourceContainer
{
    return sourceContainer;
}

- (PajeContainer *)destContainer
{
    return destContainer;
}

- (PajeEntityType *)sourceEntityType
{
    return [sourceContainer entityType];
}

- (PajeEntityType *)destEntityType
{
    return [destContainer entityType];
}

- (NSColor *)color
{
    return [NSColor blueColor];
}
@end
