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
#include "PajeEntityInspector.h"
#include "SourceCodeReference.h"
#include "PajeType.h"

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
    return inspector;
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([notification object] == inspectionWindow) {
        [allInstances removeObjectIdenticalTo:self];
        [self autorelease];
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
#ifdef GNUSTEP
        NSString *filename = @"PajeEntityInspector";
        loaded = [bundle loadNibFile:filename
	    	   externalNameTable:nameTable
		            withZone:[self zone]];
#else
        NSString *filename = [bundle pathForResource:@"PajeEntityInspector" ofType:@"nib"];
        if (filename)
            loaded = [NSBundle loadNibFile:filename
                         externalNameTable:nameTable
                                  withZone:[self zone]];
#endif
        class = [class superclass];
    }
    if (!loaded) {
        NSRunAlertPanel(@"Can't find file",
                        @"Interface description file '%@' not found",
                        nil, nil, nil, @"PajeEntityInspector");
        [self release];
        return nil;
    }

    top = NSMaxY([fieldBox frame]);
    bottom = NSMinY([relatedEntitiesBox frame]);

    [fieldBox retain];
    [fieldBox removeFromSuperview];
    [fileBox retain];
    [fileBox removeFromSuperview];
    [relatedEntitiesBox retain];
    [relatedEntitiesBox removeFromSuperview];

    return self;
}

- (void)dealloc
{
    if (inspectedEntity) [inspectedEntity release];
    [nonDisplayedFields release];
    [fieldBox release];
    [fileBox release];
    [relatedEntitiesBox release];
    [super dealloc];
}

- (void)reset
{
    [nameField retain];
    [colorField retain];
    [reuseButton retain];
    [filterButton retain];
    [[[[[inspectionWindow contentView] subviews] mutableCopy] autorelease] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[inspectionWindow contentView] addSubview:nameField];
    [[inspectionWindow contentView] addSubview:colorField];
    [[inspectionWindow contentView] addSubview:reuseButton];
    [[inspectionWindow contentView] addSubview:filterButton];
    [nameField release];
    [colorField release];
    [reuseButton release];
    [filterButton release];

    top = NSMaxY([fieldBox frame]);
    bottom = NSMinY([relatedEntitiesBox frame]);
}

