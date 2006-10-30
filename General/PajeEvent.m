/*
    Copyright (c) 1998-2005 Benhur Stein
    
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
/* PajeEvent.m
 *
 *
 * 20021112 BS creation (from A0Event)
 */

#include "PajeEvent.h"
#include "../General/NSUserDefaults+Additions.h"
#include "../General/NSColor+Additions.h"
#include "../General/UniqueString.h"
#include "../General/Protocols.h"
#include "../General/PajeType.h"
#include "../General/Macros.h"


// must follow PajeEventId definition
char *PajeEventNames[] = {
    "PajeStartTrace",
    "PajeDefineContainerType",
    "PajeDefineEventType",
    "PajeDefineStateType",
    "PajeDefineVariableType",
    "PajeDefineLinkType",
    "PajeDefineEntityValue",
    "PajeCreateContainer",
    "PajeDestroyContainer",
    "PajeNewEvent",
    "PajeSetState",
    "PajePushState",
    "PajePopState",
    "PajeSetVariable",
    "PajeAddVariable",
    "PajeSubVariable",
    "PajeStartLink",
    "PajeEndLink"
};

// must follow PajeFieldId definition
NSString *PajeFieldNames[] = {
    @"EventId",
    @"Time",
    @"Name",
    @"Alias",
    //"ContainerType",
    //"EntityType",
    @"Type",
    @"Container",
    @"StartContainerType",
    @"EndContainerType",
    @"StartContainer",
    @"EndContainer",
    @"Color",
    @"Value",
    @"Key",
    @"File",
    @"Line"
};
NSString *PajeOldFieldNames[] = {
    @"",
    @"",
    @"NewName", // Container
    @"NewType", // NewValue, NewContainer
    //"",
    //"Type",
    @"NewContainerType",
    @"",
    @"SourceContainerType",
    @"DestContainerType",
    @"SourceContainer",
    @"DestContainer",
    @"",
    @"",
    @"",
    @"FileName",
    @"LineNumber"
};

NSString *PajeOld1FieldNames[] = {
    @"",
    @"",
    @"", // Container
    @"NewValue", // NewContainer
    //"",
    //"",
    @"ContainerType",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @""
};

NSString *PajeOld2FieldNames[] = {
    @"",
    @"",
    @"", // Container
    @"NewContainer", // NewContainer
    //"",
    //"",
    @"EntityType",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @"",
    @""
};

NSArray *PajeExtraFieldNames;

PajeFieldId obligatoryFieldIds[][10] = {
    /*PajeStartTrace         */{ -1 },
    /*PajeDefineContainerType*/{ PajeNameFieldId, PajeTypeFieldId, -1 },
    /*PajeDefineEventType    */{ PajeNameFieldId, PajeTypeFieldId, -1 },
    /*PajeDefineStateType    */{ PajeNameFieldId, PajeTypeFieldId, -1 },
    /*PajeDefineVariableType */{ PajeNameFieldId, PajeTypeFieldId, -1 },
    /*PajeDefineLinkType     */{ PajeNameFieldId, PajeTypeFieldId, PajeStartContainerTypeFieldId, PajeEndContainerTypeFieldId, -1 },
    /*PajeDefineEntityValue  */{ PajeNameFieldId, PajeTypeFieldId, -1 },
    /*PajeCreateContainer    */{ PajeTimeFieldId, PajeNameFieldId, PajeTypeFieldId, PajeContainerFieldId, -1 },
    /*PajeDestroyContainer   */{ PajeTimeFieldId, PajeNameFieldId, PajeTypeFieldId, -1 },
    /*PajeNewEvent           */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajeSetState           */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajePushState          */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajePopState           */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajeSetVariable        */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajeAddVariable        */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajeSubVariable        */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, -1 },
    /*PajeStartLink          */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, PajeStartContainerFieldId, PajeKeyFieldId, -1 },
    /*PajeEndLink            */{ PajeTimeFieldId, PajeTypeFieldId, PajeContainerFieldId, PajeValueFieldId, PajeEndContainerFieldId, PajeKeyFieldId, -1 }
};

