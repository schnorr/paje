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
#ifndef _PajeTraceController_h_
#define _PajeTraceController_h_

#include <AppKit/AppKit.h>
#include "../General/PSortedArray.h"
#include "../General/PajeFilter.h"
#include "PajeCheckPoint.h"

#ifdef GNUSTEP
#define IBOutlet  
#endif

@interface PajeTraceController : NSObject
{
    id <PajeReader> reader;
    id <PajeSimulator> simulator;
    id encapsulator;
    NSMutableDictionary *components;
    
    NSMutableDictionary *filters;
    NSMutableArray *tools;

    NSString *configurationName;

    PSortedArray *chunkDates;
}

- (void)registerFilter:(PajeFilter *)filter;
- (void)registerTool:(id<PajeTool>)tool;

- (NSDictionary *)filters;
- (NSArray *)tools;

- (void)readNextChunk:(id)sender;
- (void)readChunk:(int)chunkNumber;
- (void)startChunk:(int)chunkNumber;
- (void)endOfChunk;

- (BOOL)openFile:(NSString *)filename;

- (void)setConfigurationName:(NSString *)name;
- (void)loadConfiguration:(NSString *)name;
- (void)saveConfiguration;

// One of the windows controlled by me has become key.
- (void)windowIsKey;

// Remove a component from the chain.
- (void)removeComponent:component;
@end

#endif