- (void)addSubview:(NSView *)view atBottom:(BOOL)atBottom
{
    NSRect frame;
    float ypos;

    if (!view)
        return;
    frame = [view frame];
    if (atBottom) {
        ypos = bottom;
        bottom += (NSHeight(frame) + 2);
    } else {
        ypos = top - NSHeight(frame);
        top = ypos - 2;
    }
    frame.origin.y = ypos;
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
    NSBox *box = /*[*/[NSUnarchiver unarchiveObjectWithData:[NSArchiver archivedDataWithRootObject:fieldBox]]/* autorelease]*/;
    NSForm *form = [[[box contentView] subviews] objectAtIndex:0];
    int index;

    NSAssert([titles count] == [values count],
             @"count of fields and values do not match");
    
    [box setTitle:boxTitle];
    
    // Field Matrix
    while ([form cellAtIndex:0])
        [form removeEntryAtIndex:0];

    for (index = 0; index < [titles count]; index++) {
        NSString *fieldTitle = [[titles objectAtIndex:index] description];
        NSString *fieldValue = [[values objectAtIndex:index] description];
        NSFormCell *fieldCell;
        
//            [nonDisplayedFields removeObject:fieldName];
        fieldCell = [form addEntry:[fieldTitle stringByAppendingString:@":"]];
        [fieldCell setStringValue:fieldValue];
        [fieldCell setBordered:NO];
        [fieldCell setEditable:NO];
        [fieldCell setTitleFont:[[NSFontManager sharedFontManager] convertFont:[fieldCell titleFont] toHaveTrait:NSBoldFontMask]];
    }
    [form sizeToCells];
    [box sizeToFit];
    //[box setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin];
    [box setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [box setAutoresizesSubviews:YES];
    [[box contentView] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[box contentView] setAutoresizesSubviews:YES];
    [form setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    return box;
}

- (NSBox *)boxWithTitle:(NSString *)boxTitle
           fieldObjects:(NSArray *)objects
            fieldTitles:(NSArray *)titles
            fieldValues:(NSArray *)values
{
    // I don't know a better way of copying a box...
    NSBox *box = /*[*/[NSUnarchiver unarchiveObjectWithData:[NSArchiver archivedDataWithRootObject:fieldBox]]/* autorelease]*/;
    NSForm *form = [[[box contentView] subviews] objectAtIndex:0];
    int index;

    NSAssert([titles count] == [values count],
             @"count of fields and values do not match");

    [box setTitle:boxTitle];

    // Field Matrix
    while ([form cellAtIndex:0])
        [form removeEntryAtIndex:0];

    [form setTarget:self]; //@@@
    [form setDoubleAction:@selector(fuidoubleclicado:)]; //@@@

    for (index = 0; index < [titles count]; index++) {
        NSString *fieldTitle = [[titles objectAtIndex:index] description];
        NSString *fieldValue = [[values objectAtIndex:index] description];
        id fieldObject = [objects objectAtIndex:index];
        NSFormCell *fieldCell;

//            [nonDisplayedFields removeObject:fieldName];
        fieldCell = [form addEntry:[fieldTitle stringByAppendingString:@":"]];
        [fieldCell setStringValue:fieldValue];
        [fieldCell setRepresentedObject:fieldObject];
        [fieldCell setBordered:NO];
        [fieldCell setEditable:NO];
        [fieldCell setTitleFont:[[NSFontManager sharedFontManager] convertFont:[fieldCell titleFont] toHaveTrait:NSBoldFontMask]];
    }
    [form sizeToCells];
    [box sizeToFit];
    [box setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [box setAutoresizesSubviews:YES];
    [[box contentView] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[box contentView] setAutoresizesSubviews:YES];
    [form setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    return box;
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

- (void)inspect:(PajeEntity *)entity
{
    SourceCodeReference *sourceRef;
    NSArray *relatedEntities;

    if (inspectedEntity) [inspectedEntity release];
    inspectedEntity = [entity retain];

    nonDisplayedFields = [[NSMutableSet alloc]
        initWithArray:[entity fieldNames]];

    [self reset];

    // global fields
    [nameField setStringValue:[[inspectedEntity name] description]];
    [colorField setAction:@selector(takeColorFrom:)];
    [colorField setTarget:inspectedEntity];
    [colorField setColor:[inspectedEntity color]];
    [inspectionWindow setTitle:[[inspectedEntity entityType] name]];

    [nonDisplayedFields removeObject:@"PajeEventName"];
    [nonDisplayedFields removeObject:@"Name"];
    [nonDisplayedFields removeObject:@"Color"];

    [nonDisplayedFields removeObject:@"EntityType"];
    [nonDisplayedFields removeObject:@"Value"];

    [self addLocalFields];

    // source code reference
    sourceRef = [inspectedEntity valueOfFieldNamed:@"FileReference"];
    if (sourceRef) {
        NSString *filename = [sourceRef filename];
        int lineNumber = [sourceRef lineNumber];
        [filenameField setStringValue:[filename description]];
        [lineNumberField setIntValue:lineNumber];
        [self addSubview:fileBox atBottom:YES];
        [nonDisplayedFields removeObject:@"FileReference"];
    }

    relatedEntities = [inspectedEntity relatedEntities];
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
            [cell setTitle:[[related name] description]];
            [cell setTarget:related];
            [cell setAction:@selector(inspect:)];
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
                [[NSClassFromString(@"SourceTextController") controllerForFilename:fullPath] selectLineNumber:lineNumber];
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
