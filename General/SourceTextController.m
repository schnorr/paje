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
#include "SourceTextController.h"
#include "../General/NSString+Additions.h"
#include "../General/Macros.h"

@implementation SourceTextController

static NSMutableDictionary *filenameToInstance;

+ (SourceTextController *)controllerForFilename:(NSString *)name
{
    SourceTextController *controller;
    if (filenameToInstance == nil) {
        filenameToInstance = [NSMutableDictionary new];
    }

    controller = [filenameToInstance objectForKey:name];
    if (controller == nil) {
        controller = [[[super alloc] initWithFilename:name] autorelease];
        if (controller != nil) {
            [filenameToInstance setObject:controller forKey:name];
        }
    }
    return controller;
}

- (id)initWithFilename:(NSString*)name
{
    NSString *fileContents;
    
    fileContents = [NSString stringWithContentsOfFile:name];
    if (fileContents == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        Assign(filename, name);
        if (![NSBundle loadNibNamed:@"SourceTextViewer" owner:self])
            NSRunAlertPanel(@"SourceTextController",
                            @"Couldn't load interface file", nil, nil, nil);
        [textView setString:fileContents];
        [textView sizeToFit];
        [[textView window] setTitleWithRepresentedFilename:name];
        [[textView window] makeKeyAndOrderFront:self];
    }
    return self;
}

- (void)dealloc
{
    [filename release];
//    [textView release];
//    [lineNumberField release];
    [super dealloc];
}

- (IBAction)lineNumberChanged:(id)sender
{
    [self selectLineNumber:[sender intValue]];
}

- (void)selectLineNumber:(unsigned)lineNumber
{
    NSString *string = [textView string];
    NSRange selRange;

    selRange = [string rangeForLineNumber:lineNumber];
    [textView setSelectedRange:selRange];
    [textView scrollRangeToVisible:selRange];
    [[textView window] orderFront:self];
}


// This delegate method is called when the selection is about to change
// (and whenever the textView is clicked on).
- (NSRange)textView:(NSTextView *)aTextView
willChangeSelectionFromCharacterRange:(NSRange)oldRange
   toCharacterRange:(NSRange)newRange
{
    NSString *string = [textView string];
    unsigned lineNumber;
    NSRange selRange;

    // expand the range to the whole line
    selRange = [string lineRangeForRange:NSMakeRange(newRange.location, 0)];

    lineNumber = [string lineNumberAtIndex:selRange.location];
    [lineNumberField setIntValue:lineNumber];

    // highlight related entities
//    [[NSClassFromString(@"A0bSimul") onlyInstance] selectLine:lineNumber inFile:filename];

    return selRange;
}

// Delegate method from window
- (void)windowWillClose:(NSNotification *)aNotification
{
    [filenameToInstance removeObjectForKey:filename];
}
@end

