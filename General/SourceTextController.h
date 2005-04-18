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
#ifndef _SourceTextController_h_
#define _SourceTextController_h_
//
// SourceTextController
//
// Shows a source file; can select lines and highlights events
// caused by a line when it is selected.
// controller and delegate of the textView that shows the source file
//

#include <AppKit/AppKit.h>

@interface SourceTextController : NSObject
{
    IBOutlet NSTextView *textView;
    NSString *filename;
}

+ (SourceTextController *)controllerForFilename:(NSString *)name;
- (id)initWithFilename:(NSString*)name;

- (void)selectLineNumber:(unsigned)lineNumber;

// This delegate method is called when the selection is about to change
// (and whenever the textView is clicked on).
- (NSRange)textView:(NSTextView *)aTextView
willChangeSelectionFromCharacterRange:(NSRange)oldRange
   toCharacterRange:(NSRange)newRange;

@end
#endif
