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
I've taken this from http://jeremy.hksys.com/openstep/index.html

NSMatrix within a NSScrollView

by Jeremy Bettis <jeremy@hksys.com>
(Updated Feb 6, 1998)

_

When a NSMatrix (such as a NSForm) is positioned inside of a NSScrollView, pulling the scrollbar down and clicking on a text cell selects the wrong cell. Here is a fix.

*/


#include <AppKit/AppKit.h>

// ====================================================================
// A NSForm inside of a NSScrollView does not handle mouse clicks
// correctly. This subclass fixes that.  It scrolls the old selected
// cell to visible while activating the new one.
// ====================================================================

static int dontscroll = 0;

@interface HackedMatrix : NSMatrix
- (void) scrollCellToVisibleAtRow:(int)r column:(int)c;
- (void) textDidEndEditing:(NSNotification *)notify;
@end

@implementation HackedMatrix
+ (void) load
{
//    id pool = [NSAutoreleasePool new];
//    [self poseAsClass:[NSMatrix class]];
//    [pool release];
}

- (void) scrollCellToVisibleAtRow:(int)r column:(int)c
{
    if (dontscroll <= 0) {
        [super scrollCellToVisibleAtRow:r column:c];
    }
    dontscroll = 0;
}

- (void) textDidEndEditing:(NSNotification *)notify
{
    dontscroll=1;
    NS_DURING
        [super textDidEndEditing:notify];
    NS_HANDLER
        dontscroll = 0;
        [localException raise];
    NS_ENDHANDLER
    dontscroll = 0;
}

@end
