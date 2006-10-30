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

@implementation PajeTraceController
- (id)init
{
    NSNotificationCenter *notificationCenter;
    
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    Assign(components, [NSMutableDictionary dictionary]);
    Assign(filters, [NSMutableDictionary dictionary]);
    Assign(tools, [NSMutableArray array]);
    chunkDates = [[NSClassFromString(@"PSortedArray") alloc]
                                initWithSelector:@selector(self)];

    notificationCenter = [NSNotificationCenter defaultCenter];

    // accept notifications posted when we should read more of the trace file
    [notificationCenter addObserver:self
                           selector:@selector(chunkFault:)
                               name:@"PajeChunkNotInMemoryNotification"
                             object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Assign(filters, nil);
    Assign(tools, nil);
    Assign(components, nil);
    Assign(chunkDates, nil);
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

- (id)createComponentWithName:(NSString *)componentName
                 ofClassNamed:(NSString *)className
{
    Class componentClass;
    id component;

    componentClass = NSClassFromString(className);
    if (componentClass == Nil) {
        NSBundle *bundle;
        bundle = [[PajeController controller] bundleWithName:className];
        componentClass = [bundle principalClass];
        NSLog(@"bundle %@: %@ class:%@", className, bundle, componentClass);
    } 
    component = [componentClass componentWithController:self];
    if (component != nil) {
        [components setObject:component forKey:componentName];
    }
    return component;
}

- (void)connectComponent:(id)c1 toComponent:(id)c2
{
    [c1 setOutputComponent:c2];
    [c2 setInputComponent:c1];
}

- (id)componentWithName:(NSString *)name
{
    id component;
    
    component = [components objectForKey:name];
    if (component == nil) {
        NSString *className;
        if ([[NSScanner scannerWithString:name]
                scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
                           intoString:&className]) {
            component = [self createComponentWithName:name
                                         ofClassNamed:className];
        }
    }
    return component;
}

- (void)connectComponentNamed:(NSString *)n1
             toComponentNamed:(NSString *)n2
{
    id c1;    
    id c2;
    c1 = [self componentWithName:n1];
    c2 = [self componentWithName:n2];
    [self connectComponent:c1 toComponent:c2];
}

- (void)addComponentSequence:(NSArray *)componentSequence
{
    int index;
    int count;
    
    count = [componentSequence count];
    for (index = 1; index < count; index++) {
        NSString *componentName1;
        NSString *componentName2;
        componentName1 = [componentSequence objectAtIndex:index-1];
        componentName2 = [componentSequence objectAtIndex:index];
        [self connectComponentNamed:componentName1
                   toComponentNamed:componentName2];
    }
}

- (void)addComponentSequences:(NSArray *)componentSequences
{
    int index;
    int count;
    
    count = [componentSequences count];
    for (index = 0; index < count; index++) {
        NSArray *componentSequence;
        componentSequence = [componentSequences objectAtIndex:index];
        [self addComponentSequence:componentSequence];
    }
}

+ (NSArray *)defaultComponentGraph
{
    NSArray *graph;

    graph = [@"( ( FileReader, \
                   PajeEventDecoder, \
                   PajeSimulator, \
                   StorageController, \
                   AggregatingFilter, \
                   ReductionFilter, \
                   FieldFilter, \
                   ContainerFilter, \
                   OrderFilter, \
                   EntityTypeFilter, \
                   ImbricationFilter, \
                   SpaceTimeViewer \
                 ), \
                 ( ImbricationFilter, \
                   StatViewer ) )" propertyList];

    /*
    graph = [@"( ( PajeFileReader, \
                   PajeEventDecoder, \
                   PajeSimul, \
                   Encapsulate, \
                   InsetLimit, \
                   STController \
                 ), \
                 ( InsetLimit, \
                   StatViewer ) )" propertyList];
		   */
    return graph;
}

- (void)createComponentGraph
{
    [self addComponentSequences:[[self class] defaultComponentGraph]];

    reader = [self componentWithName:@"FileReader"];
    simulator = [self componentWithName:@"PajeSimulator"];
    encapsulator = [self componentWithName:@"StorageController"];
/*
    reader = [self componentWithName:@"PajeFileReader"];
    simulator = [self componentWithName:@"PajeSimul"];
    encapsulator = [self componentWithName:@"Encapsulate"];
*/
}


//
// message sent by NSApplication if the user double-clicks a trace file
//
- (BOOL)openFile:(NSString *)filename
{
    NS_DURING
        [self createComponentGraph];
        [reader setInputFilename:filename];

        [self performSelector:@selector(readNextChunk:)
                   withObject:self
                   afterDelay:0.0];

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

- (void)readNextChunk:(id)sender
{
    [self readChunk:[chunkDates count]];
/*
    if ([reader hasMoreData]) {
        float delay = (float)rand()/RAND_MAX*100;
        [self performSelector:_cmd withObject:self afterDelay:delay];
        NSLog(@"one more after %f", delay);
    }
*/
}

- (void)readChunk:(int)chunkNumber
{
    int i;
    NSDate *start, *end, *e2;
    double t, t2;
    NSAutoreleasePool *pool;
    
    pool = [NSAutoreleasePool new];
    start = [NSDate date];
    
    NS_DURING
        [self startChunk:chunkNumber];
        i = -(int)[simulator eventCount];
        if ([reader hasMoreData]) {
            NSDebugMLLog(@"tim", @"will read chunk starting at %@",
                                    [simulator currentTime]);
            [reader readNextChunk];
        }
        [self endOfChunkLast:![reader hasMoreData]];

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

    end = [[NSDate date] retain];
    t = [end timeIntervalSinceDate:start];
    i += [simulator eventCount];
    
    [pool release];

    e2 = [NSDate date];
    t2 = [e2 timeIntervalSinceDate:end];
    [end release];
    NSLog(@"%@: %d events in %f seconds = %f e/s; rel=%f", [reader inputFilename], i, t, i/t, t2);
}

- (void)startChunk:(int)chunkNumber
{
    [reader startChunk:chunkNumber];
    if ([reader hasMoreData] && chunkNumber >= [chunkDates count]) {
        [chunkDates addObject:[simulator currentTime]];
    }
}

- (void)endOfChunkLast:(BOOL)last
{
    [reader endOfChunkLast:last];
}

- (void)chunkFault:(NSNotification *)notification
{
    int chunkNumber;
    
    chunkNumber = [[[notification userInfo] 
                          objectForKey:@"ChunkNumber"] intValue];
    [self readChunk:chunkNumber];
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

- (void)removeComponent:component
{
    [[PajeController controller] closeTraceController:self];
}

- (void)saveConfiguration
{
    NSEnumerator *filterEnum;
    NSString *filterName;
    NSMutableDictionary *configuration;
    
    configuration = [NSMutableDictionary dictionary];

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

    configuration = [NSDictionary
                               dictionaryWithContentsOfFile:configurationName];
    
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
