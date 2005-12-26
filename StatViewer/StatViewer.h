/*
    Copyright (c) 1997-2005 Benhur Stein
    
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
#ifndef _StatViewer_h_
#define _StatViewer_h_

#include <AppKit/AppKit.h>
#include "PieCell.h"
#include "StatArray.h"
#include "../General/PajeFilter.h"

@interface StatViewer: PajeFilter <PajeTool>
{
    id matrix;
    id window;
    NSDate *startTime;
    NSDate *endTime;
    IBOutlet NSPopUpButton *entityTypeSelector;
    IBOutlet NSPopUpButton *graphTypeSelector;
    id durationField;
}
- (void)awakeFromNib;

- (void)setStartTime:(NSDate *)time;
- (void)setEndTime:(NSDate *)time;

- (void)timeSelectionChanged;
- (void)changeInitialAngle:(id)sender;
- (IBAction)graphTypeSelectorChanged:(id)sender;
- (IBAction)entityTypeSelectorChanged:(id)sender;

- (PajeEntityType *)selectedEntityType;

- (void)invalidateValues;
- (void)invalidateCellCaches;
- (void)provideDataForCell:(PieCell *)cell;

- (void)windowDidResize:(NSNotification *)notification;
- (void)print:(id)sender;
@end

#endif
