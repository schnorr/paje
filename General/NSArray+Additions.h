/*
    Copyright (c) 2006 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
    59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
*/
#ifndef _NSArray_Additions_h_
#define _NSArray_Additions_h_

//
// NSArray+Additions
//
// a category with additions to NSArray
//
// Author: Edmar Pessoa Ara�jo Neto
//

#include <Foundation/NSArray.h>

@interface NSArray (PajeAdditions)

- (NSEnumerator *)objectEnumeratorWithRange:(NSRange)range;
- (NSEnumerator *)reverseObjectEnumeratorWithRange:(NSRange)range;

@end

#endif
