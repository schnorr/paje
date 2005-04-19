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
#include "PajeEventDecoder.h"
#include "../General/FoundationAdditions.h"
#include "../General/UniqueString.h"
#include "../General/NSUserDefaults+Colors.h"

@implementation PajeEventDecoder

static NSString *INT_VALUE = @"Int";
static NSString *HEX_VALUE = @"Hex";
static NSString *TIME_VALUE = @"Date";
static NSString *DOUBLE_VALUE = @"Double";
static NSString *STRING_VALUE = @"String";
static NSString *COLOR_VALUE = @"Color";

- (id)initWithController:(PajeTraceController *)c
{
    [super initWithController:c];

    status = OUT_DEF;
    eventBeingDefined.fieldTypes = [[NSMutableArray alloc] init];
    eventBeingDefined.fieldNames = [[NSMutableArray alloc] init];

    eventNames = [[NSMutableDictionary dictionary] retain];
    eventFieldTypes = [[NSMutableDictionary dictionary] retain];
    eventFieldNames = [[NSMutableDictionary dictionary] retain];
    scanner = nil;
    percent = [[NSCharacterSet characterSetWithCharactersInString:@"%"] retain];
    alphanum = [[NSMutableCharacterSet characterSetWithCharactersInString:
        @"%0123456789_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] retain];
//alphanumericCharacterSet];
//    [alphanum addCharactersInString:@"_"];
    delimiter = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];

    return self;
}

- (void)encodeCheckPointWithCoder:(NSCoder *)coder
{
    [coder encodeValuesOfObjCTypes:"ii", &eventCount, &lineCount];
    NSDebugMLLog(@"tim", @"encoded %d %d", eventCount, lineCount);
}

- (void)decodeCheckPointWithCoder:(NSCoder *)coder
{
    [coder decodeValuesOfObjCTypes:"ii", &eventCount, &lineCount];
    NSDebugMLLog(@"tim", @"decoded %d %d", eventCount, lineCount);
}

- (void)dealloc
{
    [eventBeingDefined.fieldTypes release];
    [eventBeingDefined.fieldNames release];

    [eventNames release];
    [eventFieldTypes release];
    [eventFieldNames release];
    [percent release];
    [alphanum release];
    [delimiter release];
    [scanner release];
    [super dealloc];
}

- (void)reset
{
    [eventNames removeAllObjects];
    [eventFieldTypes removeAllObjects];
    [eventFieldNames removeAllObjects];
    Assign(scanner, nil);
}

- (BOOL)readNextLine
{
    int c;
    if (scanner && ![scanner isAtEnd]) {
        do {
            c = [scanner readChar];
	} while (c != '\n' && ![scanner isAtEnd]);
        lineCount++;
        return ![scanner isAtEnd];
    }
    return NO;
}

- (void)raise:(NSString *)reason
{
    [self reset];
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
    if (![data isKindOfClass:[NSData class]]) {
        [self raise:@"Internal error: incorrect data type"];
    }
    
    Assign(scanner, [DataScanner scannerWithData:(NSData *)data]);
    
    do {
        if (status != EVENTS) {
            [self scanDefinitionLine];
        }
	if (status == EVENTS) {
            PajeEvent *event;
            event = [self readEvent];
            if (event != nil) {
                [self outputEntity:event];
            }
        }
    } while ([self readNextLine]);
    
    Assign(scanner, nil);
}

- (BOOL)readPercent
{
    int c = [scanner readChar];
    if (c == '%') {
        return YES;
    }
    [scanner setPosition:[scanner position] - 1];
    return NO;
}

- (void)scanDefinitionLine
{
    NSString *fieldName, *fieldType, *str;

    switch (status) {
    case OUT_DEF:
        if (![self readPercent]) {
            status = EVENTS;
            break;
        }

        str = [scanner readString];
        ASSIGN(eventBeingDefined.eventName, [scanner readString]);
        ASSIGN(eventBeingDefined.eventId, [scanner readIntNumber]);
        if (![str isEqualToString:@"EventDef"]
            || eventBeingDefined.eventName == nil
            || eventBeingDefined.eventId == nil) {
            [self raise:@"'EventDef name number' expected"];
        }

        [eventBeingDefined.fieldTypes removeAllObjects];
        [eventBeingDefined.fieldNames removeAllObjects];
        [eventBeingDefined.fieldNames addObject: @"PajeEventName"];
        status = IN_DEF;
        break;
    case IN_DEF:
        if (![self readPercent]) {
            [self raise:@"Line should start with a '%'"];
        }

        fieldName = [scanner readString];
        if (fieldName == nil) {
            [self raise:@"Incomplete line, missing field name"];
        }
        if ([fieldName isEqualToString:@"EndEventDef"]) {
            [eventNames setObject:U(eventBeingDefined.eventName)
                           forKey:eventBeingDefined.eventId];
            [eventFieldTypes setObject:[eventBeingDefined.fieldTypes copy]
                                forKey:eventBeingDefined.eventId];
            [eventFieldNames setObject:[eventBeingDefined.fieldNames copy]
                                forKey:eventBeingDefined.eventId];
            status = OUT_DEF;
            break;
        }

        fieldType = [scanner readString];
        if (fieldType == nil) {
            [self raise:@"Incomplete line, missing field type"];
        }

        if ([fieldType isEqualToString:@"int"])
            [eventBeingDefined.fieldTypes addObject:INT_VALUE];
        else if ([fieldType isEqualToString:@"hex"])
            [eventBeingDefined.fieldTypes addObject:HEX_VALUE];
        else if ([fieldType isEqualToString:@"double"])
            [eventBeingDefined.fieldTypes addObject:DOUBLE_VALUE];
        else if ([fieldType isEqualToString:@"date"])
            [eventBeingDefined.fieldTypes addObject:TIME_VALUE];
        else if ([fieldType isEqualToString:@"string"])
            [eventBeingDefined.fieldTypes addObject:STRING_VALUE];
        else if ([fieldType isEqualToString:@"color"])
            [eventBeingDefined.fieldTypes addObject:COLOR_VALUE];
        else
            [self raise:[NSString stringWithFormat:@"Unrecognised field type '%@'", fieldType]];

        [eventBeingDefined.fieldNames addObject:fieldName];
        break;
    default:
        [self raise:@"Internal error, invalid status"];
    }
}

- (PajeEvent *)readEvent
{
    NSNumber *eventId;
    NSString *eventName;
    static PajeEvent *event;
    NSEnumerator *fieldTypeEnum;
    NSString *type;
    NSNumber *aNumber;
    double aDouble;
    NSString *aString;
static double tt;
static NSDate *last = nil;
static n = 0;
if (last == nil) last = [NSDate new];
//if ((++n %1000)==0) { double t = [[NSDate date] timeIntervalSinceDate:last]; Assign(last, [NSDate date]); NSLog(@"%d %f/s t=%f e=%@", n, 1000/t, tt, event);}

    if (valArray == nil) {
        valArray = [NSMutableArray new];
    }

    eventId = [scanner readIntNumber];
    if (eventId == nil) {
        return nil;
    }
    
    eventName = [eventNames objectForKey:eventId];
    if (eventName == nil) {
        [self raise: @"Unrecognized event id"];
    }
    [valArray addObject:eventName];

    fieldTypeEnum = [[eventFieldTypes objectForKey:eventId] objectEnumerator];
    while ((type = [fieldTypeEnum nextObject]) != nil) {
        if (type == INT_VALUE) {
            aNumber = [scanner readIntNumber];
            [valArray addObject:aNumber];
        } else if (type == DOUBLE_VALUE) {
            aNumber = [scanner readDoubleNumber];
            [valArray addObject:aNumber];
        } else if (type == TIME_VALUE) {
            aDouble = [scanner readDouble];
tt=aDouble;
            [valArray addObject:[NSDate/*PTime*/ dateWithTimeIntervalSinceReferenceDate:aDouble]];
        } else if (type == HEX_VALUE || type == STRING_VALUE) {
            // string can be delimited by ""
            aString = [scanner readString];
            [valArray addObject:aString];
        } else if (type == COLOR_VALUE) {
            // string can be delimited by ""
            aString = [scanner readString];
            [valArray addObject:[NSColor colorFromString:aString]];
        } else
            [self raise: @"Unknown data type"];
    }

    event = [PajeEvent eventWithObjects:valArray
                                forKeys:[eventFieldNames objectForKey:eventId]];
    [valArray removeAllObjects];

    eventCount++;
    return event;
}

- (int)eventCount
{
    return eventCount;
}
@end
