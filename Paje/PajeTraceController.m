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
#include "../General/Protocols.h"
#include "../General/Macros.h"
#include "../General/PajeFilter.h"
#include "../StorageController/Encapsulate.h"

// number of chunks to keep simultaneously in memory
// FIXME: should be configurable/more intelligent
#define CHUNKS_TO_KEEP 10

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
    [self removeCheckPointDirectory];
    Assign(checkPointDirectory, nil);
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
//    id virtualizer;
    id entityTypeSelector;
    id fieldFilter;
    id containerselector;
    id order;
    id statViewer;
//    id nodeGroup;
    id busyNode;
    id spacetime;
    id insetlimit;

    reader = (id<PajeReader>)[NSClassFromString(@"PajeFileReader") componentWithController:self];
    [components addObject:reader];
    decoder = [NSClassFromString(@"PajeEventDecoder") componentWithController:self];
    [components addObject:decoder];
    simulator = (id<PajeSimulator>)[NSClassFromString(@"PajeSimul") componentWithController:self];
    [components addObject:simulator];
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
    statViewer = [NSClassFromString(@"StatViewer") componentWithController:self];
    [components addObject:statViewer];

    [self connectComponent:reader            toComponent:decoder];
    [self connectComponent:decoder           toComponent:simulator];
    [self connectComponent:simulator         toComponent:encapsulator];
    [self connectComponent:encapsulator      toComponent:busyNode];
    [self connectComponent:busyNode          toComponent:fieldFilter];
    [self connectComponent:fieldFilter       toComponent:containerselector];
    [self connectComponent:containerselector toComponent:order];
    [self connectComponent:order             toComponent:entityTypeSelector];
//    [self connectComponent:busyNode          toComponent:statViewer];
    [self connectComponent:entityTypeSelector toComponent:insetlimit];
    [self connectComponent:insetlimit         toComponent:spacetime];
    [self connectComponent:insetlimit         toComponent:statViewer];
    
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

        [self performSelector:@selector(readChunk:)
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

- (void)readChunk:(id)sender
{
    int i;
    NSDate *start = [NSDate date], *end;
    double t;
    NSAutoreleasePool *pool;
    
    if (![reader hasMoreData]) {
        return;
    }
    
    i = -(int)[simulator eventCount];
    pool = [NSAutoreleasePool new];
    
    NS_DURING
        NSDebugMLLog(@"tim", @"will read chunk starting at %@",
                                [simulator currentTime]);
        [reader readNextChunk];
        [self writeCheckPoint];

    NS_HANDLER
        if (NSRunAlertPanel([localException name], @"%@\n%@",
                            @"Continue", @"Abort", nil,
                            [localException reason],
                            [localException userInfo]
                            //[[[localException userInfo] objectEnumerator] 
                            //allObjects]
                            ) != NSAlertDefaultReturn)
            [[NSApplication sharedApplication] terminate:self];
    NS_ENDHANDLER

    [pool release];

    end = [NSDate date];
    t = [end timeIntervalSinceDate:start];
    i += [simulator eventCount];
    NSLog(@"%@: %d events in %f seconds = %f e/s", [reader inputFilename], i, t, i/t);
    
}

- (void)createCheckPointDirectory
{
    NSString *dirname;
    NSString *path;
    
    if (checkPointDirectory != nil) {
        return;
    }
    
    dirname = [NSString stringWithFormat:@"Paje-%@-%@",
                          [[reader inputFilename] lastPathComponent],
                          [[NSProcessInfo processInfo] globallyUniqueString]];
    path = [NSTemporaryDirectory() stringByAppendingPathComponent:dirname];
    checkPointDirectory = [path retain];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:checkPointDirectory
                                               attributes:nil];

}

- (void)destroyCheckPointDirectory
{
    [[NSFileManager defaultManager] removeFileAtPath:checkPointDirectory
                                             handler:nil];
}

- (NSString *)checkPointDirectory
{
    if (checkPointDirectory == nil) {
        [self createCheckPointDirectory];
    }
    return checkPointDirectory;
}

- (void)writeCheckPoint
{
    NSMutableData *d;
    NSArchiver *a;
    id comp_enum;
    id component;
    NSDate *time;
    NSString *fileName;
    NSString *filePath;
    PajeCheckPoint *checkPoint;

    time = [simulator currentTime];
    if (time == nil) {
        return;
    }
    
    fileName = [NSString stringWithFormat:@"%@.ckp", [time description]];
    filePath = [[self checkPointDirectory]
                                stringByAppendingPathComponent:fileName];
    checkPoint = [PajeCheckPoint checkPointWithTime:time fileName:filePath];

    // If checkpoint has already been generated, do not write it again
    if ([checkPoints indexOfObject:checkPoint] != NSNotFound) {
        return;
    }

    NSDebugMLLog(@"tim", @"will write checkPoint %@", checkPoint);
    d = [[NSMutableData alloc] init];
    a = [[NSArchiver alloc] initForWritingWithMutableData:d];
    comp_enum = [components objectEnumerator];
    while ((component = [comp_enum nextObject]) != nil) {
        if ([component respondsToSelector:
                            @selector(encodeCheckPointWithCoder:)]) {
            NSDebugMLLog(@"tim", @"encoding component=%@", component);
            [component encodeCheckPointWithCoder:a];
        }
    }
    [d writeToFile:filePath atomically:NO];
    [a release];
    [d release];
    
    [checkPoints addObject:checkPoint];
}

- (void)gotoCheckPoint:(PajeCheckPoint *)checkPoint
{
    NSData *d;
    NSUnarchiver *a;
    NSEnumerator *comp_enum;
    id component;

    NSDebugMLLog(@"tim", @"will read checkPoint %@", checkPoint);

    d = [[NSData alloc] initWithContentsOfFile:[checkPoint fileName]];
    a=[[NSUnarchiver alloc] initForReadingWithData:d];
    comp_enum = [components objectEnumerator];

    while ((component = [comp_enum nextObject]) != nil) {
        if ([component respondsToSelector:
                            @selector(decodeCheckPointWithCoder:)]) {
            NSDebugMLLog(@"tim", @"decoding %@", component);
            [component decodeCheckPointWithCoder:a];
        }
    }
    [a release];
    [d release];
    [encapsulator removeObjectsAfterTime:[checkPoint time]];
}

- (void)traceFault:(NSNotification *)notification
{
    NSDictionary *info;
    NSDate *startTime;
    NSDate *endTime;
    unsigned index;
    int index2;
    PajeCheckPoint *checkPoint;

    info = [notification userInfo];
    startTime = [info objectForKey:@"StartTime"];
    endTime = [info objectForKey:@"EndTime"];

    if (startTime != nil) {
        index = [checkPoints indexOfLastObjectNotAfterValue:
                                                    (id<Comparing>)startTime];
    } else {
        index = NSNotFound;
    }

    if (index != NSNotFound) {
        // let's remove some old stuff
        // (should have some more intelligence in this!)
        index2 = index - CHUNKS_TO_KEEP;
        if (index2 > 0) {
            [encapsulator removeObjectsBeforeTime:
                [[checkPoints objectAtIndex: index2] time]];
        }

        checkPoint = [checkPoints objectAtIndex:index];
        if (([startTime isEarlierThanDate: [encapsulator startTimeInMemory]])
            || ([[checkPoint time] isLaterThanDate:[simulator currentTime]]))
            [self gotoCheckPoint:checkPoint];
    }
    
    while ([reader hasMoreData]
             && [[simulator currentTime] isEarlierThanDate:endTime]) {
        [self readChunk:self];
    } 
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

- (void)registerTool:(id<PajeTool>)tool
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
