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
#include "PajeFileReader.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"
#include "../General/Macros.h"

@implementation PajeFileReader

- (id)initWithController:(PajeTraceController *)c
{
    [super initWithController:c];

    return self;
}

- (void)encodeCheckPointWithCoder:(NSCoder *)coder
{
    unsigned long long position = [inputFile offsetInFile];
    [coder encodeValuesOfObjCTypes:"@Q", &inputFilename, &position];
    NSDebugMLLog(@"tim", @"encoded %@ %lld", inputFilename, position);
}

- (void)decodeCheckPointWithCoder:(NSCoder *)coder
{
    id filename;
    unsigned long long position;
    
    [coder decodeValuesOfObjCTypes:"@Q", &filename, &position];
    NSDebugMLLog(@"tim", @"decoded %@ %lld", filename, position);
    if (inputFilename) {
        if (![filename isEqual:inputFilename]) {
            [self raise:@"trying to read check point file of a different trace file"];
        }
    }

    [filename release];
    [inputFile seekToFileOffset:position];
    hasMoreData = YES;
}

- (void)dealloc
{
    [inputFilename release];
    [inputFile release];
    [super dealloc];
}

- (NSString *)traceDescription
{
    return [inputFilename stringByAbbreviatingWithTildeInPath];
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
    Assign(inputFilename, filename);
    Assign(inputFile, [NSFileHandle fileHandleForReadingAtPath:filename]);

    if (inputFile == nil) {
        [self raise:@"Couldn't open file"];
    }
    hasMoreData = YES;
}

- (void)inputEntity:(id)entity
{    
    [self raise:@"Configuration error: should not receive programmed input"];
}

- (void)readNextChunk
{
    NSData *data;
    unsigned int length;

    if (![self hasMoreData]) {
        return;
    }
    data = [inputFile readDataOfLength:CHUNK_SIZE];
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
    
        if (i >= 0) {
            [inputFile seekToFileOffset:[inputFile offsetInFile] - offset];
            length -= offset;
            [data setLength:length];
        }
    }
    NSDebugMLLog(@"tim", @"data: %@\nchunk length: %u has more:%d",
                 [data class], [data length], hasMoreData);
    if (length > 0) {
        [self outputEntity:data];
    }
}

- (BOOL)hasMoreData
{
    return hasMoreData;
}

// shouldn't be here
- (int)eventCount
{
    return [outputComponent eventCount];
}
- (NSDate *)currentTime
{
    return [outputComponent currentTime];
}
@end
