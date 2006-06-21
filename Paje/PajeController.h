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
#ifndef _PajeController_h_
#define _PajeController_h_

#include <AppKit/AppKit.h>
#include "PajeTraceController.h"

@interface PajeController:NSObject
{
    NSMutableArray *traceControllers;
    PajeTraceController *currentTraceController;
    NSMutableDictionary *bundles;

    IBOutlet NSWindow *filtersWindow;
    IBOutlet NSPopUpButton *filtersPopUp;
    IBOutlet NSBox *filtersDummyView;
    IBOutlet NSMenu *filtersMenu;
    IBOutlet NSMenu *toolsMenu;
}

+ (PajeController *)controller;
- (void)filterChanged:(id)sender;
- (void)filterMenuSelected:(id)sender;

- (NSBundle *)bundleWithName:(NSString *)name;

- (void)print:(id)sender;
- (void)open:(id)sender;

- (void)setCurrentTraceController:(PajeTraceController *)controller;
- (void)updateToolsMenu;
- (void)updateFiltersMenu;

- (void)closeTraceController:(PajeTraceController *)traceController;

// NSApplication delegate
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;

@end

@interface NSObject (PajeFilterDelegate)
- (void)viewWillBeSelected:(NSView *)view;
@end

#endif