PajeFieldId optionalFieldIds[][5] = {
    /*PajeStartTrace         */{ -1 },
    /*PajeDefineContainerType*/{ PajeAliasFieldId, -1 },
    /*PajeDefineEventType    */{ PajeAliasFieldId, -1 },
    /*PajeDefineStateType    */{ PajeAliasFieldId, -1 },
    /*PajeDefineVariableType */{ PajeAliasFieldId, -1 },
    /*PajeDefineLinkType     */{ PajeAliasFieldId, -1 },
    /*PajeDefineEntityValue  */{ PajeAliasFieldId, PajeColorFieldId, -1 },
    /*PajeCreateContainer    */{ PajeAliasFieldId, -1 },
    /*PajeDestroyContainer   */{ -1 },
    /*PajeNewEvent           */{ PajeFileFieldId, PajeLineFieldId, -1 },
    /*PajeSetState           */{ PajeFileFieldId, PajeLineFieldId, -1 },
    /*PajePushState          */{ PajeFileFieldId, PajeLineFieldId, -1 },
    /*PajePopState           */{ PajeFileFieldId, PajeLineFieldId, -1 },
    /*PajeSetVariable        */{ -1 },
    /*PajeAddVariable        */{ -1 },
    /*PajeSubVariable        */{ -1 },
    /*PajeStartLink          */{ PajeFileFieldId, PajeLineFieldId, -1 },
    /*PajeEndLink            */{ PajeFileFieldId, PajeLineFieldId, -1 }
};

NSMutableArray *PajeUserFieldNames;

PajeEventId pajeEventIdFromName(const char *name)
{
    PajeEventId i;
    for (i = 0; i < PajeEventIdCount; i++) {
        if (strcmp(name, PajeEventNames[i]) == 0) {
            return i;
        }
    }
    return -1;
}

PajeFieldId pajeFieldIdFromName(const char *name)
{
    PajeEventId i;
    for (i = 0; i < PajeFieldIdCount; i++) {
        if (strcmp(name, [PajeFieldNames[i] cString]) == 0) {
            return i;
        }
    }
    for (i = 0; i < PajeFieldIdCount; i++) {
        if (strcmp(name, [PajeOldFieldNames[i] cString]) == 0
         || strcmp(name, [PajeOld1FieldNames[i] cString]) == 0
         || strcmp(name, [PajeOld2FieldNames[i] cString]) == 0) {
            return i;
        }
    }
    for (i = 0; i < [PajeUserFieldNames count]; i++) {
        if (strcmp(name, [[PajeUserFieldNames objectAtIndex:i] cString]) == 0) {
            return i + PajeFieldIdCount;
        }
    }
    [PajeUserFieldNames addObject:[NSString stringWithCString:name]];
    return i + PajeFieldIdCount;
}

NSString *pajeFieldNameFromId(PajeFieldId fieldId)
{
    if (fieldId < PajeFieldIdCount) {
        return PajeFieldNames[fieldId];
    } else {
        return [PajeUserFieldNames objectAtIndex:fieldId - PajeFieldIdCount];
    }
}


PajeFieldType pajeFieldTypeFromName(const char *name)
{
    if (strcmp(name, "int")    == 0) return PajeIntFieldType;
    if (strcmp(name, "hex")    == 0) return PajeHexFieldType;
    if (strcmp(name, "date")   == 0) return PajeDateFieldType;
    if (strcmp(name, "double") == 0) return PajeDoubleFieldType;
    if (strcmp(name, "string") == 0) return PajeStringFieldType;
    if (strcmp(name, "color")  == 0) return PajeColorFieldType;
    return -1;
}

@implementation PajeEventDefinition
+ (void)initialize
{
    PajeUserFieldNames = [[NSMutableArray alloc] init];
}

+ (PajeEventDefinition *)definitionWithPajeEventId:(PajeEventId)anId
                                        internalId:(const char *)internalId
{
    return [[[self alloc] initWithPajeEventId:anId
                                   internalId:internalId] autorelease];
}

- (id)initWithPajeEventId:(PajeEventId)anId
               internalId:(const char *)internalId
{
    self = [super init];
    if (self != nil) {
        eventId = strdup(internalId);
        pajeEventId = anId;
        fieldTypes[0] = PajeIntFieldType;
        fieldIds[0] = PajeEventIdFieldId;
        fieldCount = 1;
        extraFieldCount = 0;
        int i;
        for (i = 0; i < PajeFieldIdCount; i++) {
            fieldIndexes[i] = -1;
        }
        fieldIndexes[PajeEventIdFieldId] = 0;
    }
    return self;
}

