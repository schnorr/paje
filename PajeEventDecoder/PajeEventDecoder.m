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
#include "PajeEventDecoder.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"
#include "../General/NSUserDefaults+Additions.h"
#include "../General/NSColor+Additions.h"
#include "../General/Macros.h"
#include "../General/CStringCallBacks.h"

char *break_line(char *s, line *line)
{
    BOOL in_string = NO;
    BOOL in_word = NO;
    char *p;
    line->word_count = 0;

    for (p = s; *p != '\0'; p++) {
        if (*p == '\n') {
            *p = '\0';
            p++;
            break;
        }
        if (in_string) {
            if (*p == '"') {
                *p = '\0';
                in_string = NO;
            }
            continue;
        }
        if (*p == '#') {
            *p = '\0';
            while (YES) {
                p++;
                if (*p == '\n') {
                    p++;
                    break;
                } else if (*p == '\0') {
                    break;
                }
            }
            break;
        }
        if (in_word && isspace(*p)) {
            *p = '\0';
            in_word = NO;
            continue;
        }
        if (!in_word && !isspace(*p)) {
            if (*p == '"') {
                p++;
                in_string = YES;
            } else {
                in_word = YES;
            }
            if (line->word_count < PE_MAX_NFIELDS) {
                line->word[line->word_count] = p;
                line->word_count ++;
            }
            continue;
        }
    }
    return p;
}


@implementation PajeEventDecoder

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self != nil) {
        status = OUT_DEF;

        eventDefinitions = NSCreateMapTable(CStringMapKeyCallBacks,
                                            NSObjectMapValueCallBacks, 50);

        chunkInfo = [[NSMutableArray alloc] init];
        currentChunk = 0;
    }

    return self;
}

- (void)dealloc
{
    NSFreeMapTable(eventDefinitions);
    [chunkInfo release];
    [super dealloc];
}

- (void)startChunk:(int)chunkNumber
{
    if (chunkNumber != currentChunk) {
        if (chunkNumber >= [chunkInfo count]) {
            // cannot position in an unread place
            [self raise:@"Cannot start unknown chunk"];
        }

        NSArray *info;
        info = [chunkInfo objectAtIndex:chunkNumber];
        eventCount = [[info objectAtIndex:0] intValue];
        lineCount = [[info objectAtIndex:1] intValue];

        currentChunk = chunkNumber;
    } else {
        // let's register the first chunk position
        if ([chunkInfo count] == 0) {

            [chunkInfo addObject:[NSArray arrayWithObjects:
                [NSNumber numberWithInt:eventCount],
                [NSNumber numberWithInt:lineCount], nil]];

        }
    }
    if (status != EVENTS && chunkNumber+1 < [chunkInfo count]) {
        // attempt to reread a chunk with only definitions
        ignoringChunk = YES;
    } else {
        ignoringChunk = NO;
    }

    // keep the ball rolling (tell other components)
    [super startChunk:chunkNumber];
}

// The current chunk has ended.
- (void)endOfChunkLast:(BOOL)last
{
    if (!last) {
        currentChunk++;
        // if we're at the end of the known world, let's register its position
        if (currentChunk == [chunkInfo count]) {

            [chunkInfo addObject:[NSArray arrayWithObjects:
                [NSNumber numberWithInt:eventCount],
                [NSNumber numberWithInt:lineCount], nil]];

        }
    }
    [super endOfChunkLast:last];
}



- (void)raise:(NSString *)reason, ...
{
    va_list args;

    va_start(args, reason);
    [NSException raise:@"DecodeFileException" format:reason arguments:args];
    va_end(args);
    return;

    [[NSException exceptionWithName:@"DecodeFileException"
                             reason:reason
                           userInfo:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:eventCount], @"Event Number",
            nil]
        ] raise];
}

- (void)inputEntity:(id)data
{
    if (ignoringChunk) {
        return;
    }
    if (![data isKindOfClass:[NSData class]]) {
        [self raise:@"Internal error: incorrect data type"];
    }

    char *dataPointer;
    char *initDataPointer;
    int length;

    length = [data length];
    dataPointer = (char *)[data bytes];
    initDataPointer = dataPointer;

    line line;
    
    while ((dataPointer - initDataPointer) < length) {
        dataPointer = break_line(dataPointer, &line);
        if (line.word_count == 0) {
            continue;
        }
        if (status != EVENTS) {
            [self scanDefinitionLine:&line];
        }
	if (status == EVENTS) {
            PajeEvent *event;
            event = [self scanEventLine:&line];
            if (event != nil) {
                [self outputEntity:event];
            }
        }
    }
}

