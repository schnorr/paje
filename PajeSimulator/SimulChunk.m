/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004, 2005 Benhur Stein
    
    This file is part of Pajé.

    Pajé is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Pajé is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Pajé; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/

#include "SimulChunk.h"
#include "../General/FilteredEnumerator.h"
#include "../General/Macros.h"

@implementation SimulChunk
+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc
                 incompleteEntities:(NSMutableArray *)array
{
    Class class;
    switch ([type drawingType]) {
    case PajeEventDrawingType:
        class = [EventChunk class];
        break;
    case PajeStateDrawingType:
        class = [StateChunk class];
        break;
    case PajeLinkDrawingType:
        class = [LinkChunk class];
        break;
    case PajeVariableDrawingType:
        class = [VariableChunk class];
        break;
    default:
        NSWarnMLog(@"No support for creating chunk of type %@", type);
        class = nil;
    }

    return [[[class alloc] initWithEntityType:type
                                    container:pc
                           incompleteEntities:array] autorelease];
}

+ (SimulChunk *)chunkWithEntityType:(PajeEntityType *)type
                          container:(PajeContainer *)pc
{
    return [self chunkWithEntityType:type
                           container:pc
                  incompleteEntities:nil];
}

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
      incompleteEntities:(NSMutableArray *)array
{
    NSParameterAssert(array == nil);
    return [super initWithEntityType:type container:pc];
}

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
{
    return [self initWithEntityType:type container:pc incompleteEntities:nil];
}


- (NSEnumerator *)enumeratorOfAllCompleteEntities
{
    [self _subclassResponsibility:_cmd];
    return nil;
}
- (NSEnumerator *)enumeratorOfCompleteEntitiesAfterTime:(NSDate *)time
{
    [self _subclassResponsibility:_cmd];
    return nil;
}


// all entities, including those that finish after the chunk's endTime
- (NSEnumerator *)enumeratorOfAllEntities
{
    [self _subclassResponsibility:_cmd];
    return nil;
}

