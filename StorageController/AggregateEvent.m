#include "AggregateEvent.h"

#include "../General/Macros.h"

@implementation AggregateEvent

+ (AggregateEvent *)eventWithEvents:(NSArray *)entities;
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
                          name:@"AggregateEvent"
                     container:[entity container]];
    if (self != nil) {
        condensedArray = [[CondensedEntitiesArray alloc] init];
        Assign(endTime, [entity endTime]);
        do {
            [condensedArray addArray:[entity condensedEntities]];
            condensedEntitiesCount += [entity condensedEntitiesCount];
            if (![entity isAggregate]) {
                [condensedArray addName:[entity name] count:1];
                condensedEntitiesCount ++;
            }
            lastEntity = entity;
        } while ((entity = [entityEnum nextObject]) != nil);
        Assign(startTime, [lastEntity startTime]);
    }
    return self;
}

- (void)dealloc
{
    Assign(condensedArray, nil);
    Assign(startTime, nil);
    Assign(endTime, nil);
    [super dealloc];
}

- (BOOL)isAggregate
{
    return YES;
}

- (NSDate *)startTime
{
    return startTime;
}

- (NSDate *)time
{
    return startTime;
}

- (NSDate *)endTime
{
    return endTime;
}

- (double)exclusiveDuration
{
    return 0.0;
}

- (unsigned)condensedEntitiesCount
{
    return condensedEntitiesCount;
}

- (CondensedEntitiesArray *)condensedEntities
{
    return condensedArray;
}

- (unsigned)subCount
{
    return [condensedArray count];
}

- (NSString *)subNameAtIndex:(unsigned)i
{
    return [condensedArray nameAtIndex:i];
}

- (NSColor *)subColorAtIndex:(unsigned)i
{
    return [entityType colorForName:[condensedArray nameAtIndex:i]];
}

- (unsigned)subCountAtIndex:(unsigned)i
{
    return [condensedArray countAtIndex:i];
}

- (double)subDurationAtIndex:(unsigned)i
{
    return [self duration] * [condensedArray countAtIndex:i]
                           / condensedEntitiesCount;
}

- (NSColor *)color
{
    return [NSColor whiteColor];
}

@end
