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
#include "ColoredSwitchButtonCell.h"
#include "Macros.h"

@implementation ColoredSwitchButtonCell
- (id)init
{
    self = [super init];
    [self setButtonType:NSSwitchButton];
    return self;
}

- (void) dealloc
{
    Assign(color, nil);
    [super dealloc];
}

- (void)setColor:(NSColor *)c
{
    Assign(color, c);
}

- (void)drawInteriorWithFrame:(NSRect)frame
                       inView:(NSView *)controlView
{
    NSRect r = frame;
    
    r.size.width = r.size.height;
    r = NSInsetRect(r, 3, 3);
    [color set];
    NSRectFill(r);
    
    r = NSOffsetRect(frame, NSHeight(frame), 0);
    r.size.width -= NSHeight(frame);
    [super drawInteriorWithFrame:r inView:controlView];
}

- (NSComparisonResult) compare: (id)otherCell
{
  return [[self stringValue] compare: [(NSCell*)otherCell stringValue]];
}

@end
