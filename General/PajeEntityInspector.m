/*
    Copyright (c) 1998--2005 Benhur Stein
    
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
#include "PajeEntityInspector.h"
#include "SourceCodeReference.h"
#include "SourceTextController.h"
#include "PajeType.h"
#include "Macros.h"

#define SUBVIEW_SEPARATION 2
#define BOTTOM_MARGIN 10


@implementation PajeEntityInspector

static NSMutableArray *allInstances;

+ (PajeEntityInspector *)inspector
{
    NSEnumerator *instEnum;
    PajeEntityInspector *inspector;
    if (allInstances == nil) {
        allInstances = [[NSMutableArray alloc] init];
    }
    instEnum = [allInstances objectEnumerator];
    while ((inspector = [instEnum nextObject]) != nil) {
        if ([inspector isReusable]) {
            return inspector;
        }
    }
    inspector = [[self alloc] init];
    [allInstances addObject:inspector];
    [inspector release];
    return inspector;
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([notification object] == inspectionWindow) {
        [allInstances removeObjectIdenticalTo:self];
    }
}

- (id)init
{
    Class class = [self class];
    BOOL loaded = NO;
    NSDictionary *nameTable = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self, @"NSOwner", nil];

    while (!loaded && (class != [class superclass])) {
        NSBundle *bundle = [NSBundle bundleForClass:class];
        NSString *filename = @"PajeEntityInspector";
        loaded = [bundle loadNibFile:filename
	    	   externalNameTable:nameTable
		            withZone:[self zone]];
        class = [class superclass];
    }
    if (!loaded) {
        NSRunAlertPanel(@"Can't find file",
                        @"Interface description file '%@' not found",
                        nil, nil, nil, @"PajeEntityInspector");
        [self release];
        return nil;
    }

    [[showFileButton retain] removeFromSuperview];
    archivedTitleField = [NSArchiver archivedDataWithRootObject:titleField];
    archivedValueField = [NSArchiver archivedDataWithRootObject:valueField];
    [archivedTitleField retain];
    [archivedValueField retain];
    [titleField removeFromSuperview];
    [valueField removeFromSuperview];
    [fieldBox setContentViewMargins:NSMakeSize(2, 2)];
    archivedBox= [[NSArchiver archivedDataWithRootObject:fieldBox] retain];
    [fieldBox removeFromSuperview];

    [relatedEntitiesBox retain];
    [relatedEntitiesBox setContentViewMargins:NSMakeSize(2, 2)];
    [relatedEntitiesBox removeFromSuperview];

    [nameField retain];
    [colorField retain];
    [reuseButton retain];
    [filterButton retain];

    return self;
}

- (void)dealloc
{
    Assign(inspectedEntity, nil);

    Assign(relatedEntitiesBox, nil);
    Assign(archivedBox, nil);
    Assign(archivedTitleField, nil);
    Assign(archivedValueField, nil);

    Assign(nameField, nil);
    Assign(colorField, nil);
    Assign(reuseButton, nil);
    Assign(filterButton, nil);

    [super dealloc];
}

- (void)reset
{
    // remove everything from the panel
    [[[inspectionWindow contentView] subviews]
            makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // add the top widgets
    [[inspectionWindow contentView] addSubview:nameField];
    [[inspectionWindow contentView] addSubview:colorField];
    [[inspectionWindow contentView] addSubview:reuseButton];
    [[inspectionWindow contentView] addSubview:filterButton];

    // initialize bounding box
    boundingBox = NSUnionRect([colorField frame], [nameField frame]);
}

- (void)addSubview:(NSView *)view
{
    NSRect frame;

    if (view == nil) {
        return;
    }

    // add view bellow other views
    frame = [view frame];
    frame.origin.y = NSMinY(boundingBox) - NSHeight(frame) - SUBVIEW_SEPARATION;
    frame.origin.x = NSMinX(boundingBox);
    frame.size.width = NSWidth(boundingBox);
    [view setFrame:frame];
    [[inspectionWindow contentView] addSubview:view];

    // update bounding box to reflect new view
    boundingBox = NSUnionRect(boundingBox, frame);
}

- (void)addLastSubview:(NSView *)view
{
    NSRect frame;

    if (view == nil)
        return;

    // the last view can autosize if window changes size. resize window
    // before adding it, if necessary
    frame = [view frame];
    int dif = NSMinY(boundingBox) - SUBVIEW_SEPARATION
            - NSHeight(frame) - BOTTOM_MARGIN;
    if (dif != 0) {
        NSSize windowSize = [inspectionWindow frame].size;
        windowSize.height -= dif;
        [inspectionWindow setContentSize:windowSize];
    }

    // bottom is now at window margin
    frame.origin.y = BOTTOM_MARGIN;
    frame.origin.x = NSMinX(boundingBox);
    frame.size.width = NSWidth(boundingBox);

    // the size of the window may have changed -- boundingBox is no longer valid
    boundingBox = NSUnionRect([colorField frame], frame);

    [view setFrame:frame];
    [[inspectionWindow contentView] addSubview:view];
}

- (IBAction)filterEntityName:(id)sender
{
    PajeEntityType *entityType;
    id entityName;

    entityType = [inspectedEntity entityType];
    entityName = [inspectedEntity name];
    if (entityType != nil && entityName != nil) {
        NSString *filtering;
        NSDictionary *userInfo;
        filtering = [sender state] ? @"YES" : @"NO";
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         entityType, @"EntityType",
                                         entityName, @"EntityName",
                                         filtering, @"Show",
                                         nil];
        [[NSNotificationCenter defaultCenter]
                postNotificationName:@"PajeFilterEntityNameNotification"
                              object:self
                            userInfo:userInfo];
    }
}

- (NSBox *)boxWithTitle:(NSString *)boxTitle
            fieldTitles:(NSArray *)titles
            fieldValues:(NSArray *)values
{
    NSBox *box;
    int index;
    float curY = 0;
    float titleWidth = 0;
    NSTextField *field1;

    NSAssert([titles count] == [values count],
             @"count of fields and values do not match");
    
    // I don't know a better way of copying a box...
    box = [NSUnarchiver unarchiveObjectWithData:archivedBox];
    field1 = [NSUnarchiver unarchiveObjectWithData:archivedTitleField];

    [box setTitle:boxTitle];

    for (index = 0; index < [titles count]; index++) {
        float w;
        NSString *title = [[titles objectAtIndex:index] description];
        [field1 setStringValue:title];
        w = [[field1 cell] cellSize].width;
        if (w > titleWidth) titleWidth = w;
    }
    for (index = [titles count] - 1; index >= 0; index--) {
        float height;
        NSString *title = [[titles objectAtIndex:index] description];
        NSString *value = [[values objectAtIndex:index] description];
        NSTextField *tField;
        NSTextField *vField;
        
        tField = [NSUnarchiver unarchiveObjectWithData:archivedTitleField];
        vField = [NSUnarchiver unarchiveObjectWithData:archivedValueField];
        
        [tField setStringValue:title];
        [vField setStringValue:value];
        
        height = MAX([[tField cell] cellSize].height,
                     [[vField cell] cellSize].height);
        
        [tField setFrame:NSMakeRect(0, curY, titleWidth, height)];
        [vField setFrame:NSMakeRect(titleWidth + 2, curY, 10, height)];
        [box addSubview:tField];
        [box addSubview:vField];
        
        curY += height+2;
    }
    [box sizeToFit];

    return box;
}

- (void)addSourceReference
{
    SourceCodeReference *sourceRef;
    NSBox *box;
    NSArray *values;
    NSRect buttonFrame;
    NSRect contentFrame;
    
    // source code reference
    sourceRef = [filter valueOfFieldNamed:@"FileReference"
                                forEntity:inspectedEntity];
    if (sourceRef == nil) {
        return;
    }

    values = [NSArray arrayWithObjects:
            [sourceRef filename],
            [NSString stringWithFormat:@"%d", [sourceRef lineNumber]],
            nil];
    
    box = [self boxWithTitle:@"Source File"
            fieldTitles:[NSArray arrayWithObjects:@"File", @"Line", nil]
            fieldValues:values];
    [box sizeToFit];
            
    contentFrame = [[box contentView] frame];
    [showFileButton sizeToFit];
    buttonFrame = [showFileButton frame];
    [showFileButton setFrame:NSMakeRect(NSMaxX(contentFrame) + 2,
                                        0,
                                        NSWidth(buttonFrame),
                                        NSHeight(contentFrame))];
    [box addSubview:showFileButton];
    [box sizeToFit];

    [self addSubview:box];
}


- (NSBox *)boxWithTitle:(NSString *)boxTitle
           fieldObjects:(NSArray *)objects
            fieldTitles:(NSArray *)titles
            fieldValues:(NSArray *)values
{
    return [self boxWithTitle:boxTitle
                  fieldTitles:titles
                  fieldValues:values];
}

- (NSBox *)boxWithTitle:(NSString *)boxTitle
            fieldTitles:(NSArray *)titles
             fieldNames:(NSArray *)names
{
    NSString *fieldName;
    NSEnumerator *fieldNameEnum = [names objectEnumerator];
    NSMutableArray *fieldValues = [NSMutableArray array];

    while ((fieldName = [fieldNameEnum nextObject]) != nil) {
        id fieldValue = [inspectedEntity valueOfFieldNamed:fieldName];
        if (fieldValue == nil) fieldValue = @"";
        [fieldValues addObject:[fieldValue description]];
        [nonDisplayedFields removeObject:fieldName];
    }
    return [self boxWithTitle:boxTitle
                  fieldTitles:titles
                  fieldValues:fieldValues];
}

- (void)addBoxForContainer:(PajeContainer *)container
             upToContainer:(PajeContainer *)upto
                 withTitle:(NSString *)title
{
    NSBox *box;
    NSMutableArray *fieldTitles;
    NSMutableArray *fieldValues;
    NSMutableArray *fieldObjects;
    
    if (container == nil) {
        return;
    }

    fieldTitles = [NSMutableArray array];
    fieldValues = [NSMutableArray array];
    fieldObjects = [NSMutableArray array];
    while ([container container] != nil && ![container isEqual:upto]) {
        [fieldTitles insertObject:[[container entityType] name] atIndex:0];
        [fieldValues insertObject:[container name] atIndex:0];
        [fieldObjects insertObject:container atIndex:0];
        container = [container container];
    }

    box = [self boxWithTitle:title
                fieldObjects:fieldObjects
                 fieldTitles:fieldTitles
                 fieldValues:fieldValues];
    [self addSubview:box];
}

- (void)addLocalFields
{
    PajeContainer *container;
    PajeContainer *sourceContainer;
    PajeContainer *destContainer;
    NSBox *box;
    NSMutableArray *fieldTitles;
    NSMutableArray *fieldValues;
    NSDate *startTime;
    NSDate *endTime;
    double duration;
    double exclusiveDuration;
    id startLogical;
    id endLogical;

    // container information
    container = [inspectedEntity container];
    [self addBoxForContainer:container
               upToContainer:nil
                   withTitle:@"Container"];
    [nonDisplayedFields removeObject:@"Container"];

    sourceContainer = [inspectedEntity valueOfFieldNamed:@"SourceContainer"];
    if (sourceContainer != nil) {
        [self addBoxForContainer:sourceContainer
                   upToContainer:container
                       withTitle:@"Source Container"];
        [nonDisplayedFields removeObject:@"SourceContainer"];
    }
    destContainer = [inspectedEntity valueOfFieldNamed:@"DestContainer"];
    if (destContainer != nil) {
        [self addBoxForContainer:destContainer
                   upToContainer:container
                       withTitle:@"Dest Container"];
        [nonDisplayedFields removeObject:@"DestContainer"];
    }

    // timing information
    fieldTitles = [NSMutableArray array];
    fieldValues = [NSMutableArray array];
    startTime = [inspectedEntity startTime];
    endTime = [inspectedEntity endTime];
    duration = [inspectedEntity duration];
    if (duration == 0) {
        [fieldTitles addObject:@"Time"];
        [fieldValues addObject:[startTime description]];
    } else {
        [fieldTitles addObject:@"Start Time"];
        [fieldValues addObject:[startTime description]];
        [fieldTitles addObject:@"End Time"];
        [fieldValues addObject:[endTime description]];
        [fieldTitles addObject:@"Duration"];
        [fieldValues addObject:[NSString stringWithFormat:@"%.6f", duration]];
    }
    exclusiveDuration = [inspectedEntity exclusiveDuration];
    NSLog(@"inspected %@ dur=%f excl=%f", inspectedEntity, duration, exclusiveDuration);
    if (exclusiveDuration != duration) {
        [fieldTitles addObject:@"Exclusive Duration"];
        [fieldValues addObject:[NSString stringWithFormat:@"%.6f",
                                         exclusiveDuration]];
    }
    startLogical = [inspectedEntity valueOfFieldNamed:@"StartLogical"];
    if (startLogical != nil) {
        [fieldTitles addObject:@"Start Logical"];
        [fieldValues addObject:[startLogical description]];
        [nonDisplayedFields removeObject:@"StartLogical"];
    }
    endLogical = [inspectedEntity valueOfFieldNamed:@"EndLogical"];
    if (endLogical != nil) {
        [fieldTitles addObject:@"End Logical"];
        [fieldValues addObject:[endLogical description]];
        [nonDisplayedFields removeObject:@"EndLogical"];
    }

    [nonDisplayedFields removeObject:@"Time"];
    [nonDisplayedFields removeObject:@"StartTime"];
    [nonDisplayedFields removeObject:@"EndTime"];
    [nonDisplayedFields removeObject:@"Duration"];
    [nonDisplayedFields removeObject:@"Exclusive Duration"];
    
    box = [self boxWithTitle:@"Timing"
                 fieldTitles:fieldTitles
                 fieldValues:fieldValues];
    [self addSubview:box];
}

- (void)addGlobalFields
{
    // global fields
    [nameField setStringValue:[filter nameForEntity:inspectedEntity]];
    [colorField setColor:[filter colorForEntity:inspectedEntity]];
    [colorField setAction:@selector(colorChanged:)];
    [colorField setTarget:self];
    [inspectionWindow setTitle:[filter descriptionForEntityType:
                                 [filter entityTypeForEntity:inspectedEntity]]];

    [nonDisplayedFields removeObject:@"PajeEventName"];
    [nonDisplayedFields removeObject:@"Name"];
    [nonDisplayedFields removeObject:@"Color"];

    [nonDisplayedFields removeObject:@"EntityType"];
    [nonDisplayedFields removeObject:@"Value"];
}

- (void)addOtherFields
{
    // other fields
    if ([nonDisplayedFields count] > 0) {
        NSBox *box;
        NSArray *fieldTitles = [nonDisplayedFields allObjects];

        box = [self boxWithTitle:@"Other values"
                     fieldTitles:fieldTitles
                      fieldNames:fieldTitles];
        [self addSubview:box];
    }
}

- (BOOL)isReusable
{
    return [reuseButton state];
}

- (void)setReusable:(BOOL)reuse
{
    [reuseButton setState:reuse];
}

- (IBAction)entityClicked:(id)sender
{
    if ([sender isKindOfClass:[NSMatrix class]]) {
        sender = [sender selectedCell];
    }
    [self inspectEntity:[sender representedObject] withFilter:filter];
}

- (IBAction)colorChanged:(id)sender
{
    [filter setColor:[sender color] forEntity:inspectedEntity];
}

- (void)addScriptBox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [scriptPathField setStringValue:
            [defaults objectForKey:@"EntityInspectorScriptPath"]];
    [scriptFieldNameField setStringValue:
            [defaults objectForKey:@"EntityInspectorScriptFieldName"]];

    if ([[filter relatedEntitiesForEntity:inspectedEntity] count] == 0) {
        [scriptFieldSourceMatrix selectCellWithTag:0];
    }

    [[scriptBox retain] autorelease];
    [scriptBox removeFromSuperview];
    [self addSubview:scriptBox];
}

- (void)addRelatedEntities
{
    NSArray *relatedEntities;

    relatedEntities = [filter relatedEntitiesForEntity:inspectedEntity];
    if ([relatedEntities count] > 0) {
        NSEnumerator *relatedEnum;
        int row;
        PajeEntity *related;

        [relatedEntitiesMatrix renewRows:[relatedEntities count] columns:1];
        row = 0;
        relatedEnum = [relatedEntities objectEnumerator];
        while ((related = [relatedEnum nextObject]) != nil) {
            NSButtonCell *cell;
            cell = [relatedEntitiesMatrix cellAtRow:row++ column:0];
            [cell setTitle:[filter nameForEntity:related]];
            [cell setRepresentedObject:related];
            [cell setTarget:self];
            [cell setAction:@selector(entityClicked:)];
        }
        [relatedEntitiesMatrix sizeToCells];
        NSScrollView *sv = [relatedEntitiesMatrix enclosingScrollView];
        NSSize svSize = [sv frame].size;
        svSize.height = MIN(NSHeight([relatedEntitiesMatrix frame]) + 1, 105);
        [sv setFrameSize:svSize];
        [relatedEntitiesBox sizeToFit];
        [self addLastSubview:relatedEntitiesBox];
    }
}


- (void)inspectEntity:(id<PajeEntity>)entity
           withFilter:(PajeFilter *)f
{
    Assign(inspectedEntity, entity);
    Assign(filter, f);

    nonDisplayedFields = [[NSMutableSet alloc]
            initWithArray:[filter fieldNamesForEntity:entity]];

    [self reset];

    [self addGlobalFields];
    [self addLocalFields];

    [nonDisplayedFields removeObject:@"RelatedEntities"];
    [nonDisplayedFields removeObject:@"FileReference"];

    [self addOtherFields];

    [self addSourceReference];

    // script execution
    [self addScriptBox];

    // Related entities
    [self addRelatedEntities];
    
    int dif = NSMinY(boundingBox) - 10;
    if (dif != 0) {
        NSRect frame = [inspectionWindow frame];
        frame.origin.y += dif;
        frame.size.height -= dif;
        [inspectionWindow setContentSize:frame.size];
    }
    
    Assign(nonDisplayedFields, nil);

//    lastWindowPosition = [inspectionWindow cascadeTopLeftFromPoint:lastWindowPosition];
//    [inspectionWindow display];
    [inspectionWindow orderFront:self];
}

- (void)showSource:(id)sender
{
    SourceCodeReference *FileReference;
    NSString *filename;
    int lineNumber;
    NSArray *sourcePaths;

    FileReference = [inspectedEntity valueOfFieldNamed:@"FileReference"];
    if (!FileReference) {
        NSBeep();
        return;
    }
    
    sourcePaths = [[NSUserDefaults standardUserDefaults]
            arrayForKey:@"PajeSourcePaths"];

    filename = [FileReference filename];
    lineNumber = [FileReference lineNumber];
    if (sourcePaths && ([sourcePaths count] > 0)) {
        NSEnumerator *sourcePathEnum = [sourcePaths objectEnumerator];
        NSString *fullPath;

        while ((fullPath = [sourcePathEnum nextObject]) != nil) {
            fullPath = [fullPath stringByAppendingPathComponent:filename];
            if ([[NSFileManager defaultManager] 
                   isReadableFileAtPath:fullPath]) {
                [[SourceTextController controllerForFilename:fullPath]
                        selectLineNumber:lineNumber];
                return;
            }
        }
    }
    NSRunAlertPanel(@"File Not Found",
                    @"File '%@' has not been found or is not readable.\n"
                     @"Verify the value of the defaults variable"
                     @" \"PajeSourcePaths\" in the Info/Preferences... panel.\n"                      @"Currently, it is set to '%@'",
                    @"Ok", nil, nil, filename, sourcePaths);
}

- (IBAction)executeScript:(id)sender
{
    NSArray *entities;
    NSEnumerator *entitiesEnum;
    PajeEntity *entity;
    NSMutableArray *arguments;
    NSString *fieldName;
    NSString *scriptPath;
    NSTask *task;

    if ([[scriptFieldSourceMatrix selectedCell] tag] == 0) {
        entities = [NSArray arrayWithObject:inspectedEntity];
    } else {
        entities = [inspectedEntity relatedEntities];
        if ([entities count] < 1) {
            NSRunAlertPanel(@"Entity Inspector",
                            @"No related entities!", nil, nil, nil);
            return;
        }
    }

    fieldName = [scriptFieldNameField stringValue];
    if ((fieldName == nil) || ([fieldName isEqual:@""])) {
        NSRunAlertPanel(@"Entity Inspector",
                        @"Field name not defined!", nil, nil, nil);
        return;
    }
    [[NSUserDefaults standardUserDefaults]
            setObject:fieldName forKey:@"EntityInspectorScriptFieldName"];

    scriptPath = [scriptPathField stringValue];
    if ((scriptPath == nil) || ([scriptPath isEqual:@""])) {
        NSRunAlertPanel(@"EntityInspector",
                        @"Program path not defined!", nil, nil, nil);
        return;
    }
    [[NSUserDefaults standardUserDefaults]
            setObject:scriptPath forKey:@"EntityInspectorScriptPath"];

    if (![[NSFileManager defaultManager] isExecutableFileAtPath:scriptPath]) {
        NSRunAlertPanel(@"EntityInspector",
                        @"File '%@' does not exist or is not executable!",
                        nil, nil, nil, scriptPath);
        return;
    }

    arguments = [NSMutableArray array];
    entitiesEnum = [entities objectEnumerator];
    while ((entity = [entitiesEnum nextObject]) != nil) {
        id argument;
        argument = [[entity valueOfFieldNamed:fieldName] description];
        if (argument == nil)
            argument = @"--nil--";
        [arguments addObject:argument];
    }
    
    task = [NSTask launchedTaskWithLaunchPath:scriptPath arguments:arguments];
}

@end
