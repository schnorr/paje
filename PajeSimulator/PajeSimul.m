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

        rootContainerType = [PajeContainerType typeWithName:@"File"
                                              containerType:nil
                                                      event:nil];
        rootContainer = [[SimulContainer alloc] initWithType:rootContainerType
                                                        name:rootContainerName
                                                       alias:@"0"
                                                   container:nil
                                                creationTime:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                   simulator:self];
        [rootContainerType addInstance:rootContainer];

        [userTypes setObject:rootContainerType forKey:@"0"];
        [userTypes setObject:rootContainerType forKey:@"/"];
        [userTypes setObject:rootContainerType forKey:@"File"];
                            
        [userNumberToContainer setObject:rootContainer forKey:@"0"];
        [userNumberToContainer setObject:rootContainer forKey:@"/"];
        [userNumberToContainer setObject:rootContainer
                                  forKey:rootContainerName];
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

#ifndef MAP
#undef NS_MESSAGE
#ifndef NS_MESSAGE
#ifndef GNUSTEP
NSInvocation *invocation;
#define NS_MESSAGE(obj, meth)                                   \
    ((invocation = [NSInvocation invocationWithMethodSignature: \
    [obj methodSignatureForSelector: @selector(meth)]]),        \
    [invocation setTarget: obj],                                \
    [invocation setSelector: @selector(meth)],                  \
    invocation)
#else
#define NS_MESSAGE(target, message)                             \
    ([[[NSInvocation alloc] initWithTarget:target                \
    selector:@selector(message), nil] autorelease])