- (void)dealloc
{
    free(eventId);
    [fieldNames release];
    [extraFieldNames release];
    [super dealloc];
}

- (int)indexForFieldId:(PajeFieldId)fieldId
{
    if (fieldId < PajeFieldIdCount) {
        return fieldIndexes[fieldId];
    } else {
        int i;
        for (i = 0; i < fieldCount; i++) {
            if (fieldIds[i] == fieldId) {
                return i;
            }
        }
        return -1;
    }
}

- (BOOL)isObligatoryOrOptionalFieldId:(PajeFieldId)aFieldId
{
    int i;
    PajeFieldId fieldId;
    for (i = 0; ; i++) {
        fieldId = obligatoryFieldIds[pajeEventId][i];
        if (fieldId == -1) break;
        if (fieldId == aFieldId) {
            return YES;
        }
    }
    for (i = 0; ; i++) {
        fieldId = optionalFieldIds[pajeEventId][i];
        if (fieldId == -1) break;
        if (fieldId == aFieldId) {
            return YES;
        }
    }
    return NO;
}

- (void)addFieldId:(PajeFieldId)fieldId
         fieldType:(PajeFieldType)fieldType
{
    if (fieldCount >= PE_MAX_NFIELDS) {
        NSLog(@"Too many fields in event definition '%s'.", eventId);
        return;
    }
    fieldTypes[fieldCount] = fieldType;
    fieldIds[fieldCount] = fieldId;
    if ([self indexForFieldId:fieldId] != -1) {
        NSLog(@"Repeated field named '%@' in event definition %s.",
                pajeFieldNameFromId(fieldId), eventId);
    } else if (fieldId < PajeEventIdCount) {
        fieldIndexes[fieldId] = fieldCount;
    }
    if (![self isObligatoryOrOptionalFieldId:fieldId]) {
        extraFieldIds[extraFieldCount++] = fieldId;
    }
    fieldCount++;
}

- (int)fieldCount
{
    return fieldCount;
}

- (NSArray *)fieldNames
{
    if (fieldNames == nil) {
        NSString *names[fieldCount];
        fieldNames = [NSMutableArray array];
        int i;
        for (i = 0; i < fieldCount; i++) {
            names[i] = pajeFieldNameFromId(fieldIds[i]);
        }
        fieldNames = [[NSArray alloc] initWithObjects:names count:fieldCount];
    }
    return fieldNames;
}

- (NSArray *)extraFieldNames
{
    if (extraFieldCount == 0) {
        return nil;
    }
    if (extraFieldNames == nil) {
        NSString *names[extraFieldCount];
        int i;
        for (i = 0; i < extraFieldCount; i++) {
            names[i] = pajeFieldNameFromId(extraFieldIds[i]);
        }
        extraFieldNames = [[NSArray alloc] initWithObjects:names
                                                     count:extraFieldCount];
    }
    return extraFieldNames;
}
@end

@implementation PajeEvent
+ (PajeEvent *)eventWithDefinition:(PajeEventDefinition *)definition
                              line:(line *)line
{
    return [[[self alloc] initWithDefinition:definition
                                        line:line] autorelease];
}

- (id)initWithDefinition:(PajeEventDefinition *)definition
                    line:(line *)line
{
    if (line->word_count != [definition fieldCount]) {
        NSLog(@"Field count (%d) does not match definition (%d)",
                        line->word_count, [definition fieldCount]);
        return nil;
    } 
    self = [super init];
    if (self != nil) {
        Assign(pajeEventDefinition, definition);
        valueLine = line;
    }
    return self;
}

- (PajeEventId)pajeEventId
{
    return pajeEventDefinition->pajeEventId;
}


