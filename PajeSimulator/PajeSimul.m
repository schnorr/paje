/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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

// Class variable
static NSMutableDictionary *simulators;

@implementation PajeSimul

+ (void)initialize
{
    if (self == [PajeSimul class]) {
        simulators = [[NSMutableDictionary alloc] init];
#define INIT_STRINGS
#include "EventNames.h"
#undef INIT_STRINGS
    }
}

+ (PajeSimul *)simulatorWithName:(NSString *)n
{
    return [simulators objectForKey:n];
}

+ (void)setSimulator:(PajeSimul *)simul forName:(NSString *)n
{
    [simulators setObject:simul forKey:n];
}

- (void)error:(NSString *)format, ...
{
    va_list args;

    va_start(args, format);
    //NSLogv(format, args);
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

- (PajeContainer *)rootContainer
{
    if (rootContainer == nil) {
        PajeContainerType *rootContainerType;
        NSString *rootContainerName;
    
        rootContainerName = [inputComponent traceDescription];
        if (rootContainerName == nil) {
            return nil;
        }
        
        Assign(name, rootContainerName);
        [[self class] setSimulator:self forName:name];

        rootContainerType = [PajeContainerType typeWithName:@"File"
                                              containerType:nil];
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
    return [[self rootContainer] entityType];
}

- (NSString *)delete_name {
    return NSStringFromClass([self class]);
}

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
    ([[NSInvocation alloc] initWithTarget:target                \
    selector:@selector(message), nil])
#endif                          // GNUSTEP
#define ADD_INVOCATION(name) [invocationTable  \
                                    setObject:NS_MESSAGE(self, paje##name:) \
                                       forKey:Paje##name##EventName]
#else                           // NS_MESSAGE
#define ADD_INVOCATION(name) [invocationTable  \
                                    setObject:NS_MESSAGE(self, paje##name:nil) \
                                       forKey:Paje##name##EventName]
#endif                          // NS_MESSAGE

- (void)_initInvocationTable
{
    Assign(invocationTable, [NSMutableDictionary dictionary]);
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
    self =[super initWithController:c];

    if (self != nil) {
        userTypes = [[NSMutableDictionary alloc] init];
        userNumberToContainer = [[NSMutableDictionary alloc] init];

        [self _initInvocationTable];
    }

    return self;
}

- (void)dealloc
{
    [rootContainer release];
    [invocationTable release];
    [userTypes release];
    [userNumberToContainer release];
    [startTime release];
    [endTime release];
    [currentTime release];
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
    if (startTime == nil || [time isEarlierThanDate:startTime]) {
        Assign(startTime, time);
    }
    if (endTime == nil || [time isLaterThanDate:endTime]) {
        Assign(endTime, time);
    }
}

- (NSDate *)currentTime
{
    return currentTime;
}

- (void)inputEntity:(PajeEvent *)event
{
    NSInvocation *invocation;
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
        NSMutableDictionary *refToEvents;

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
    invocation = [invocationTable objectForKey:[event pajeEventName]];
    if (invocation) {
        [invocation setArgument:&event atIndex:2];
        [invocation invoke];
    }
}

- (void)_resetContainers
{
    [[userNumberToContainer allValues]
        makeObjectsPerformSelector:@selector(reset)];
}

- (void)encodeCheckPointWithCoder:(NSCoder *)coder
{
    NSEnumerator *containerEnum;
    SimulContainer *container;

    [coder encodeObject:name];
    [coder encodeObject:startTime];
    [coder encodeObject:endTime];
    [coder encodeObject:currentTime];
    containerEnum = [[userNumberToContainer allValues] objectEnumerator];
    while ((container = [containerEnum nextObject]) != nil) {
        [coder encodeObject:[container name]];
        [container encodeCheckPointWithCoder:coder];
    }
    [coder encodeObject:nil];
}

- (void)decodeCheckPointWithCoder:(NSCoder *)coder
{
    NSString *decodedName;
    NSString *containerName;
    
    decodedName = [coder decodeObject];
    
    if (![name isEqual:decodedName]) {
        [self error:@"decoding wrong simulator [%@ != %@]", name, decodedName];
    }

    Assign(startTime, [coder decodeObject]);
    Assign(endTime, [coder decodeObject]);
    Assign(currentTime, [coder decodeObject]);

    [self _resetContainers];

    while ((containerName = [coder decodeObject]) != nil) {
        SimulContainer *container;
        container = [userNumberToContainer objectForKey:containerName];
        if (container == nil) {
            [self error:@"Decoding unknown container '%@'", containerName];
        }
        [container decodeCheckPointWithCoder:coder];
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}
@end
