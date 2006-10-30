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
#ifndef _PajeEvent_h_
#define _PajeEvent_h_

/* PajeEvent.h
 *
 *
 * 20021112 BS creation (from A0Event)
 */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "../General/Protocols.h"

#define PE_MAX_NFIELDS 20

typedef struct {
    char *word[PE_MAX_NFIELDS];
    int word_count;
} line;


typedef enum {
    PajeStartTraceEventId,
    PajeDefineContainerTypeEventId,
    PajeDefineEventTypeEventId,
    PajeDefineStateTypeEventId,
    PajeDefineVariableTypeEventId,
    PajeDefineLinkTypeEventId,
    PajeDefineEntityValueEventId,
    PajeCreateContainerEventId,
    PajeDestroyContainerEventId,
    PajeNewEventEventId,
    PajeSetStateEventId,
    PajePushStateEventId,
    PajePopStateEventId,
    PajeSetVariableEventId,
    PajeAddVariableEventId,
    PajeSubVariableEventId,
    PajeStartLinkEventId,
    PajeEndLinkEventId,
    PajeEventIdCount,
    PajeUnknownEventId = -1
} PajeEventId;

typedef enum {
    PajeIntFieldType,
    PajeHexFieldType,
    PajeDateFieldType,
    PajeDoubleFieldType,
    PajeStringFieldType,
    PajeColorFieldType
} PajeFieldType;
    
typedef enum {
    PajeEventIdFieldId,
    PajeTimeFieldId,
    PajeNameFieldId,
    PajeAliasFieldId,
    //PajeContainerTypeFieldId,
    //PajeEntityTypeFieldId,
    PajeTypeFieldId,
    PajeContainerFieldId,
    PajeStartContainerTypeFieldId,
    PajeEndContainerTypeFieldId,
    PajeStartContainerFieldId,
    PajeEndContainerFieldId,
    PajeColorFieldId,
    PajeValueFieldId,
    PajeKeyFieldId,
    PajeFileFieldId,
    PajeLineFieldId,
    PajeFieldIdCount
} PajeFieldId;

PajeEventId pajeEventIdFromName(const char *name);
PajeFieldId pajeFieldIdFromName(const char *name);
PajeFieldType pajeFieldTypeFromName(const char *name);

@interface PajeEventDefinition : NSObject
{
@public
    char *eventId;
    PajeEventId pajeEventId;
    PajeFieldType fieldTypes[PE_MAX_NFIELDS]; // fieldType of each field
    PajeFieldId fieldIds[PE_MAX_NFIELDS];     // fieldId of each field
    short fieldCount; // number of fields for events with this definition
    NSArray *fieldNames;
    short fieldIndexes[PajeFieldIdCount]; // index in fieldIds for known PjFiId
    PajeFieldId extraFieldIds[PE_MAX_NFIELDS]; // non-obligatory fieldIds in ev
    short extraFieldCount;
    NSArray *extraFieldNames;
}

+ (PajeEventDefinition *)definitionWithPajeEventId:(PajeEventId)anId
                                        internalId:(const char *)internalId;
- (id)initWithPajeEventId:(PajeEventId)anId
               internalId:(const char *)internalId;

- (void)addFieldId:(PajeFieldId)fieldId
         fieldType:(PajeFieldType)fieldType;

- (int)fieldCount;
@end

@interface PajeEvent : NSObject
{
    //char *fieldValues[PE_MAX_NFIELDS];
    line *valueLine;
    PajeEventDefinition *pajeEventDefinition;
}

+ (PajeEvent *)eventWithDefinition:(PajeEventDefinition *)definition
                              line:(line *)line;
- (id)initWithDefinition:(PajeEventDefinition *)definition
                    line:(line *)line;

- (id)valueForFieldId:(PajeFieldId)fieldId;
- (NSColor *)colorForFieldId:(PajeFieldId)fieldId;
- (NSString *)stringForFieldId:(PajeFieldId)fieldId;
- (const char *)cStringForFieldId:(PajeFieldId)fieldId;
- (int)intForFieldId:(PajeFieldId)fieldId;
- (double)doubleForFieldId:(PajeFieldId)fieldId;
- (NSDate *)timeForFieldId:(PajeFieldId)fieldId;
- (NSDate *)time;

- (PajeEventId)pajeEventId;

- (NSArray *)fieldNames;
- (id)valueOfFieldNamed:(NSString *)fieldName;

- (NSDictionary *)extraFields;
@end

#endif