- (id)valueForFieldId:(PajeFieldId)fieldId
{
    int fieldIndex;
    fieldIndex = [pajeEventDefinition indexForFieldId:fieldId];
    if (fieldIndex < 0) {
        return nil;
    }
    char *fieldValue;
    fieldValue = valueLine->word[fieldIndex];
    PajeFieldType fieldType;
    fieldType = pajeEventDefinition->fieldTypes[fieldIndex];
    switch (fieldType) {
    case PajeIntFieldType:
        return [NSNumber numberWithInt:atoi(fieldValue)];
    case PajeHexFieldType:
        return [NSNumber numberWithInt:strtol(fieldValue, (char **)NULL, 16)];
    case PajeDateFieldType:
        return [NSDate dateWithTimeIntervalSinceReferenceDate:atof(fieldValue)];
    case PajeDoubleFieldType:
        return [NSNumber numberWithDouble:atof(fieldValue)];
    case PajeStringFieldType:
        return [NSString stringWithCString:fieldValue];
    case PajeColorFieldType:
        return [NSColor colorFromString:[NSString stringWithCString:fieldValue]];
    default:
        return nil;
    }
}

- (const char *)cStringForFieldId:(PajeFieldId)fieldId
{
    int fieldIndex;
    fieldIndex = [pajeEventDefinition indexForFieldId:fieldId];
    if (fieldIndex < 0) {
        return NULL;
    }
    return valueLine->word[fieldIndex];
}

- (NSColor *)colorForFieldId:(PajeFieldId)fieldId
{
    const char *fieldValue;
    fieldValue = [self cStringForFieldId:fieldId];
    if (fieldValue == NULL) {
        return nil;
    }
    return [NSColor colorFromString:[NSString stringWithCString:fieldValue]];
}

- (NSString *)stringForFieldId:(PajeFieldId)fieldId
{
    const char *fieldValue;
    fieldValue = [self cStringForFieldId:fieldId];
    if (fieldValue == NULL) {
//NSLog(@"string %d %@:nil", fieldId, PajeFieldNames[fieldId]);
        return nil;
    }
//NSLog(@"string %d %@:%s", fieldId, PajeFieldNames[fieldId], fieldValue);
    return [NSString stringWithCString:fieldValue];
}

- (int)intForFieldId:(PajeFieldId)fieldId
{
    const char *fieldValue;
    fieldValue = [self cStringForFieldId:fieldId];
    if (fieldValue == NULL) {
        return 0;
    }
    return atoi(fieldValue);
}

- (double)doubleForFieldId:(PajeFieldId)fieldId
{
    const char *fieldValue;
    fieldValue = [self cStringForFieldId:fieldId];
    if (fieldValue == NULL) {
        return 0;
    }
    return atof(fieldValue);
}

- (NSDate *)timeForFieldId:(PajeFieldId)fieldId
{
    const char *fieldValue;
    fieldValue = [self cStringForFieldId:fieldId];
    if (fieldValue == NULL) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSinceReferenceDate:atof(fieldValue)];
}

- (NSDate *)time
{
    return [self timeForFieldId:PajeTimeFieldId];
}


- (NSString *)description
{
    // FIXME
    NSString *description;
    description = @"event [";
    int i;
    for (i = 0; i < valueLine->word_count; i ++) {
        description = [description stringByAppendingString:[NSString stringWithFormat:@"%s ", valueLine->word[i]]];
    }
    description = [description stringByAppendingString:@"]"];
    //description = [NSString stringWithFormat:@"event description not implemented [%s %s]", valueLine->word[0], valueLine->word[1]];
    return description;
}

- (NSArray *)fieldNames
{
    return [pajeEventDefinition fieldNames];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
{
    return [self valueForFieldId:pajeFieldIdFromName([fieldName cString])];
}

- (NSArray *)extraFieldValues
{
    NSMutableArray *fieldValues;
    if (pajeEventDefinition->extraFieldCount == 0) {
        return nil;
    }
    fieldValues = [NSMutableArray array];
    int i;
    for (i = 0; i < pajeEventDefinition->extraFieldCount; i++) {
        PajeFieldId fieldId;
        id fieldValue;
        fieldId = pajeEventDefinition->extraFieldIds[i];
        fieldValue = [self valueForFieldId:fieldId];
        [fieldValues addObject:fieldValue];
    }
    return fieldValues;
}

- (NSDictionary *)extraFields
{
    NSArray *fieldNames;
    NSArray *fieldValues;
    fieldNames = [pajeEventDefinition extraFieldNames];
    if (fieldNames == nil) {
        return nil;
    }
    fieldValues = [self extraFieldValues];
    return [NSDictionary dictionaryWithObjects:fieldValues forKeys:fieldNames];
}
@end
