/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/

#include "PajeController.h"
#include "PajeTraceController.h"
#include "PajeCheckPoint.h"
#include "../General/Protocols.h"
#include "../General/Macros.h"
#include "../General/PajeFilter.h"
#include "../StorageController/Encapsulate.h"

#include <locale.h>


@interface NSMenu (RemoveAllItems)
- (void)removeAllItems;
@end
@implementation NSMenu (RemoveAllItems)
- (void)removeAllItems
{
    int i;
    
    for (i = [self numberOfItems]; i > 0; i--) {
        [self removeItemAtIndex: i-1];
    }
}
@end

@implementation PajeController

static PajeController *uniqueController;

+ (PajeController *)controller
{
    if (uniqueController == nil) {
        [[self alloc] init];
    }
    return uniqueController;
}

- (void)awakeFromNib
{
    // Couldn't connect to menu in Gorm, only to menuitem...
    if ([[filtersMenu class] isEqual:[NSMenuItem class]]) {
        filtersMenu = [(NSMenuItem *)filtersMenu submenu];
    }
    if ([[toolsMenu class] isEqual:[NSMenuItem class]]) {
        toolsMenu = [(NSMenuItem *)toolsMenu submenu];
    }
}

- (id)init
{
    if (uniqueController != nil) {
        [self release];
    } else {
        // initialisation code here
        Assign(traceControllers, [NSMutableArray array]);
        Assign(bundles, [NSMutableDictionary dictionary]);
        
        uniqueController = self;

        // FIXME: find a cleaner way of reading numbers independently of locale
        setlocale(LC_NUMERIC, "C");
    }
    return uniqueController;
}

- (void)dealloc
{
    Assign(traceControllers, nil);
    
    [super dealloc];
}

- (NSBundle *)loadBundleNamed:(NSString*)name
{
    NSString *bundleName;
    NSArray *bundlePaths;
    NSEnumerator *pathEnumerator;
    NSString *path;
    NSString *bundlePath;
    NSBundle *bundle;

    bundleName = [@"Bundles" stringByAppendingPathComponent:@"Paje"];
    bundleName = [bundleName stringByAppendingPathComponent:name];
    bundleName = [bundleName stringByAppendingPathExtension:@"bundle"];

    bundlePaths = [[NSUserDefaults standardUserDefaults]
                                       arrayForKey:@"BundlePaths"];
    if (!bundlePaths) {
        bundlePaths = NSSearchPathForDirectoriesInDomains(
                                            NSAllLibrariesDirectory,
                                            NSAllDomainsMask, YES);
    }

    // insert application path (eases development)
    bundlePaths = [[NSArray arrayWithObject:[[NSBundle mainBundle] bundlePath]]
                                 arrayByAddingObjectsFromArray:bundlePaths];

    pathEnumerator = [bundlePaths objectEnumerator];
    while ((path = [pathEnumerator nextObject]) != nil) {
        bundlePath = [path stringByAppendingPathComponent:bundleName];
        bundle = [NSBundle bundleWithPath:bundlePath];
        if ([bundle load]) {
            [bundles setObject:bundle forKey:name];
            return bundle;
        }
    }
    [NSException raise:@"PajeException" format:@"Bundle '%@' not found", name];
    return nil;
}

- (NSBundle *)bundleWithName:(NSString *)name
{
    NSBundle *bundle;

    bundle = [bundles objectForKey:name];
    if (bundle == nil) {
        [self loadBundleNamed:name];
        bundle = [bundles objectForKey:name];
    }

    return bundle;
}

- (void)loadAllBundles
{
return;
    [self loadBundleNamed:@"General"];
    [self loadBundleNamed:@"FileReader"];
    [self loadBundleNamed:@"PajeEventDecoder"];
    [self loadBundleNamed:@"PajeSimulator"];
    [self loadBundleNamed:@"StorageController"];

    [self loadBundleNamed:@"EntityTypeFilter"];
    [self loadBundleNamed:@"FieldFilter"];
    [self loadBundleNamed:@"ContainerFilter"];
    [self loadBundleNamed:@"OrderFilter"];
    [self loadBundleNamed:@"ReductionFilter"];
    [self loadBundleNamed:@"ImbricationFilter"];

    [self loadBundleNamed:@"SpaceTimeViewer"];
    [self loadBundleNamed:@"StatViewer"];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [filtersPopUp removeAllItems];
    [filtersMenu removeAllItems];
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    
    [self loadAllBundles];
}

- (void)applicationWillTerminate:(NSNotification *)notif
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)print:(id)sender
{
    [[[NSApplication sharedApplication] keyWindow] print:sender];
}

- (void)open:(id)sender
{
    id		openFilePanel;
    int		result;
    NSString   *directory;
    NSString   *filename;
    //NSArray    *filetypes = [NSArray arrayWithObjects:@"trace", nil];

    filename = [[NSUserDefaults standardUserDefaults]
                                      stringForKey:@"LastOpenFile"];
    if (!filename) filename = @"";
    directory = [filename stringByDeletingLastPathComponent];
    filename = [filename lastPathComponent];
    
    openFilePanel = [NSOpenPanel openPanel];
    [openFilePanel setCanChooseDirectories:NO];
    [openFilePanel setCanChooseFiles:YES];

    result = [openFilePanel runModalForDirectory:directory
                                            file:filename
                                           types:nil/*filetypes*/];
    
    if (result == NSOKButton) {
        [self application:NSApp openFile:[openFilePanel filename]];
    }
}

