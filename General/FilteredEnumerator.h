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
#ifndef _FilteredEnumerator_h_
#define _FilteredEnumerator_h_

/* FilteredEnumerator.h created by benhur on Sat 14-Jun-1997 */

#include <Foundation/Foundation.h>

@interface FilteredEnumerator : NSEnumerator
{
    NSEnumerator *originalEnumerator;
    id filter;
    SEL selector;
    id context;
}
+ (FilteredEnumerator *)enumeratorWithEnumerator:(NSEnumerator *)orgEnum
                                          filter:(id)f
                                        selector:(SEL)sel
                                         context:(id)c;
- (id)initWithEnumerator:(NSEnumerator *)orgEnum
                  filter:(id)f
                selector:(SEL)sel
                 context:(id)c;
- (void)dealloc;
- (id)nextObject;

@end

#endif
