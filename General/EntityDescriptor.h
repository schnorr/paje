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
#ifndef _EntityDescriptor_h_
#define _EntityDescriptor_h_

// EntityDescriptor
//
// holds a small description of an entityType
//

#include <Foundation/Foundation.h>

#include "Protocols.h"
#include "Macros.h"


@interface EntityDescriptor : NSObject
{
    NSString *entityType;
    PajeDrawingType drawingType;
}

//
// Initialisation
//
+ (EntityDescriptor *)descriptorWithEntityType:(NSString *)type
                                   drawingType:(PajeDrawingType)drawType;
- (id)initWithEntityType:(NSString *)type
             drawingType:(PajeDrawingType)drawType;
- (void)dealloc;

//
// Accessors
//
- (NSString *)entityType;
- (PajeDrawingType)drawingType;

- (NSArray *)allNames;
@end

#endif