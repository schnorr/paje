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
//
// SourceCodeReference
//
// Contains a reference to a source line in a file.
//

#include "SourceCodeReference.h"
#include "Macros.h"

@implementation SourceCodeReference

+ (SourceCodeReference *)referenceToFilename:(NSString *)name
                                 lineNumber:(int)line
{
    return [[[self alloc] initWithFilename:name lineNumber:line] autorelease];
}

- (id)initWithFilename:(NSString *)name
           lineNumber:(int)line
{
    self = [super init];
    if (self) {
        Assign(filename, name);
        lineNumber = line;
    }
    return self;
}

- (void)dealloc
{
    Assign(filename, nil);
    [super dealloc];
}

//
// accessors
//

- (NSString *)filename  { return filename; }
- (int)lineNumber       { return lineNumber; }


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%d", filename, lineNumber];
}

//
// it can be hashed (NSObject protocol)
//
- (unsigned)hash
{
    return lineNumber;
}

- (BOOL)isEqual:(id)object
{
    if ((self == object)
        || ([object isKindOfClass:[SourceCodeReference class]]
            && lineNumber == [object lineNumber]
            && [filename isEqual:[object filename]]))
        return YES;
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}


// NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
//    [super encodeWithCoder:coder];
    [coder encodeValuesOfObjCTypes:"@i", &filename, &lineNumber];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];//WithCoder:coder];
    [coder decodeValuesOfObjCTypes:"@i", &filename, &lineNumber];
    return self;
}
@end