#endif                          // GNUSTEP
#define ADD_INVOCATION(name) [invocationTable  \
                                    setObject:NS_MESSAGE(self, paje##name:) \
                                       forKey:Paje##name##EventName]
#else                           // NS_MESSAGE
#define ADD_INVOCATION(name) [invocationTable  \
                                    setObject:NS_MESSAGE(self, paje##name:nil) \
                                       forKey:Paje##name##EventName]
#endif                          // NS_MESSAGE
#else /* MAP */
#define ADD_INVOCATION(name) NSMapInsert(invocationTable, \
                                         Paje##name##EventName, \
                                         [self methodForSelector:@selector(paje##name:)])
#endif /* MAP */

- (void)_initInvocationTable
{
#ifdef MAP
    invocationTable = NSCreateMapTable(NSIntMapKeyCallBacks/*NSObjectMapKeyCallBacks*/,
                                       NSIntMapValueCallBacks, 50);
#else
    Assign(invocationTable, [NSMutableDictionary dictionary]);
#endif
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
        userTypes = [[NSMutableDictionary alloc] init];
        userNumberToContainer = [[NSMutableDictionary alloc] init];
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
#ifdef MAP
    NSFreeMapTable(invocationTable);
#else
    [invocationTable release];
#endif
    [userTypes release];
    [userNumberToContainer release];
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
    return [userTypes objectForKey:name];
}

- (void)inputEntity:(PajeEvent *)event
{
    id time;

    [self rootContainer];

{
    NSString *filename;
        // set event's filename
//    file = [event objectForKey:@"File"];
//    if (file)
//        filename = [fileToFilename objectForKey:file];
//    else
        filename = [event objectForKey:@"FileName"];
    if (filename) {
        id line;
        int lineNumber;
        SourceCodeReference *sourceRef;
//        NSMutableDictionary *refToEvents;

        line = [event objectForKey:@"Line"];
        if (line == nil)
            line = [event objectForKey:@"LineNumber"];
        lineNumber = [line intValue];
        sourceRef = [SourceCodeReference referenceToFilename:filename
                                                  lineNumber:lineNumber];
//        refToEvents = [filenameToReferences objectForKey:filename];
//        [refToEvents addObject:event forKey:sourceRef];
        [event removeObjectForKey:@"File"];
        [event removeObjectForKey:@"FileName"];
        [event removeObjectForKey:@"Line"];
        [event removeObjectForKey:@"LineNumber"];
        [event setObject:sourceRef forKey:@"FileReference"];
    }

}

    // set the current time, if event has one
    time = [event time];
    if (time != nil) {
        [self setCurrentTime:time];
    }
    // invoke the method that simulates this event
#ifndef MAP
    NSInvocation *invocation;
    invocation = [invocationTable objectForKey:[event pajeEventName]];
    if (invocation) {
        [invocation setArgument:&event atIndex:2];
        [invocation invoke];
    }
#else
    void (*f)(id, SEL, id);
    f = NSMapGet(invocationTable, [event pajeEventName]);
    if (f != NULL) {
        f(self, 0, event);
    } else {
        NSLog(@"Unknown event \"%@\"", [event pajeEventName]);
    }
#endif
    
    eventCount++;
}

- (void)_resetContainers
{
    [[userNumberToContainer allValues]
        makeObjectsPerformSelector:@selector(reset)];
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
if (replaying) return;
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
{
    NSEnumerator *subContainerEnumerator;
    SimulContainer *subContainer;

    [container endOfChunk];
    
    if (endTime == nil || [endTime isEarlierThanDate:currentTime]) {
        Assign(endTime, currentTime);
    }

    subContainerEnumerator = [[container subContainers] objectEnumerator];
    while ((subContainer = [subContainerEnumerator nextObject]) != nil) {
        [self endOfChunkInContainer:subContainer];
    }
}

- (void)emptyChunk:(int)chunkNumber inContainer:(SimulContainer *)container
{
    NSEnumerator *subContainerEnumerator;
    SimulContainer *subContainer;

    [container emptyChunk:chunkNumber];
    
    subContainerEnumerator = [[container subContainers] objectEnumerator];
    while ((subContainer = [subContainerEnumerator nextObject]) != nil) {
        [self emptyChunk:chunkNumber inContainer:subContainer];
    }
}

- (id)chunkState
{
    NSEnumerator *containerEnum;
    SimulContainer *container;
    NSMutableDictionary *state;

    state = [NSMutableDictionary dictionary];

    [state setObject:currentTime forKey:@"_currentTime"];
    [state setObject:[NSNumber numberWithInt:eventCount] forKey:@"_eventCount"];

    // FIXME: should be saved by type
    containerEnum = [[userNumberToContainer allValues] objectEnumerator];
    while ((container = [containerEnum nextObject]) != nil) {
        id key = [container alias];
        if (nil == [state objectForKey:key]) {
            [state setObject:[container chunkState] forKey:key];
        }
    }
    
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
        container = [userNumberToContainer objectForKey:key];
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

    if (currentChunkNumber == [chunkInfo count] - 1) {
        replaying = NO;
    } else {
        replaying = YES;
    }

    [self startChunkInContainer:rootContainer];

    // keep the ball rolling (tell other components)
    [super startChunk:chunkNumber];
}


- (void)endOfChunk
{
    [self endOfChunkInContainer:rootContainer];

    currentChunkNumber++;
    // if we're at the end of the known world, let's register its position
    if (currentChunkNumber == [chunkInfo count]) {

        [chunkInfo addObject:[self chunkState]];

    }
    [super endOfChunk];
}

- (void)emptyChunk:(int)chunkNumber
{
    [self emptyChunk:chunkNumber inContainer:rootContainer];
}

- (void)notifyMissingChunk:(int)chunkNumber
{
    NSDictionary *userInfo;
    userInfo = [NSDictionary dictionaryWithObject:
                                 [NSNumber numberWithInt:chunkNumber]
                                           forKey:@"ChunkNumber"];
    [[NSNotificationCenter defaultCenter]
                  postNotificationName:@"PajeChunkNotInMemoryNotification"
                                object:self
                              userInfo:userInfo];
}

- (void)getChunksUntilTime:(NSDate *)time
{
    while ([currentTime isEarlierThanDate:time]) {
        int chunkNumber = [chunkInfo count] - 1;
        [self notifyMissingChunk:chunkNumber];
        // if no chunk has been read, give up
        if ([chunkInfo count] == chunkNumber) {
            break;
        }
    }
}


- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}
@end
