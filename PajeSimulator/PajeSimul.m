/*
    Copyright (c) 1998--2005 Benhur Stein
    
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
/*
 * PajeSimul.m
 *
 * Simulator for Paje traces.
 *
 * 20021107 BS  creation (from A0bSimul)
 */


#include "PajeSimul.h"
#include "SimulContainer.h"
#include "../General/UniqueString.h"
#include "../General/SourceCodeReference.h"
#include "../General/NSDictionary+Additions.h"
#include "../General/Macros.h"
#include "../General/CStringCallBacks.h"

#include "../Paje/PajeTraceController.h"

#define DEFINE_STRINGS
#include "EventNames.h"
#undef DEFINE_STRINGS

@implementation PajeSimul

+ (void)initialize
{
    if (self == [PajeSimul class]) {
#define INIT_STRINGS
#include "EventNames.h"
#undef INIT_STRINGS
    }
}

- (void)error:(NSString *)format, ...
{
    va_list args;

    va_start(args, format);
    [NSException raise:@"PajeSimulException" format:format arguments:args];
    va_end(args);
}

- (void)error:(NSString *)str inEvent:(PajeEvent *)event
{
#ifdef OLDEVENT
    PajeEvent *eventCopy;
    NSDate *evTime;
    evTime = [event valueOfFieldNamed:@"Time"];
    if (evTime != nil) {
        id n;
        eventCopy = [event mutableCopy];
        n = [NSNumber numberWithDouble:[evTime timeIntervalSinceReferenceDate]];
        [eventCopy setValue:n ofFieldNamed:@"Time"];
    } else {
        eventCopy = [event retain];
    }
    [self error:@"%@ in event %@", str,
                [eventCopy descriptionWithLocale:[NSDictionary dictionary]
                                          indent:0]];
    [eventCopy release];
#else
    [self error:@"%@ in event %@", str, event];
#endif
}

- (PajeContainer *)rootInstance
{
    return [self rootContainer];
}

- (PajeContainer *)rootContainer
{
    if (rootContainer == nil) {
        PajeContainerType *rootContainerType;
        NSString *rootContainerName;
    
        rootContainerName = [inputComponent traceDescription];
        if (rootContainerName == nil) {
            return nil;
        }

        rootContainerType = [PajeContainerType typeWithId:@"File"
                                              description:@"File"
                                            containerType:nil
                                                    event:nil];
        rootContainer = [[SimulContainer alloc] initWithType:rootContainerType
                                                        name:rootContainerName
                                                       alias:@"0"
                                                   container:nil
                                                creationTime:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                       event:nil
                                                   simulator:self];
        [rootContainerType addInstance:rootContainer id1:"0" id2:"/"];

        [self setType:rootContainerType forId:"0"];
        [self setType:rootContainerType forId:"/"];
        [self setType:rootContainerType forId:"File"];

    }
    return rootContainer;
}

- (PajeContainerType *)rootContainerType
{
    return (PajeContainerType *)[[self rootContainer] entityType];
}

- (NSString *)delete_name {
    return NSStringFromClass([self class]);
}

#define ADD_INVOCATION(name) invocationTable[Paje##name##EventId] = \
                                         [self methodForSelector:@selector(paje##name:)]

- (void)_initInvocationTable
{
    ADD_INVOCATION(StartTrace);
    ADD_INVOCATION(DefineContainerType);
    ADD_INVOCATION(DefineEventType);
    ADD_INVOCATION(DefineStateType);
    ADD_INVOCATION(DefineVariableType);
    ADD_INVOCATION(DefineLinkType);
    ADD_INVOCATION(DefineEntityValue);
    ADD_INVOCATION(CreateContainer);
    ADD_INVOCATION(DestroyContainer);
    ADD_INVOCATION(NewEvent);
    ADD_INVOCATION(SetState);
    ADD_INVOCATION(PushState);
    ADD_INVOCATION(PopState);
    ADD_INVOCATION(SetVariable);
    ADD_INVOCATION(AddVariable);
    ADD_INVOCATION(SubVariable);
    ADD_INVOCATION(StartLink);
    ADD_INVOCATION(EndLink);
}

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self != nil) {
        userTypes = NSCreateMapTable(CStringMapKeyCallBacks,
                                     NSObjectMapValueCallBacks, 50);
        relatedEntities = [[NSMutableDictionary alloc] init];

        [self _initInvocationTable];

        chunkInfo = [[NSMutableArray alloc] init];
        currentChunkNumber = 0;
        currentTime = [[NSDate distantPast] retain];
    }

    return self;
}

