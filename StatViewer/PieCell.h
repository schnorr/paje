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
#ifndef _PieCell_h_
#define _PieCell_h_
/* PieCell.h created by benhur on Wed 24-Sep-1997 */
/*
   Cell that shows a pie-chart.
   The values of the pie are in "representedObject", that is an NSArray
   of NSDictionaries, each with a "Value", "Color", and "Name" fields.
   */
#include <AppKit/AppKit.h>
#include "StatArray.h"
#include "StatValue.h"

@interface PieCell : NSCell
{
    id dataProvider;
    StatArray *data;
    NSNumber *initialAngle;
    BOOL simple;              // true if undecorated display
    int type;
    BOOL showPercent;
}

- (void)setDataProvider:(id)provider;
- (void)setData:(StatArray *)d;

// overrides from NSCell:
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)setInitialAngle:(NSNumber *)angle;
- (void)setGraphType:(int)t;
- (void)setShowPercent:(BOOL)yn;
@end
#include "StatViewer.h"
#endif
