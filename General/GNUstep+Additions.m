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
 * GNUstep+Additions
 *
 * Some missing methods in GNUstep
 */

#ifdef GNUSTEP

#include <AppKit/AppKit.h>

@implementation NSAttributedString (Additions)
- (NSComparisonResult)compare:(id)other
{
    if ([other isKindOfClass:[NSAttributedString class]]) {
        return [[self string] compare:[(NSAttributedString *)other string]];
    } else if ([other isKindOfClass:[NSString class]]) {
        return [[self string] compare:(NSString *)other];
    }
    return [super compare:other];
}
@end

@implementation NSClipView (Additions)
- (void) viewFrameChanged: (NSNotification*)aNotification
{
  NSRect proposedVisibleRect;
  NSRect newVisibleRect;
  NSRect newBounds;

  // give documentView a chance to adjust its visible rectangle
  proposedVisibleRect = [self convertRect: _bounds toView: _documentView];
  newVisibleRect = [_documentView adjustScroll: proposedVisibleRect];
  newBounds = [self convertRect: newVisibleRect fromView: _documentView];
  newBounds.origin = [self constrainScrollPoint: newBounds.origin];
  [self setBounds: newBounds];

  /* If document frame does not completely cover _bounds */
  if (NSContainsRect([_documentView frame], _bounds) == NO)
    {
      /*
       * fill the area not covered by documentView with background color
       */
      [self setNeedsDisplay: YES];
    }

  [_super_view reflectScrolledClipView: self];
}

@end
#endif
