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
#include "PajeTraceController.h"
#include "PajeController.h"
#include "PajeCheckPoint.h"
#include "../General/Protocols.h"
#include "../General/Macros.h"
#include "../General/PajeFilter.h"
#include "../StorageController/Encapsulate.h"

@implementation PajeTraceController
- (id)init
{
    NSNotificationCenter *notificationCenter;
    
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    Assign(components, [NSMutableArray array]);
    Assign(filters, [NSMutableDictionary dictionary]);
    Assign(tools, [NSMutableArray array]);

    notificationCenter = [NSNotificationCenter defaultCenter];

    // accept notifications posted when we should read more of the trace file
    [notificationCenter addObserver:self
                           selector:@selector(traceFault:)
                               name:@"PajeTraceNotInMemoryNotification"
                             object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Assign(filters, nil);
    Assign(tools, nil);
    Assign(checkPoints, nil);
    Assign(components, nil);
    [super dealloc];
}

- (NSDictionary *)filters
{
    return filters;
}

- (NSArray *)tools
{
    return tools;
}

- (void)connectComponent:(id)c1 toComponent:(id)c2
{
    [c1 setOutputComponent:c2];
    [c2 setInputComponent:c1];
}

- (id)createComponentGraph
{
    id decoder;
    id virtualizer;
    id simul;
    id entityTypeSelector;
    id fieldFilter;
    id containerselector;
    id order;
//    id statViewer;
//    id nodeGroup;
    id busyNode;
    id spacetime;
    id insetlimit;

    reader = [NSClassFromString(@"PajeFileReader") componentWithController:self];
    [components addObject:reader];
    decoder = [NSClassFromString(@"PajeEventDecoder") componentWithController:self];
    [components addObject:decoder];
    simul = [NSClassFromString(@"PajeSimul") componentWithController:self];
    [components addObject:simul];
    encapsulator = [NSClassFromString(@"Encapsulate") componentWithController:self];
    [components addObject:encapsulator];
//    virtualizer = [NSClassFromString(@"VirtualThread") componentWithController:self];
//    [components addObject:virtualizer];
    entityTypeSelector = [NSClassFromString(@"EntityTypeSelector") componentWithController:self];
    fieldFilter = [NSClassFromString(@"FieldFilter") componentWithController:self];
    [components addObject:entityTypeSelector];
    containerselector = [NSClassFromString(@"ContainerSelector") componentWithController:self];
    [components addObject:containerselector];
    order = [NSClassFromString(@"Order") componentWithController:self];
    [components addObject:order];
//    nodeGroup = [NSClassFromString(@"NodeGroup") componentWithController:self];
//    [components addObject:nodeGroup];
    busyNode = [NSClassFromString(@"BusyNode") componentWithController:self];
    [components addObject:busyNode];
    insetlimit = [NSClassFromString(@"InsetLimit") componentWithController:self];
    [components addObject:insetlimit];
    spacetime = [NSClassFromString(@"STController") componentWithController:self];
    [components addObject:spacetime];
//    statViewer = [NSClassFromString(@"StatViewer") componentWithController:self];
//    [components addObject:statViewer];

    [self connectComponent:reader            toComponent:decoder];
    [self connectComponent:decoder           toComponent:simul];
    [self connectComponent:simul             toComponent:encapsulator];
    [self connectComponent:encapsulator      toComponent:busyNode];
    [self connectComponent:busyNode          toComponent:fieldFilter];
    [self connectComponent:fieldFilter       toComponent:containerselector];
    [self connectComponent:containerselector toComponent:order];
    [self connectComponent:order             toComponent:entityTypeSelector];
//    [self connectComponent:busyNode          toComponent:statViewer];
    [self connectComponent:entityTypeSelector toComponent:insetlimit];
    [self connectComponent:insetlimit         toComponent:spacetime];
    
    return reader;
}


//
// message sent by NSApplication if the user double-clicks a trace file
//
- (BOOL)openFile:(NSString *)filename
{
    NS_DURING
        [self createComponentGraph];
        [reader setInputFilename:filename];

        [self performSelector:@selector(readAll:)
                   withObject:self
                   afterDelay:0.0];

        [checkPoints release];
        checkPoints = [[NSClassFromString(@"PSortedArray") alloc] initWithSelector:@selector(time)];
        [self writeCheckPoint];

        NS_VALUERETURN(YES, BOOL);
    NS_HANDLER
        if (NSRunAlertPanel([localException name], @"%@\n%@",
                            @"Continue", @"Abort", nil,
                            [localException reason],
                            [[[localException userInfo] objectEnumerator] allObjects]) != NSAlertDefaultReturn)
            [[NSApplication sharedApplication] terminate:self];
        NS_VALUERETURN(NO, BOOL);
    NS_ENDHANDLER
}

- (void)readAll:(id)sender
{
    int i = 0;
    NSDate *start = [NSDate date], *end;
    double t;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NS_DURING
[reader readNextChunk];
/*
        while([reader readNextEvent]) {
            i++;
            if ((i) % 1000 == 0) {
                //[self writeCheckPoint];
                [pool release];
                pool = [NSAutoreleasePool new];
//break;
            }
        }
*/

        [pool release];
        end = [NSDate date];
        t = [end timeIntervalSinceDate:start];
        i = [reader eventCount];
        NSLog(@"%@: %d events in %f seconds = %f e/s", [reader inputFilename], i, t, i/t);

    NS_HANDLER
        if (NSRunAlertPanel([localException name], @"%@\n%@",
                            @"Continue", @"Abort", nil,
                            [localException reason],
                            [[[localException userInfo] objectEnumerator] allObjects]) != NSAlertDefaultReturn)
            [[NSApplication sharedApplication] terminate:self];
    NS_ENDHANDLER
}

- (void)writeCheckPoint
{
#if 0
    NSMutableData *d;
    NSArchiver *a;
    id comp_enum = [components objectEnumerator];
    id component;
    NSDate *time = [reader currentTime];
    NSString *fileName = [NSString stringWithFormat:@"/tmp/Paje-%@.ckp", [time description]];
    PajeCheckPoint *checkPoint = [PajeCheckPoint checkPointWithTime:time
                                                           fileName:fileName];

    if ([checkPoints indexOfObject:checkPoint] != NSNotFound)
        return;

    d = [[NSMutableData alloc] init];
    a = [[NSArchiver alloc] initForWritingWithMutableData:d];
    while (component = [comp_enum nextObject]) {
        if ([component respondsToSelector:@selector(encodeCheckPointWithCoder:)]) {
            [component encodeCheckPointWithCoder:a];
        }
    }
    [d writeToFile:fileName atomically:NO];
    [a release];
    [d release];
    
    [checkPoints addObject:checkPoint];
#endif
}

- (void)gotoCheckPoint:(PajeCheckPoint *)checkPoint
{
#if 0
    NSData *d = [[NSData alloc] initWithContentsOfFile:[checkPoint fileName]];
    NSUnarchiver *a=[[NSUnarchiver alloc] initForReadingWithData:d];
    id comp_enum = [components objectEnumerator];
    id component;
    while (component = [comp_enum nextObject])
        if ([component respondsToSelector:@selector(decodeCheckPointWithCoder:)]) {
            NSLog(@"%@ lendo %@", NSStringFromClass([component class]), [checkPoint fileName]);
            [component decodeCheckPointWithCoder:a];
        }
    [a release];
    [d release];
    [encapsulator removeObjectsAfterTime:[checkPoint time]];


    //KLUDGE
    [self performSelector:@selector(readAll:)
               withObject:self
               afterDelay:0.0];

#endif
}

- (void)traceFault:(NSNotification *)notification
{
    NSDictionary *info;
    NSDate *startTime;
    NSDate *endTime;
    unsigned index;
    int index2;
    PajeCheckPoint *checkPoint;
    int i;
    BOOL endOfFile;

    return;
//#if 0
    info = [notification userInfo];
    startTime = [info objectForKey:@"StartTime"];
    endTime = [info objectForKey:@"EndTime"];
    index = [checkPoints indexOfLastObjectNotAfterValue:(id<Comparing>)startTime];

    // let's remove some old stuff (should have some more intelligence in this!)
    index2 = index - 5;
    if (index2 > 0)
        [encapsulator removeObjectsBeforeTime:
            [[checkPoints objectAtIndex: index2] time]];

    if (index != NSNotFound) {
        checkPoint = [checkPoints objectAtIndex:index];
        if (([startTime isEarlierThanDate: [encapsulator startTimeInMemory]])
            || ([[checkPoint time] isLaterThanDate:[reader currentTime]]))
            [self gotoCheckPoint:checkPoint];
    }
//#endif
    
//    NSLog(@"traceFault: will read, starting at %@", [reader currentTime]);
//    [reader readUntilTime:endTime];
    endOfFile = NO;
    do {
        NSAutoreleasePool *pool;
        pool = [[NSAutoreleasePool alloc] init];
        for (i=0; i<2000 && !endOfFile; i++) {
            endOfFile = ![reader readNextEvent];
            if (((i+1) % 50) == 49) {
                [pool release];
                pool = [[NSAutoreleasePool alloc] init];
            }
        }
        [pool release];
        if (!endOfFile)
            [self writeCheckPoint];
    } while (!endOfFile && [[reader currentTime] isEarlierThanDate:endTime]);
//    NSLog(@"read until %@ (asked for %@)", [reader currentTime], endTime);
}

- (void)registerFilter:(PajeFilter *)filter
{
    NSString *filterName;
    PajeFilter *f;

    filterName = [filter filterName];
    while (YES) {
        f = [filters objectForKey:filterName];
        if (f == nil) {
            break;
        }
        if (f == filter) {
            return;
        }
        filterName = [filterName stringByAppendingString:@"+"];
    }
    [filters setObject:filter forKey:filterName];
    [[PajeController controller] updateFiltersMenu];
}

- (void)registerTool:(id)tool
{
    [tools addObject:tool];
    [[PajeController controller] updateToolsMenu];
}

- (void)windowIsKey
{
    [[PajeController controller] setCurrentTraceController:self];
}

- (void)saveConfiguration
{
    NSEnumerator *filterEnum;
    NSString *filterName;
    NSMutableDictionary *configuration;
    
    configuration = [NSMutableDictionary dictionaryWithCapacity:[filters count]];

    filterEnum = [filters keyEnumerator];

    while ((filterName = [filterEnum nextObject]) != nil) {
        PajeFilter *filter;
        NSDictionary *filterConfig;
        
        filter = [filters objectForKey:filterName];
        filterConfig = [filter configuration];
        
        if (filterConfig != nil) {
            [configuration setObject:filterConfig forKey:filterName];
        }
    }
    
    [configuration writeToFile:configurationName atomically:YES];
}

- (void)loadConfiguration:(NSString *)name
{
    // FIXME: should load and connect filters; more info needed on config file
    NSDictionary *configuration;
    NSEnumerator *filterEnum;
    NSString *filterName;
    
    Assign(configurationName, name);

    configuration = [NSDictionary dictionaryWithContentsOfFile:configurationName];
    
    filterEnum = [configuration keyEnumerator];

    while ((filterName = [filterEnum nextObject]) != nil) {
        PajeFilter *filter;
        NSDictionary *filterConfig;
        
        filter = [filters objectForKey:filterName];
        
        if (filter == nil) {
            // FIXME: shouldn't be done this way: reload all filters
            continue;
        }
        filterConfig = [configuration objectForKey:filterName];
        
        if (filterConfig != nil) {
            [filter setConfiguration:filterConfig];
        }
    }
}

- (void)setConfigurationName:(NSString *)name
{
    Assign(configurationName, name);
    [self saveConfiguration];
}
@end
