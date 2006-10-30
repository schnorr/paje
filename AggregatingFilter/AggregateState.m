#include "AggregateState.h"

#include "../General/Macros.h"

@implementation AggregateState

+ (PajeEntity *)entityWithEntities:(NSArray *)entities
{
    return [[[self alloc] initWithEntities:entities] autorelease];
}

- (id)initWithEntities:(NSArray *)entities
{
    NSEnumerator *entityEnum;
    PajeEntity *entity;
    PajeEntity *lastEntity;
    
    entityEnum = [entities reverseObjectEnumerator];
    entity = [entityEnum nextObject];

    NSParameterAssert(entity != nil);

    self = [super initWithType:[entity entityType]
                          name:@"AggregateState"
                     container:[entity container]];
    if (self != nil) {
        condensedArray = [[CondensedEntitiesArray alloc] init];
        imbricationLevel = [entity imbricationLevel];
        Assign(endTime, [entity endTime]);
        do {
            [condensedArray addArray:[entity condensedEntities]];
            condensedEntitiesCount += [entity condensedEntitiesCount];
            if (![entity isAggregate]) {
                [condensedArray addValue:[entity value]
                                duration:[entity exclusiveDuration]];
                condensedEntitiesCount ++;
            }
            lastEntity = entity;
        } while ((entity = [entityEnum nextObject]) != nil);
        Assign(startTime, [lastEntity startTime]);
    }
    return self;
}

- (double)subDurationAtIndex:(unsigned)i
{
    return [condensedArray durationAtIndex:i];
}

- (double)exclusiveDuration
{
    return [self duration] - [condensedArray totalDuration];
}

- (int)imbricationLevel
{
    return imbricationLevel;
}

@end
