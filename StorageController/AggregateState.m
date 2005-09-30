#include "AggregateState.h"

#include "../General/Macros.h"

@implementation AggregateState

+ (AggregateState *)stateWithStates:(NSArray *)entities
{
    return [[[self alloc] initWithEntities:entities] autorelease];
}

- (id)initWithEntities:(NSArray *)entities
{
    NSEnumerator *entityEnum;
    PajeEntity *entity;
    PajeEntity *lastEntity;
    
    entityEnum = [entities objectEnumerator];
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
                [condensedArray addName:[entity name]
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

- (int)imbricationLevel
{
    return imbricationLevel;
}

@end
