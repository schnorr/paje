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
#include "EntityDescriptor.h"

@implementation EntityDescriptor : NSObject

//
// Initialisation
//

+ (EntityDescriptor *)descriptorWithEntityType:(NSString *)type
                                   drawingType:(PajeDrawingType)drawType
{
    return [[[self alloc] initWithEntityType:type
                                 drawingType:drawType] autorelease];
}

- (id)initWithEntityType:(NSString *)type
             drawingType:(PajeDrawingType)drawType
{
    self = [super init];
    if (self) {
        Assign(entityType, type);
        drawingType = drawType;
    }
    return self;
}

- (void)dealloc
{
    Assign(entityType, nil);
    [super dealloc];
}


//
// Accessors
//

- (NSString *)entityType { return entityType; }
- (PajeDrawingType)drawingType { return drawingType; }

- (NSArray *)allValues
{
    return nil;
}
@end