- (NSEnumerator *)enumeratorOfEntitiesBeforeTime:(NSDate *)time
{
    [self _subclassResponsibility:_cmd];
    return nil;
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime
{
    [self _subclassResponsibility:_cmd];
    return nil;
}


- (void)removeAllCompletedEntities
{
    [self _subclassResponsibility:_cmd];
}


- (NSMutableArray *)incompleteEntities
{
    [self _subclassResponsibility:_cmd];
    return nil;
}


// Simulation
- (void)addEntity:(PajeEntity *)entity
{
    [self _subclassResponsibility:_cmd];
}


- (void)stopWithEvent:(PajeEvent *)event
{
    [self _subclassResponsibility:_cmd];
}


// for states
- (void)pushEntity:(PajeEntity *)entity
{
    [self _subclassResponsibility:_cmd];
}

- (UserState *)topEntity
{
    [self _subclassResponsibility:_cmd];
    return nil;
}

- (void)removeTopEntity
{
    [self _subclassResponsibility:_cmd];
}

@end

@implementation EventChunk

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
      incompleteEntities:(NSMutableArray *)array
{
    self = [super initWithEntityType:type
                           container:pc
                  incompleteEntities:array];
    if (self != nil) {
        entities = [[PSortedArray alloc] initWithSelector:@selector(endTime)];
    }
    return self;
}

- (void)dealloc
{
    Assign(entities, nil);
    [super dealloc];
}

- (NSEnumerator *)enumeratorOfAllEntities
{
    return [entities reverseObjectEnumerator];
}

- (NSEnumerator *)enumeratorOfAllCompleteEntities
{
    return [entities reverseObjectEnumerator];
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesAfterTime:(NSDate *)time
{
    return [entities reverseObjectEnumeratorAfterValue:(id<Comparing>)time];
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime
{
    NSEnumerator *enAfterStart;
    SEL filterSelector = @selector(isEntity:laterThan:);
    
    enAfterStart = [self enumeratorOfCompleteEntitiesAfterTime:sliceStartTime];
    return [FilteredEnumerator enumeratorWithEnumerator:enAfterStart
                                                 filter:self
                                               selector:filterSelector
                                                context:sliceEndTime];
}

- (NSEnumerator *)enumeratorOfEntitiesBeforeTime:(NSDate *)time
{
    NSEnumerator *enAll;
    SEL filterSelector = @selector(isEntity:laterThan:);
    
    enAll = [self enumeratorOfAllEntities];
    return [FilteredEnumerator enumeratorWithEnumerator:enAll
                                                 filter:self
                                               selector:filterSelector
                                                context:time];
}

- (void)removeAllCompletedEntities
{
    [entities removeAllObjects];
}

- (void)setIncompleteEntities:(NSMutableArray *)array
{
    [self _subclassResponsibility:_cmd];
}

- (NSMutableArray *)incompleteEntities
{
    return nil;
}


- (void)addEntity:(PajeEntity *)entity
{
    [entities addObject:entity];
}

- (void)stopWithEvent:(PajeEvent *)event
{
}

- (id)copyWithZone:(NSZone *)z
{
    EventChunk *copy;
    copy = [super copyWithZone:z];
    [copy->entities release];
    copy->entities = [entities copy];
    return copy;
}
@end


@implementation StateChunk

- (id)initWithEntityType:(PajeEntityType *)type
               container:(PajeContainer *)pc
      incompleteEntities:(NSMutableArray *)array
{
    self = [super initWithEntityType:type container:pc incompleteEntities:nil];
    if (self != nil) {
        if (array != nil) {
            Assign(incompleteEntities, array);
        } else {
            incompleteEntities = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)dealloc
{
    Assign(incompleteEntities, nil);
    [super dealloc];
}

- (void)setIncompleteEntities:(NSMutableArray *)array
{
    Assign(incompleteEntities, array);
}

- (NSMutableArray *)incompleteEntities
{
    return incompleteEntities;
}


- (void)pushEntity:(PajeEntity *)entity
{
    [incompleteEntities addObject:entity];
    if ([entity respondsToSelector:@selector(setImbricationLevel:)]) {
        [(UserState *)entity setImbricationLevel:[incompleteEntities count]-1];
    }
}

- (UserState *)topEntity
{
    return (UserState *)[incompleteEntities lastObject];
}

- (void)removeTopEntity
{
    [incompleteEntities removeLastObject];
}

- (void)stopWithEvent:(PajeEvent *)event
{
    UserState *poppedUserState;
    UserState *newTopUserState;

    poppedUserState = [self topEntity];
    while (poppedUserState != nil) {
        [poppedUserState setEndEvent:event];
        [self addEntity:poppedUserState];
        [self removeTopEntity];
        newTopUserState = [self topEntity];
        if (newTopUserState != nil) {
            [newTopUserState addInnerState:poppedUserState];
        }
        poppedUserState = newTopUserState;
    }
}


- (NSEnumerator *)enumeratorOfAllEntities
{
    MultiEnumerator *multiEnum = [MultiEnumerator enumerator];
    [multiEnum addEnumerator:[incompleteEntities objectEnumerator]];
    [multiEnum addEnumerator:[entities reverseObjectEnumerator]];
    return multiEnum;
}

- (NSEnumerator *)enumeratorOfEntitiesFromTime:(NSDate *)sliceStartTime
                                        toTime:(NSDate *)sliceEndTime
{
    MultiEnumerator *multiEnum;
    SEL filterSelector = @selector(isEntity:laterThan:);
    
    multiEnum = [MultiEnumerator enumerator];
    [multiEnum addEnumerator:[incompleteEntities objectEnumerator]];
    [multiEnum addEnumerator:
                [self enumeratorOfCompleteEntitiesAfterTime:sliceStartTime]];
    return [FilteredEnumerator enumeratorWithEnumerator:multiEnum
                                                 filter:self
                                               selector:filterSelector
                                                context:sliceEndTime];
}

- (id)copyWithZone:(NSZone *)z
{
    StateChunk *copy;
    copy = [super copyWithZone:z];
    [copy->incompleteEntities release];
    copy->incompleteEntities = [incompleteEntities copy];
    return copy;
}
@end


@implementation LinkChunk
@end
@implementation VariableChunk
@end
