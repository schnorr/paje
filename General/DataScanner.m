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


#include "DataScanner.h"

@implementation DataScanner
+ (DataScanner *)scannerWithData:(NSData *)_data
{
    return [[[self alloc] initWithData:_data] autorelease];
}

- (id)initWithData:(NSData *)_data
{
    if ((self = [super init])) {
        Assign(data, _data);
        position = 0;
    }
    return self;
}

- (void)dealloc
{
    Assign(data, nil);
    [super dealloc];
}

- (NSData *)data
{
    return data;
}

- (unsigned)position
{
    return position;
}

- (void)setPosition:(unsigned)_position
{
    if (_position <= [data length])
        position = _position;
}

#define DECLS     char *bytes = (char *)[data bytes];    \
                  unsigned length = [data length];       \
                  int c;
#define NEXTCHAR ((position < length) ? bytes[position++] : -1)
#define SKIPWHITE do { c = NEXTCHAR; } while (c==' ' /*|| c=='\n'*/ || c=='\t' || c=='\r')
#define SKIPNONWHITE do { c = NEXTCHAR; } while (c!=' ' && c!='\n' && c!='\t' && c!=-1)

- (int)readChar
{
    DECLS;
    SKIPWHITE;
    return c;
}

- (NSNumber *)readIntNumber
{
    int value = 0;
    int signal = 1;
    DECLS;
    
    SKIPWHITE;
    if (c == '-') {
        signal = -1;
        c = NEXTCHAR;
    }
    if (c<'0' || c>'9') {
        if (c != -1) position--;
        return nil;
    }
    while (c >= '0' && c <= '9') {
        value = value * 10 + c - '0';
        c = NEXTCHAR;
    }
    if (c != -1) position--;
    return [NSNumber numberWithInt:value*signal];
}

- (NSNumber *)readDoubleNumber
{
    double value=0;
    int signal = 1;
    DECLS;

    return [NSNumber numberWithDouble:[self readDouble]];
    SKIPWHITE;
    if (c == '-') {
        signal = -1;
        c = NEXTCHAR;
    }
    if (c < '0' || c > '9') {
        if (c != -1) position--;
        return nil;
    }
    while (c >= '0' && c <= '9') {
        value = value * 10 + c - '0';
        c = NEXTCHAR;
    }
    if (c == '.') {
        double m=.1;
        c = NEXTCHAR;
        while (c >= '0' && c <= '9') {
            value = value + (c - '0') * m;
            m /= 10;
            c = NEXTCHAR;
        }
    }
    if (c != -1) position--;
    return [NSNumber numberWithDouble:value*signal];
}

- (double)readDouble
{
    double value=0;
    int signal = 1;
    DECLS;

    SKIPWHITE;
    value = atof(&bytes[position-1]);
    SKIPNONWHITE;
    if (c != -1) position--;
    return value;
    if (c == '-') {
        signal = -1;
        c = NEXTCHAR;
    }
    if (c < '0' || c > '9') {
        if (c != -1) position--;
        return 0;
    }
    while (c >= '0' && c <= '9') {
        value = value * 10 + c - '0';
        c = NEXTCHAR;
    }
    if (c == '.') {
        double m=.1;
        c = NEXTCHAR;
        while (c >= '0' && c <= '9') {
            value = value + (c - '0') * m;
            m /= 10;
            c = NEXTCHAR;
        }
    }
    if (c != -1) position--;
    return value*signal;
}

- (NSString *)readString
{
    char value[500];
    int bi=0;
    BOOL f=NO;
    DECLS;

    SKIPWHITE;
    if (c=='"') {
        f=YES;
        c = NEXTCHAR;
    }
    do {
        value[bi++] = c;
        c = NEXTCHAR;
    } while ((c != -1)
             && ((f && c!='"') || (!f && !(c==' ' || c=='\n' || c=='\t'))));
    if (f && (c == '"')) position++;
    if (c != -1) position--;
    return [NSString stringWithCString:value length:bi];
}

- (BOOL)isAtEnd
{
    DECLS;
    SKIPWHITE;
    if (c == -1) return YES;
    position--;
    return NO;
}
@end