- (void)dealloc
{
    [rootContainer release];
    NSFreeMapTable(userTypes);
    [relatedEntities release];
    [startTime release];
    [endTime release];
    [currentTime release];
    [chunkInfo release];
    [super dealloc];
}

- (NSDate *)startTime
{
    return startTime;
}

- (NSDate *)endTime
{
    return endTime;
}

- (void)setCurrentTime:(NSDate *)time
{
    Assign(currentTime, time);
    if (startTime == nil) {
        Assign(startTime, time);
    }
}

- (NSDate *)currentTime
{
    return currentTime;
}

- (int)eventCount
{
    return eventCount;
}

- (PajeEntityType *)entityTypeWithName:(NSString *)name
{
    return NSMapGet(userTypes, [name cString]);
}

- (id)typeForId:(const char *)typeId
{
    if (typeId == NULL) return nil;
    return NSMapGet(userTypes, typeId);
}

- (void)setType:(id)type forId:(const char *)typeId
{
    NSMapInsert(userTypes, strdup(typeId), type);
}

- (void)inputEntity:(PajeEvent *)event
{
    id time;

    [self rootContainer];

#ifdef SUPPORT_FOR_SOURCE_REFERENCES
    // set event's filename -- not supported
    NSString *filename;
    filename = [event stringForFieldId:PajeFileFieldId];
    if (filename != nil) {
        int lineNumber;
        SourceCodeReference *sourceRef;

        lineNumber = [event intForFieldId:PajeLineFieldId];
        sourceRef = [SourceCodeReference referenceToFilename:filename
                                                  lineNumber:lineNumber];
    }
#endif

    // set the current time, if event has one
    time = [event time];
    if (time != nil) {
        [self setCurrentTime:time];
    }

    // invoke the method that simulates this event
    int eventId;
    eventId = [event pajeEventId];
    IMP f = NULL;
    if (eventId >= 0 
           && eventId < (sizeof invocationTable / sizeof(invocationTable[0]))) {
        f = invocationTable[eventId];
    }
    if (f != NULL) {
        f(self, 0, event);
    } else {
        NSLog(@"Unknown event \"%@\"", event);
    }
    
    eventCount++;
}


- (BOOL)canEndChunkBefore:(PajeEvent *)event
{
    id time;

    time = [event time];
    if (time != nil 
          && [currentTime isLaterThanDate:[NSDate distantPast]]
          && [currentTime isLaterThanDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0]] 
          && [time isLaterThanDate:currentTime]) {
        return YES;
    }

    [self inputEntity:event];
    return NO;
}


- (void)_resetContainers
{
    //[[userNumberToContainer allValues]
    //    makeObjectsPerformSelector:@selector(reset)];
}

- (void)addRelatedEntity:(id)entity toKey:(id)key
{
    NSMutableArray *entities;
    entities = [relatedEntities objectForKey:key];
    if (entities == nil) {
        entities = [NSMutableArray arrayWithObject:entity];
        [relatedEntities setObject:entities forKey:key];
    } else {
        [entities addObject:entity];
    }
}

- (NSArray *)relatedEntitiesForEntity:(id<PajeEntity>)entity
{
    id key;

    key = [entity valueOfFieldNamed:@"RelationKey"];
    if (key != nil) {
        return [relatedEntities objectForKey:key];
    } else {
        return [entity relatedEntities];
    }
}

- (void)outputEntity:(id)entity
{
    id key;
    key = [(id<PajeEntity>)entity valueOfFieldNamed:@"RelationKey"];
    if (key != nil) {
        [self addRelatedEntity:entity toKey:key];
    }
    [super outputEntity:entity];
}

- (void)outputChunk:(id)entity
{
    if (replaying) {
        return;
    }
    [super outputEntity:entity];
}


- (void)startChunkInContainer:(SimulContainer *)container
{
    NSEnumerator *subContainerEnumerator;
    SimulContainer *subContainer;

    [container startChunk];

    subContainerEnumerator = [[container subContainers] objectEnumerator];
    while ((subContainer = [subContainerEnumerator nextObject]) != nil) {
        [self startChunkInContainer:subContainer];
    }
}

- (void)endOfChunkInContainer:(SimulContainer *)container
                         last:(BOOL)last
{
    NSEnumerator *subContainerEnumerator;
    SimulContainer *subContainer;

    [container endOfChunkLast:last];
    
    if (endTime == nil || [endTime isEarlierThanDate:currentTime]) {
        Assign(endTime, currentTime);
    }

    subContainerEnumerator = [[container subContainers] objectEnumerator];
    while ((subContainer = [subContainerEnumerator nextObject]) != nil) {
        [self endOfChunkInContainer:subContainer last:last];
    }
}

