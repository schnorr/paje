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
#import "SourceTextController.h"
#import "../General/NSString+Additions.h"
#import "../General/Macros.h"

@implementation SourceTextController

static NSMutableDictionary *filenameToInstance;

+ (SourceTextController *)controllerForFilename:(NSString *)name
{
    SourceTextController *controller;
    if (!filenameToInstance)
        filenameToInstance = [NSMutableDictionary new];
    controller = [filenameToInstance objectForKey:name];
    if (!controller) {
        controller = [[[super alloc] initWithFilename:name] autorelease];
        if (controller)
            [filenameToInstance setObject:controller forKey:name];
    }
    return controller;
}

- (id)initWithFilename:(NSString*)name
{
    self = [super init];
    if (self) {
        Assign(filename, name);
        if (![NSBundle loadNibNamed:@"SourceTextViewer" owner:self])
            NSRunAlertPanel(@"SourceTextController",
                            @"Couldn't load interface file", nil, nil, nil);
        [[textView window] makeKeyAndOrderFront:self];
    }
    return self;
}

- (void)dealloc
{
    [filename release];
    [textView release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [textView setString:[NSString stringWithContentsOfFile:filename]];
    [textView sizeToFit];
    [[textView window] setTitleWithRepresentedFilename:filename];
}

- (void)selectLineNumber:(unsigned)lineNumber
{
    NSString *string = [textView string];
    NSRange selRange;

    selRange = [string rangeForLineNumber:lineNumber];
    [textView sizeToFit];
    [textView setSelectedRange:selRange];
    [textView scrollRangeToVisible:selRange];
    [[textView window] orderFront:self];
}

// Deselect any previously highlighted line and select the specified one.
/*
- (void)selectCharRange:(NSRange)charRange
{
    NSTextStorage    *store = [self textStorage];

    [store beginEditing];
    if (previousSelection)
        [store removeAttribute:NSBackgroundColorAttributeName 
        range¬revRange];
    [store addAttribute:NSBackgroundColorAttributeName 
        value:selColor range:charRange];
    [store endEditing];

    prevRange = charRange;
    previousSelection = YES;
}
*/


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
    selRange = [textView selectionRangeForProposedRange:newRange
                                            granularity:NSSelectByParagraph];

    [textView sizeToFit];
//    [textView setSelectedRange:selRange];
//    [textView scrollRangeToVisible:selRange];

    lineNumber = [string lineNumberAtIndex:newRange.location];
    
    // highlight related entities
    [[NSClassFromString(@"A0bSimul") onlyInstance] selectLine:lineNumber inFile:filename];
    
    return selRange;
}

@end

