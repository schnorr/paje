/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
#include "PajeFileReader.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"
#include "../General/Macros.h"

#define LINE_SIZE 512

@implementation FileReader

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self != nil) {
        chunkInfo = [[NSMutableArray alloc] init];
        currentChunk = 0;
        hasMoreData = NO;
    }

    return self;
}

- (void)dealloc
{
    [inputFilename release];
    [inputFile release];
    [chunkInfo release];
    [super dealloc];
}

- (NSString *)traceDescription
{
    return [inputFilename stringByAbbreviatingWithTildeInPath];
}

// A new chunk will start.
// Position the file in the good position, if not yet there.
- (void)startChunk:(int)chunkNumber
{
    if (chunkNumber != currentChunk) {
        if (chunkNumber >= [chunkInfo count]) {
            // cannot position in an unread place
            NSLog(@"Chunk after end: %d (%d)", chunkNumber, [chunkInfo count]);
            [self raise:@"Cannot start unknown chunk"];
        }

        unsigned long /*long*/ position;
        position = [[chunkInfo objectAtIndex:chunkNumber] longLongValue];
        if (1||[inputFile seekToEndOfFile] > position) {
            [inputFile seekToFileOffset:position];
            hasMoreData = YES;
        } else {
            hasMoreData = NO;
        }

        currentChunk = chunkNumber;
    } else {
        // let's register the first chunk position
        if ([chunkInfo count] == 0) {

            unsigned long /*long*/ position;
            position = [inputFile offsetInFile];
            [chunkInfo addObject:[NSNumber numberWithLongLong:position]];

        }
    }

    // keep the ball rolling (tell other components)
    [super startChunk:chunkNumber];
}

// The current chunk has ended.
- (void)endOfChunkLast:(BOOL)last
{
    currentChunk++;
    if (!last) {
        // if we're at the end of the known world, let's register its position
        if (currentChunk == [chunkInfo count]) {

            unsigned long /*long*/ position;
            position = [inputFile offsetInFile];
            [chunkInfo addObject:[NSNumber numberWithLongLong:position]];

        }
    }
    [super endOfChunkLast:last];
}

- (void)raise:(NSString *)reason
{
    NSDebugLog(@"PajeFileReader: '%@' in file '%@', bytes read %lld",
                            reason, inputFilename, [inputFile offsetInFile]);
    [[NSException exceptionWithName:@"PajeReadFileException"
                             reason:reason
                           userInfo:
        [NSDictionary dictionaryWithObjectsAndKeys:
            inputFilename, @"File Name",
            [NSNumber numberWithUnsignedLongLong:[inputFile offsetInFile]],
                           @"BytesRead",
            nil]
        ] raise];
}


- (NSString *)inputFilename
{
    return inputFilename;
}

- (void)setInputFilename:(NSString *)filename
{
    if (inputFilename != nil) {
        [self raise:@"Already has an open file"];
    }
    Assign(inputFilename, filename);
    Assign(inputFile, [NSFileHandle fileHandleForReadingAtPath:filename]);

    if (inputFile == nil) {
        [self raise:@"Couldn't open file"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseCompression"]) {
#ifdef GNUSTEP
    	[inputFile useCompression];
#endif
    }
    hasMoreData = YES;
}

- (void)inputEntity:(id)entity
{    
    [self raise:@"Configuration error:" " PajeFileReader should be first component"];
}

- (BOOL)canEndChunk
{
    NSMutableData *data;
    unsigned int length;
    unsigned long /*long*/ offsetInFile;

    if (![self hasMoreData]) {
        return YES;
    }
    offsetInFile = [inputFile offsetInFile];
    data = (NSMutableData *)[inputFile readDataOfLength:LINE_SIZE];
    length = [data length];
    if (length < LINE_SIZE) {
        hasMoreData = NO;
    }
    const char *bytes;
    char *eol;
    bytes = [data bytes];
    eol = memchr(bytes, '\n', length);
    if (eol != NULL) {
        unsigned int newlength;
        newlength = eol - bytes + 1;
        if (newlength != length) {
            length = newlength;
            hasMoreData = YES;
            [inputFile seekToFileOffset:offsetInFile + length];
            [data setLength:length];
        }
    }
    NSDebugMLLog(@"tim", @"data: %@\nchunk length: %u has more:%d",
                 [data class], [data length], hasMoreData);
    if (length > 0) {
        if ([super canEndChunkBefore:data]) {
            [inputFile seekToFileOffset:offsetInFile];
            return YES;
        } else {
            [inputFile seekToFileOffset:offsetInFile + length];
            return NO;
        }
    } else {
        return YES;
    }
}

- (void)readNextChunk
{
    NSMutableData *data;
    unsigned int length;

    if (![self hasMoreData]) {
        return;
    }
    int nextChunk = currentChunk +1;
    if (nextChunk < [chunkInfo count]) {
        // this chunk has already been read, we should know its size
        unsigned long /*long*/ nextChunkPosition;
        nextChunkPosition = [[chunkInfo objectAtIndex:nextChunk] longLongValue];
        unsigned long /*long*/ chunkSize;
        chunkSize = nextChunkPosition - [inputFile offsetInFile];
        data = (NSMutableData *)[inputFile readDataOfLength:chunkSize];
        length = [data length];
        if (length != chunkSize) {
            [self raise:@"Cannot reread chunk! Has file been altered?"];
        }
        [self outputEntity:data];
    } else {
        // first time reading this chunk.
        // must determine its correct size (must end in a line boundary
        // and in a date-changing event).
        data = (NSMutableData *)[inputFile readDataOfLength:CHUNK_SIZE];
        length = [data length];
        if (length < CHUNK_SIZE) {
            hasMoreData = NO;
        } else {
            char *bytes;
            int i;
            int offset = 0;
            bytes = (char *)[data bytes];
            for (i = length-1; i >= 0 && bytes[i] != '\n'; i--) {
                offset++;
            }

            if ((i >= 0) && (offset > 0)) {
                [inputFile seekToFileOffset:[inputFile offsetInFile] - offset];
                length -= offset;
                [data setLength:length];
            }
        }
        NSDebugMLLog(@"tim", @"data: %@\nchunk length: %u has more:%d",
                     [data class], [data length], hasMoreData);
        if (length > 0) {
            [self outputEntity:data];
            while (![self canEndChunk]) {
                ;
            }
        }
    }
}

- (BOOL)hasMoreData
{
    return hasMoreData;
}
@end