//
// message sent by NSApplication if the user double-clicks a trace file
//
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    PajeTraceController *traceController;
    
    [[NSUserDefaults standardUserDefaults] setObject:filename
                                              forKey:@"LastOpenFile"];
    
    traceController = [[[PajeTraceController alloc] init] autorelease];
    if (![traceController openFile:filename]) {
        return NO;
    }
    [traceControllers addObject:traceController];
    [self setCurrentTraceController:traceController];
    
    return YES;
}

- (void)closeTraceController:(PajeTraceController *)traceController
{
    if (traceController == currentTraceController) {
        [self setCurrentTraceController:nil];
    }
    [traceController close];
    [traceControllers removeObjectIdenticalTo:traceController];
}

- (void)filterMenuSelected:(id)sender
{
    [filtersPopUp selectItemAtIndex:[sender tag]];
    [self filterChanged:self];
    [filtersWindow makeKeyAndOrderFront:self];
}

- (void)filterChanged:(id)sender
{
    PajeFilter *filter;
    NSView *view;
    id delegate;
    
    filter = [[filtersPopUp selectedItem] representedObject];
    if (filter == nil ) return;
    
    view = [filter filterView]; 
    if ([filtersDummyView contentView] == view) return;
    delegate = [filter filterDelegate];
    [filtersWindow setDelegate:delegate];
    if ([delegate respondsToSelector:@selector(viewWillBeSelected:)])
        [delegate viewWillBeSelected:view];
    [filtersDummyView setContentView:view];
}


- (void)setCurrentTraceController:(PajeTraceController *)controller
{
    if (currentTraceController == controller) {
        return;
    }
    
    currentTraceController = controller;
    [self updateToolsMenu];
    [self updateFiltersMenu];
}

- (void)updateToolsMenu
{
    NSEnumerator *toolsEnum;
    id tool;
    
    // keep the first menu item (Colors)
    while ([toolsMenu numberOfItems] > 1) {
        [toolsMenu removeItemAtIndex:1];
    }
    
    toolsEnum = [[currentTraceController tools] objectEnumerator];
    for (tool = [toolsEnum nextObject];
         tool != nil;
         tool = [toolsEnum nextObject]) {
    
        NSString *toolName = [tool toolName];
    
        [[toolsMenu addItemWithTitle:[toolName stringByAppendingString:@"..."]
                              action:@selector(activateTool:)
                       keyEquivalent:@""] setTarget:tool];
    }
    
    [toolsMenu sizeToFit];
}

- (void)updateFiltersMenu
{
    NSDictionary *filters;
    NSEnumerator *filterNamesEnum;
    PajeFilter *filter;
    NSString *filterName;
    NSString *previouslySelectedFilterName;
    int tag = 0;
    
    previouslySelectedFilterName = [[[filtersPopUp selectedItem] title] retain];
    [filtersMenu removeAllItems];
    [filtersPopUp removeAllItems];
    
    filters = [currentTraceController filters];
    filterNamesEnum = [filters keyEnumerator];
    while ((filterName = [filterNamesEnum nextObject]) != nil) {    
        NSString *keyEquivalent;
        id<NSMenuItem> menuItem;
        NSString *menuTitle;

        filter = [filters objectForKey:filterName];
        keyEquivalent = [filter filterKeyEquivalent];
        if ([filter filterView] == nil) {
            NSWarnLog(@"Filter %@ has no view", filterName);
            continue;
        }

        [filtersPopUp addItemWithTitle:filterName];
        [[filtersPopUp lastItem] setRepresentedObject:filter];
        menuTitle = [filterName stringByAppendingString:@"..."];
        menuItem = [filtersMenu addItemWithTitle:menuTitle
                                          action:@selector(filterMenuSelected:)
                                   keyEquivalent:keyEquivalent];
        [menuItem setTag:tag++];
    }
    
    [filtersMenu addItemWithTitle:@"Save Configuration"
                           action:@selector(saveFilterConfiguration:)
                    keyEquivalent:@""];
    [filtersMenu addItemWithTitle:@"Load Configuration"
                           action:@selector(loadFilterConfiguration:)
                    keyEquivalent:@""];

    [filtersMenu sizeToFit];
    [filtersPopUp selectItemWithTitle:previouslySelectedFilterName];
    [self filterChanged:self];
    [previouslySelectedFilterName release];
}

- (void)saveFilterConfiguration:(id)sender
{
    [currentTraceController setConfigurationName:@"/tmp/pajeconfig"];
}

- (void)loadFilterConfiguration:(id)sender
{
    [currentTraceController loadConfiguration:@"/tmp/pajeconfig"];
}
@end
