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

#include "ReduceEntityInspector.h"

@implementation ReduceEntityInspector
- (void)addLocalFields
{
    NSString *lastFieldName;
    NSString *lastProgramName;

    [super addLocalFields];

    if ([[inspectedEntity relatedEntities] count] < 1)
        return;

    if (![NSBundle loadNibNamed:@"ReduceEntityInspector" owner:self]) {
        NSRunAlertPanel(@"ReduceEntityInspector",
                        @"Cannot load interface file ReduceEntityInspector",
                        nil, nil, nil);
        return;
    }
    
    [executeForm setAutosizesCells:YES];
    fieldNameField = [executeForm cellAtIndex:0];
    programPathField = [executeForm cellAtIndex:0];
    NSLog(@"distances: %@", NSStringFromSize([executeBox contentViewMargins]));

    lastFieldName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReduceEntityInspector FieldName"];
    if (lastFieldName == nil) {
        lastFieldName = @"";
    }
    [fieldNameField setStringValue:lastFieldName];

    lastProgramName = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReduceEntityInspector ProgramPath"];
    if (lastProgramName == nil) {
        lastProgramName = @"";
    }
    [programPathField setStringValue:lastProgramName];

    [self addSubview:executeBox atBottom:NO];
}

- (IBAction)executeTask:(id)sender
{
    NSArray *relatedEntities;
    NSEnumerator *relatedEntitiesEnum;
    PajeEntity *entity;
    NSMutableArray *arguments;
    NSString *fieldName;
    NSString *programPath;
    NSTask *task;

    relatedEntities = [inspectedEntity relatedEntities];
    if ([relatedEntities count] < 1) {
        NSBeep();
        return;
    }

    fieldName = [fieldNameField stringValue];
    if ((fieldName == nil) || ([fieldName isEqual:@""])) {
        NSRunAlertPanel(@"ReduceEntityInspector",
                        @"Field name not defined!", nil, nil, nil);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:fieldName
                                              forKey:@"ReduceEntityInspector FieldName"];

    programPath = [programPathField stringValue];
    if ((programPath == nil) || ([programPath isEqual:@""])) {
        NSRunAlertPanel(@"ReduceEntityInspector",
                        @"Program path not defined!", nil, nil, nil);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:programPath
                                              forKey:@"ReduceEntityInspector ProgramPath"];

    if (![[NSFileManager defaultManager] isExecutableFileAtPath:programPath]) {
        NSRunAlertPanel(@"ReduceEntityInspector",
                        @"File %@ does not exist or is not executable!",
                        nil, nil, nil, programPath);
        return;
    }

    arguments = [NSMutableArray array];
    relatedEntitiesEnum = [relatedEntities objectEnumerator];
    while ((entity = [relatedEntitiesEnum nextObject]) != nil) {
        id argument;
        argument = [[entity valueOfFieldNamed:fieldName] description];
        if (argument == nil)
            argument = @"--nil--";
        [arguments addObject:argument];
    }
    
    task = [NSTask launchedTaskWithLaunchPath:programPath arguments:arguments];
}
@end
