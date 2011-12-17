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
// PajeContainer
//
// superclass for containers
//

#include "PajeContainer.h"
#include "Macros.h"
#include "UniqueString.h"
#include "PTime.h"

@implementation PajeContainer

+ (PajeContainer *)containerWithType:(id)type
                                name:(NSString *)n
                           container:(PajeContainer *)c
{
    return [[[self alloc] initWithType:type
                                  name:n
                             container:c] autorelease];
}

- (id)initWithType:(PajeEntityType *)type
              name:(NSString *)n
         container:(PajeContainer *)c
{
    self = [super initWithType:type
                          name:n
                     container:c];
    if (self) {
        Assign(subContainers, [NSMutableArray array]);
    }
    return self;
}

- (void)dealloc
{
    Assign(subContainers, nil);
    [super dealloc];
}

- (void)addSubContainer:(PajeContainer *)subcontainer
{
    [subContainers addObject:subcontainer];
}

- (NSArray *)subContainers
{
    return subContainers;
}
 
- (BOOL)isContainer
{
    return YES;
}

- (NSDate *)time
{
    return [NSDate/*PTime*/ dateWithTimeIntervalSinceReferenceDate:0.0];
}

- (NSDate *)endTime
{
    return [NSDate/*PTime*/ dateWithTimeIntervalSinceReferenceDate:200.0];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSString *)alias
{
    return nil;
}

- (NSEnumerator *)enumeratorOfEntitiesTyped:(PajeEntityType *)type
                                   fromTime:(NSDate *)start
                                     toTime:(NSDate *)end
{
    [self _subclassResponsibility:_cmd];
    return nil;
}

- (NSEnumerator *)enumeratorOfCompleteEntitiesTyped:(PajeEntityType *)type
                                           fromTime:(NSDate *)start
                                             toTime:(NSDate *)end
{
    [self _subclassResponsibility:_cmd];
    return nil;
}

// NSCoding protocol
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:subContainers];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    Assign(subContainers, [coder decodeObject]);
    return self;
}

- (double)minValueForEntityType:(PajeEntityType *)type
{
    return 0.0;
}

- (double)maxValueForEntityType:(PajeEntityType *)type
{
    return 0.0;
}


- (void)verifyMinMaxOfEntityType:(PajeEntityType *)type
                       withValue:(double)value
{
  return;
}
@end
