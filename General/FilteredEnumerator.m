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
/* FilteredEnumerator.m created by benhur on Sat 14-Jun-1997 */

#include "FilteredEnumerator.h"

@implementation FilteredEnumerator

+ (FilteredEnumerator *)enumeratorWithEnumerator:(NSEnumerator *)orgEnum
                                          filter:(id)f
                                        selector:(SEL)sel
                                         context:(id)c;
{
    return [[[self alloc] initWithEnumerator:orgEnum
                                      filter:f
                                    selector:sel
                                     context:c] autorelease];
}

- (id)initWithEnumerator:(NSEnumerator *)orgEnum
                  filter:(id)f
                selector:(SEL)sel
                 context:(id)c
{
    self = [super init];
    if (self) {
        originalEnumerator = [orgEnum retain];
        filter = [f retain];
        selector = sel;
        context = [c retain];
    }
    return self;
}

- (void)dealloc
{
    [originalEnumerator release];
    [filter release];
    [context release];
    [super dealloc];
}

- (id)nextObject
{
    id obj;
    while (YES) {
        obj = [originalEnumerator nextObject];
        if (obj == nil) break;
        obj = [filter performSelector:selector
                           withObject:obj
                           withObject:context];
        if (obj != nil) break;
    }
    return obj;
}
@end