- (void)emptyChunk:(int)chunkNumber
       inContainer:(SimulContainer *)container
{
    NSEnumerator *subContainerEnumerator;
    SimulContainer *subContainer;

    [container emptyChunk:chunkNumber];
    
    subContainerEnumerator = [[container subContainers] objectEnumerator];
    while ((subContainer = [subContainerEnumerator nextObject]) != nil) {
        [self emptyChunk:chunkNumber inContainer:subContainer];
    }
}

- (void)addStateOfContainer:(SimulContainer *)container
                     toDict:(NSMutableDictionary *)dict
{
    NSEnumerator *subContainerEnumerator;
    SimulContainer *subContainer;

    [dict setObject:[container chunkState] forKey:[container alias]];
    
    subContainerEnumerator = [[container subContainers] objectEnumerator];
    while ((subContainer = [subContainerEnumerator nextObject]) != nil) {
        [self addStateOfContainer:subContainer toDict:dict];
    }
}

- (id)chunkState
{
    //NSEnumerator *containerEnum;
    //SimulContainer *container;
    NSMutableDictionary *state;

    state = [NSMutableDictionary dictionary];

    [state setObject:currentTime forKey:@"_currentTime"];
    [state setObject:[NSNumber numberWithInt:eventCount] forKey:@"_eventCount"];

    // FIXME: should be saved by type
    //containerEnum = [[userNumberToContainer allValues] objectEnumerator];
    //while ((container = [containerEnum nextObject]) != nil) {
    //    id key = [container alias];
    //    if (nil == [state objectForKey:key]) {
    //        [state setObject:[container chunkState] forKey:key];
    //    }
    //}
    [self addStateOfContainer:(SimulContainer *)[self rootContainer]
                       toDict:state];
    
    return state;
}

- (void)setChunkState:(id)obj
{
    NSDictionary *state = (NSDictionary *)obj;

    [self setCurrentTime:[state objectForKey:@"_currentTime"]];
    eventCount = [[state objectForKey:@"_eventCount"] intValue];

    [self _resetContainers];

    NSEnumerator *keyEnum;
    id key;
    keyEnum = [state keyEnumerator];
    while ((key = [keyEnum nextObject]) != nil) {
        SimulContainer *container;
        //container = [userNumberToContainer objectForKey:key];
        container = [self containerForId:[key cString] type:nil];
        if (container == nil) {
            if (![key isEqual:@"_currentTime"]
                && ![key isEqual:@"_eventCount"]) {
                [self error:@"Decoding unknown container '%@'", key];
            }
        } else {
            [container setChunkState:[state objectForKey:key]];
        }
    }
}

- (int)currentChunkNumber
{
    return currentChunkNumber;
}

- (void)startChunk:(int)chunkNumber
{
    if (chunkNumber != currentChunkNumber) {
        if (chunkNumber >= [chunkInfo count]) {
            // cannot position in an unread place
            [self error:@"Cannot start unknown chunk"];
        }

        [self setChunkState:[chunkInfo objectAtIndex:chunkNumber]];

        currentChunkNumber = chunkNumber;
    } else {
        // let's register the first chunk position
        if ([chunkInfo count] == 0) {

            [chunkInfo addObject:[self chunkState]];

        }
    }

    if (!lastChunkSeen && currentChunkNumber == [chunkInfo count] - 1) {
        replaying = NO;
    } else {
        replaying = YES;
    }

    [self startChunkInContainer:rootContainer];

    // keep the ball rolling (tell other components)
    [super startChunk:chunkNumber];
}

- (BOOL)isReplaying
{
    return replaying;
}


- (void)endOfChunkLast:(BOOL)last
{
    [self endOfChunkInContainer:rootContainer last:last];

    if (!last) {
        currentChunkNumber++;
        // if we're at the end of the known world, let's register its position
        if (currentChunkNumber == [chunkInfo count]) {

            [chunkInfo addObject:[self chunkState]];

        }
    } else {
        lastChunkSeen = YES;
    }
    [super endOfChunkLast:(BOOL)last];
}

- (void)emptyChunk:(int)chunkNumber
{
    [self emptyChunk:chunkNumber inContainer:rootContainer];
}

- (void)notifyMissingChunk:(int)chunkNumber
{
    [controller missingChunk:chunkNumber];
}

- (void)getChunksUntilTime:(NSDate *)time
{
    while ([currentTime isEarlierThanDate:time]) {
        int chunkNumber = [chunkInfo count] - 1;
        [self notifyMissingChunk:chunkNumber];
        // if no chunk has been read, give up
        if ([chunkInfo count] - 1 == chunkNumber) {
            break;
        }
    }
}


- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}
@end
