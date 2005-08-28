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

//NSPoint lastWindowPosition;

@implementation PajeEntityInspector

static NSMutableArray *allInstances;

+ (PajeEntityInspector *)inspector
{
    NSEnumerator *instEnum;
    PajeEntityInspector *inspector;
    if (!allInstances)
        allInstances = [[NSMutableArray alloc] init];
    instEnum = [allInstances objectEnumerator];
    while ((inspector = [instEnum nextObject]) != nil) {
        if ([inspector isReusable]) {
            inspector->isa = self;
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

    top = NSMinY([colorField frame]) - 5;
    bottom = 10;

    [[showFileButton retain] removeFromSuperview];
    archivedTitleField= [NSArchiver archivedDataWithRootObject:titleField];
    archivedValueField= [NSArchiver archivedDataWithRootObject:valueField];
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
    Assign(nonDisplayedFields, nil);

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
    [[[[[inspectionWindow contentView] subviews] mutableCopy] autorelease] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // add the top widgets
    [[inspectionWindow contentView] addSubview:nameField];
    [[inspectionWindow contentView] addSubview:colorField];
    [[inspectionWindow contentView] addSubview:reuseButton];
    [[inspectionWindow contentView] addSubview:filterButton];

    // initialize vertical positions for boxes
    top = NSMinY([colorField frame]) - 5;
    bottom = 10;
}

- (void)addSubview:(NSView *)view atBottom:(BOOL)atBottom
{
    NSRect frame;
    float ypos;

    if (view == nil) {
        return;
    }

    frame = [view frame];
    if (atBottom) {
        ypos = bottom;
        bottom += (NSHeight(frame) + 2);
    } else {
        ypos = top - NSHeight(frame);
        top = ypos - 2;
    }
    frame.origin.y = ypos;
    frame.origin.x = NSMinX([colorField frame]);
    frame.size.width = NSMaxX([nameField frame]) - NSMinX(frame);
    [view setFrame:frame];
    [[inspectionWindow contentView] addSubview:view];
    [[inspectionWindow contentView] setBounds:NSUnionRect([[inspectionWindow contentView] bounds], frame)];
}

- (void)addLastSubview:(NSView *)view
{
    NSRect frame;

    if (!view)
        return;

    frame = [view frame];
    frame.origin.y = bottom;
    frame.size.height = top - bottom;
    frame.origin.x = NSMinX([colorField frame]);
    frame.size.width = NSMaxX([nameField frame]) - NSMinX(frame);
    [view setFrame:frame];
    [[inspectionWindow contentView] addSubview:view];
}

- (IBAction)filterEntityName:(id)sender
{
    PajeEntityType *entityType;
    id entityName;
    NSString *filtering;

    entityType = [inspectedEntity entityType];
    entityName = [inspectedEntity name];
    if ([sender state])
        filtering = @"YES";
    else
        filtering = @"NO";
    if (entityType != nil && entityName != nil)
        [[NSNotificationCenter defaultCenter]
postNotificationName:@"PajeFilterEntityNameNotification"
              object:self
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                entityType, @"EntityType",
                entityName, @"EntityName",
                filtering, @"Show",
                nil]];
}

- (NSBox *)boxWithTitle:(NSString *)boxTitle
            fieldTitles:(NSArray *)titles
            fieldValues:(NSArray *)values
{
    // I don't know a better way of copying a box...
    NSBox *box = [NSUnarchiver unarchiveObjectWithData:archivedBox];
    int index;
    float curY = 0;
    float titleWidth = 0;
    NSTextField *field1;
    field1 = [NSUnarchiver unarchiveObjectWithData:archivedTitleField];

    NSAssert([titles count] == [values count],
             @"count of fields and values do not match");
    
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
        NSTextField *titleField;
        NSTextField *valueField;
        
        titleField = [NSUnarchiver unarchiveObjectWithData:archivedTitleField];
        valueField = [NSUnarchiver unarchiveObjectWithData:archivedValueField];
        
        [titleField setStringValue:title];
        [valueField setStringValue:value];
        
        height = MAX([[titleField cell] cellSize].height,
                     [[valueField cell] cellSize].height);
        
        [titleField setFrame:NSMakeRect(0, curY, titleWidth, height)];
        [valueField setFrame:NSMakeRect(titleWidth + 2, curY, 10, height)];
        [box addSubview:titleField];
        [box addSubview:valueField];
        
        curY += height+2;
    }
    [box sizeToFit];

    return box;
}

- (NSBox *)boxForSourceReference:(SourceCodeReference *)sourceRef
{
    NSBox *box;
    NSArray *values;
    NSRect buttonFrame;
    NSRect contentFrame;
    
    values = [NSArray arrayWithObjects:
        [sourceRef filename],
        [NSString stringWithFormat:@"%d", [sourceRef lineNumber]],
        nil];
    
    box = [self boxWithTitle:@""
            fieldTitles:[NSArray arrayWithObjects:@"File", @"Line", nil]
            fieldValues:values];
    [box setTitlePosition:NSNoTitle];
    [box sizeToFit];
            
    contentFrame = [[box contentView] frame];
    buttonFrame = [showFileButton frame];
    [showFileButton setFrame:NSMakeRect(NSMaxX(contentFrame) + 2,
                                        0,
                                        NSWidth(buttonFrame),
                                        NSHeight(contentFrame))];
    [box addSubview:showFileButton];
    [box sizeToFit];

    return box;
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
        if (!fieldValue) fieldValue = @"";
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
    NSMutableArray *fieldTitles = [NSMutableArray array];
    NSMutableArray *fieldValues = [NSMutableArray array];
    NSMutableArray *fieldObjects = [NSMutableArray array];

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
    [self addSubview:box atBottom:NO];
}

- (void)addLocalFields
{
    NSBox *box;
    NSMutableArray *fieldTitles = [NSMutableArray array];
    NSMutableArray *fieldValues = [NSMutableArray array];
    NSDate *startTime;
    NSDate *endTime;

    // entity identification
    // entityType and value are already on top of window.
    /*
    [fieldTitles addObject:@"Type"];
    [fieldValues addObject:[[inspectedEntity entityType] name]];
    [fieldTitles addObject:@"Value"];
    [fieldValues addObject:[inspectedEntity name]];
     */

    // container information
    [self addBoxForContainer:[inspectedEntity container]
               upToContainer:nil
                   withTitle:@"Container"];
    [nonDisplayedFields removeObject:@"Container"];

    // timing information
    [fieldTitles removeAllObjects];
    [fieldValues removeAllObjects];
    startTime = [inspectedEntity startTime];
    endTime = [inspectedEntity endTime];
    if (startTime == endTime /*[startTime isEqualToDate:endTime]*/) {
        [fieldTitles addObject:@"Time"];
        [fieldValues addObject:[startTime description]];
    } else {
        [fieldTitles addObject:@"Start Time"];
        [fieldValues addObject:[startTime description]];
        [fieldTitles addObject:@"End Time"];
        [fieldValues addObject:[endTime description]];
        [fieldTitles addObject:@"Duration"];
        [fieldValues addObject:[NSString stringWithFormat:@"%.6f", [endTime timeIntervalSinceDate:startTime]]];
   }
    [nonDisplayedFields removeObject:@"Time"];
    [nonDisplayedFields removeObject:@"StartTime"];
    [nonDisplayedFields removeObject:@"EndTime"];
    [nonDisplayedFields removeObject:@"Duration"];
    
    box = [self boxWithTitle:@"Timing"
                 fieldTitles:fieldTitles
                 fieldValues:fieldValues];
    [self addSubview:box atBottom:NO];
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

- (void)inspectEntity:(id<PajeEntity>)entity
           withFilter:(PajeFilter *)f
{
    SourceCodeReference *sourceRef;
    NSArray *relatedEntities;

    Assign(inspectedEntity, entity);
    Assign(filter, f);

    nonDisplayedFields = [[NSMutableSet alloc]
        initWithArray:[filter fieldNamesForEntity:entity]];

    [self reset];

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

    [self addLocalFields];

    // source code reference
    sourceRef = [filter valueOfFieldNamed:@"FileReference"
                                forEntity:inspectedEntity];
    if (sourceRef != nil) {
        [self addSubview:[self boxForSourceReference:sourceRef] atBottom:YES];
        [nonDisplayedFields removeObject:@"FileReference"];
    }

    relatedEntities = [filter relatedEntitiesForEntity:inspectedEntity];
    [nonDisplayedFields removeObject:@"RelatedEntities"];

    // other fields
    if ([nonDisplayedFields count] > 0) {
        NSBox *box;
        NSArray *fieldTitles = [nonDisplayedFields allObjects];

        box = [self boxWithTitle:@"Other values"
                     fieldTitles:fieldTitles
                      fieldNames:fieldTitles];
        [self addSubview:box atBottom:NO];
    }

    // Related entities
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
        [relatedEntitiesBox sizeToFit];
        [self addLastSubview:relatedEntitiesBox];
    }
    [relatedEntitiesMatrix retain];///BUG (porque ta sendo liberada?)
    
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
    
    sourcePaths = [[NSUserDefaults standardUserDefaults] arrayForKey:@"PajeSourcePaths"];

    filename = [FileReference filename];
    lineNumber = [FileReference lineNumber];
    if (sourcePaths && ([sourcePaths count] > 0)) {
        NSEnumerator *sourcePathEnum = [sourcePaths objectEnumerator];
        NSString *fullPath;

        while ((fullPath = [sourcePathEnum nextObject]) != nil) {
            fullPath = [fullPath stringByAppendingPathComponent:filename];
            if ([[NSFileManager defaultManager] isReadableFileAtPath:fullPath]) {
//                [[NSWorkspace sharedWorkspace] openFile:fullPath];
                [[SourceTextController controllerForFilename:fullPath] selectLineNumber:lineNumber];
//                NSRunAlertPanel(@"Source Code",
//                                @"Sorry, source code inspection is not working",
//                                @"OK", nil, nil);
                return;
            }
        }
    }
    NSRunAlertPanel(@"File Not Found",
                    @"File %@ has not been found or is not readable.\nVerify the value of the defaults variable \"PajeSourcePaths\" in the Info/Preferences... panel.\nCurrently, it is set to %@",
                    @"Ok", nil, nil, filename, sourcePaths);
}
@end
