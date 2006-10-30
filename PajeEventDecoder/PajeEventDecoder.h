/*
    Copyright (c) 1998, 1999, 2000, 2001, 2003, 2004 Benhur Stein
    
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
#ifndef _PajeEventDecoder_h_
#define _PajeEventDecoder_h_

#include <Foundation/Foundation.h>
#include "../General/PajeEvent.h"
#include "../General/PTime.h"
#include "../General/DataScanner.h"
#include "../General/PajeFilter.h"

@interface PajeEventDecoder: PajeComponent
{
    enum { OUT_DEF, IN_DEF, EVENTS } status;
    
    PajeEventDefinition *eventBeingDefined;
    NSMutableArray *valArray; /* used only while reading an event */
    
    int eventCount;
    int lineCount;

    NSMapTable *eventDefinitions;

    NSMutableArray *chunkInfo;
    unsigned currentChunk;
}

- (id)initWithController:(PajeTraceController *)c;
- (void)scanDefinitionLine:(line *)line;
- (PajeEvent *)scanEventLine:(line *)line;
- (void)raise:(NSString *)reason, ...;

- (int)eventCount;
@end

#endif
