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
// BusyState

#include "BusyState.h"
#include <AppKit/AppKit.h>
#include "../General/UniqueString.h"

NSString *BusyStateEntityType;

@implementation BusyState

static NSMutableDictionary *colorDict;

+ (void)initialize
{
    if (self == [BusyState class]) {
        BusyStateEntityType = U(@"Activity State");
    }
}

+ (NSMutableDictionary *)colorDict
{
    if (!colorDict)
        colorDict = [[NSMutableDictionary alloc] init];
    return colorDict;
}

+ (BusyState *)stateWithStartTime:(NSDate *)start
                          endTime:(NSDate *)end
                        container:(PajeContainer *)cont
                  relatedEntities:(NSArray *)related
{
    return [[[self alloc] initWithStartTime:start
                                    endTime:end
                                  container:cont
                            relatedEntities:related] autorelease];
}

- (id)initWithStartTime:(NSDate *)start
                endTime:(NSDate *)end
              container:(PajeContainer *)cont
        relatedEntities:(NSArray *)related
{
    self = [super init];
    startTime = [start retain];
    endTime = [end retain];
    container = [cont retain];
    relatedEntities = [related retain];
    return self;
}

- (void)dealloc
{
    [startTime release];
    [endTime release];
    [container release];
    [relatedEntities release];
    [super dealloc];
}


+ (id)hierarchy {
    static id hier = nil;
    if (!hier)
        hier = [[NSArray alloc] initWithObjects:@"Node", nil];
    return hier;
}

- (id)container { return container; }

- (NSDate *)startTime  { return startTime; }
- (NSDate *)endTime    { return endTime;   }
+ (PajeDrawingType)drawingType { return PajeVariableDrawingType; } //PajeStateDrawingType; }
- (PajeDrawingType)drawingType { return PajeVariableDrawingType; } //PajeStateDrawingType; }
- (NSNumber *)value {
    return [NSNumber numberWithInt:[relatedEntities count]];
}
- (NSString *)entityType { return BusyStateEntityType;}
+ (NSString *)entityType { return BusyStateEntityType;}
+ (NSString *)name { return BusyStateEntityType;}
- (NSString *)name
{
    unsigned ct = [relatedEntities count];
    if (ct == 0) return @"Inactive";
    if (ct == 1) return @"1 active thread";
    return [NSString stringWithFormat:@"%d active threads", ct];
}

- (NSColor *)color
{
    int ct = [relatedEntities count];
    if (ct >= 10) return [NSColor redColor];
    return [[NSColor blueColor] blendedColorWithFraction:ct/10. ofColor:[NSColor redColor]];
    return [NSColor colorWithDeviceHue:.667 - ct/15. saturation:1.0 brightness:1.0 alpha:1.0];
}

- (NSArray *)relatedEntities { return relatedEntities; }

/*
- (void)inspect
{
    NSLog(@"%@ inspection:\nstartTime=%@\nendTime=%@\nrelatedEntities=%@",
          NSStringFromClass([self class]), startTime, endTime, relatedEntities);
}
*/
@end