- (BOOL)canEndChunkBefore:(id)data
{
    if (ignoringChunk) {
        [self raise:@"SHOULD NOT BE IGNORING WHEN THIS METHOD IS CALLED!!!"];
        return YES;
    }
    if (![data isKindOfClass:[NSData class]]) {
        [self raise:@"Internal error: incorrect data type"];
    }

    char *dataPointer;
    char *initDataPointer;
    int length;

    length = [data length];
    dataPointer = (char *)[data bytes];
    initDataPointer = dataPointer;

    line line;
    BOOL result = NO;
    
    while ((dataPointer - initDataPointer) < length) {
        dataPointer = break_line(dataPointer, &line);
        if (line.word_count == 0) {
            continue;
        }
        if (status != EVENTS) {
            [self scanDefinitionLine:&line];
        }
	if (status == EVENTS) {
            PajeEvent *event;
            event = [self scanEventLine:&line];
            if (event != nil) {
                result = [super canEndChunkBefore:event];
            }
        }
    }
    return result;
}

- (void)scanDefinitionLine:(line *)line
{
    char *str;
    int n = 0;

    str = line->word[n++];

    switch (status) {
    case OUT_DEF:
        if (*str++ != '%') {
            status = EVENTS;
            break;
        }

        char *eventName;
        char *eventId;
        if (*str == '\0') {
            str = line->word[n++];
        }
        eventName = line->word[n++];
        eventId   = line->word[n++];
        if (n != line->word_count
            || strcmp(str, "EventDef") != 0) {
            [self raise:@"'EventDef <event name> <event id>' expected"];
        }

        if (NSMapGet(eventDefinitions, eventId) != nil) {
            [self raise:@"redefinition of event with id '%s'", eventId];
        }
        PajeEventId pajeEventId = pajeEventIdFromName(eventName);
        if (pajeEventId == PajeUnknownEventId) {
            //[self raise:@"unknown event name '%s'", eventName];
            NSLog(@"unknown event name '%s'", eventName);
            pajeEventId = 0;
        }
        eventBeingDefined = [PajeEventDefinition
                                definitionWithPajeEventId:pajeEventId
                                               internalId:eventId];
        NSMapInsert(eventDefinitions, strdup(eventId), eventBeingDefined);
        status = IN_DEF;
        break;
    case IN_DEF:
        if (*str++ != '%') {
            [self raise:@"Line should start with a '%%'"];
        }

        char *fieldName;
        char *fieldType;
        if (*str == '\0') {
            str = line->word[n++];
        }
        fieldName = str;

        if (n > line->word_count) {
            [self raise:@"Incomplete line, missing field name"];
        }
        if (strcmp(fieldName, "EndEventDef") == 0) {
            // TODO: verify if all obligatory fields are defined
            status = OUT_DEF;
            break;
        }

        PajeFieldId fieldId;
        fieldId = pajeFieldIdFromName(fieldName);

        if (n >= line->word_count) {
            [self raise:@"Incomplete line, missing field type"];
        }
        fieldType = line->word[n++];

        PajeFieldType fieldTypeId;
        fieldTypeId = pajeFieldTypeFromName(fieldType);
        if (fieldTypeId < 0) {
            [self raise:@"Unrecognised field type '%s'", fieldType];
        }
        [eventBeingDefined addFieldId:fieldId fieldType:fieldTypeId];
        break;
    default:
        [self raise:@"Internal error, invalid status"];
    }
}

- (PajeEvent *)scanEventLine:(line *)line
{
    char *eventId;
    PajeEvent *event;
    PajeEventDefinition *eventDefinition;

    eventId = line->word[0];
    if (*eventId == '%') {
        return nil;
    }
    eventDefinition = NSMapGet(eventDefinitions, eventId);
    if (eventDefinition == nil) {
        [self raise:@"Event with id '%s' has not been defined", eventId];
    }
    
    event = [PajeEvent eventWithDefinition:eventDefinition line:line];

    eventCount++;
    return event;
}

- (int)eventCount
{
    return eventCount;
}
@end
