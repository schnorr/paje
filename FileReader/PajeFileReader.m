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
    [coder encodeValuesOfObjCTypes:"@Q", &inputFilename, &bytesScanned];
}

- (void)decodeCheckPointWithCoder:(NSCoder *)coder
{
    id filename;
    unsigned long long location;

    Assign(remainsOfLastRead, nil);
    
    [coder decodeValuesOfObjCTypes:"@Q", &filename, &location];
    if (inputFilename) {
        if (![filename isEqual:inputFilename]) {
            [self raise:@"trying to read check point file of a different trace file"];
        }
    } else {
        [self setInputFilename:filename];
    }
    [filename release];
    bytesScanned = location;
    [inputFile seekToFileOffset:bytesScanned];
}

- (void)dealloc
{
    [inputFilename release];
    [inputFile release];
    [remainsOfLastRead release];
    [super dealloc];
}

- (NSString *)traceDescription
{
    return [inputFilename stringByAbbreviatingWithTildeInPath];
}

- (void)raise:(NSString *)reason
{
    NSLog(@"PajeFileReader: '%@' in file '%@', bytes read %d",
                            reason, inputFilename, bytesScanned);
    [[NSException exceptionWithName:@"PajeReadFileException"
                             reason:reason
                           userInfo:
        [NSDictionary dictionaryWithObjectsAndKeys:
            inputFilename, @"File Name",
            [NSNumber numberWithUnsignedLongLong:bytesScanned], @"BytesRead",
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
}

- (void)inputEntity:(id)entity
{    
    [self raise:@"Configuration error: should not receive programmed input"];
}

- (void)readNextChunk
{
    NSData *data;
    data = [inputFile availableData];
    [self outputEntity:data];
}

- (int)eventCount
{
    return [outputComponent eventCount];
}
@end
