/*
    Copyright (c) 2006 Benhur Stein
    
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
#ifndef _UserValue_h_
#define _UserValue_h_

//
// UserValue
//
// holds a user-definable value
//

#include "../General/PajeEvent.h"
#include "../General/PajeEntity.h"
#include "../General/PajeEntityInspector.h"
#include "../General/PajeType.h"


@interface UserValue : PajeEntity
{
    double value;
    NSDate *startTime;
    NSDate *endTime;
}

+ (UserValue *)valueWithType:(PajeEntityType *)type
                 doubleValue:(double)v
                   container:(PajeContainer *)c
                   startTime:(NSDate *)t1
                     endTime:(NSDate *)t2;
- (id)initWithType:(PajeEntityType *)type
       doubleValue:(double)v
         container:(PajeContainer *)c
         startTime:(NSDate *)t1
           endTime:(NSDate *)t2;
- (void)dealloc;

- (void)setEndTime:(NSDate *)time;
@end

#endif
