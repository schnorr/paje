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
/*
 */

#include "STController.h"
#include "DrawView.h"
#include "STEntityTypeLayoutController.h"
#include "../Paje/PajeTraceController.h"
#include "../General/Macros.h"

@implementation STController

- (id)initWithController:(PajeTraceController *)c
{
    self = [super initWithController:c];

    if (self != nil) {
        if (![NSBundle loadNibNamed:@"SpaceTime" owner:self]) {
            NSRunAlertPanel(@"SpaceTime", @"Couldn't load interface file",
                            @"Abort", nil, nil);
            //[self release];
            //return nil;
        //} else {
    }    [self adjustInterface];
        //}

        layoutDescriptors = [[NSMutableDictionary alloc] init];
        layoutController = [[STEntityTypeLayoutController alloc]
                                            initWithDelegate:self];

        // register the tools with the controller
        [self registerTool:self];
        [self registerTool:layoutController];
    }

    return self;
}

- (void)dealloc
{
    // super's implementation will grant disconnection
#ifdef GNUSTEP
    // workaround GNUstep bug #13382
    {
    int rc;
    rc = [drawView retainCount];
    [drawView retain];
    [hierarchyRuler release];
    if ([drawView retainCount] > rc) {
        [drawView release];
    }
    }
#else
    [hierarchyRuler release];
#endif
    [super dealloc];
}

- (void)disconnectComponent
{
    Assign(layoutDescriptors, nil);
    Assign(layoutController, nil);
    [super disconnectComponent];
}

// set some things that weren't set when main nib file was loaded
- (void)adjustInterface
{
    // set rulers
    [scrollView setHasVerticalRuler:YES];
    hierarchyRuler = [[HierarchyRuler alloc] initWithScrollView:scrollView
                                                     controller:self];
    [scrollView setVerticalRulerView:hierarchyRuler];
    [hierarchyRuler setClientView:drawView];

    [scrollView setHasHorizontalRuler:YES];
    [[scrollView horizontalRulerView] setClientView:drawView];
    [[scrollView horizontalRulerView] setReservedThicknessForMarkers:0.0];

    [scrollView setRulersVisible:NO/*YES*/];

    [window setDelegate:self];
    [window setFrameAutosaveName:@"SpaceTime"];
    [window makeKeyAndOrderFront:self];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    // tell controller that we are key (to change filter menus)
    // TODO: find a cleaner way of doing this
    [controller windowIsKey];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [controller removeComponent:self];
}

- (void)windowDidResize:(NSNotification *)notification
{
    [drawView windowDidResize:notification];
}

- (NSString *)toolName
{
    return @"Space Time Diagram";
}

- (void)setInputComponent:(PajeFilter *)filter
{
    [super setInputComponent:filter];
    [drawView setFilter:self/*(PajeFilter *)filter*/];
}


- (STEntityTypeLayout *)descriptorForEntityType:(PajeEntityType *)entityType
{
    return [layoutDescriptors objectForKey:entityType];
}


- (STEntityTypeLayout *)createDescriptorForEntityType:(PajeEntityType *)eType
                                  containerDescriptor:(STContainerTypeLayout *)cDesc
{
    STEntityTypeLayout *layoutDescriptor;
    PajeDrawingType drawingType;
    NSEnumerator *subtypeEnum;
    PajeEntityType *subtype;

    drawingType = [self drawingTypeForEntityType:eType];
    layoutDescriptor = [STEntityTypeLayout
                                    descriptorWithEntityType:eType
                                                 drawingType:drawingType
                                         containerDescriptor:cDesc
                                                  controller:self];
    if (drawingType == PajeVariableDrawingType) {
        [(STVariableTypeLayout*)layoutDescriptor setMinValue:[self minValueForEntityType:eType]];
        [(STVariableTypeLayout*)layoutDescriptor setMaxValue:[self maxValueForEntityType:eType]];
    }
    [layoutDescriptors setObject:layoutDescriptor forKey:eType];

    subtypeEnum = [[self containedTypesForContainerType:eType]
                                    objectEnumerator];
    while ((subtype = [subtypeEnum nextObject]) != nil) {
        STEntityTypeLayout *subdescriptor;
        
        subdescriptor = [self createDescriptorForEntityType:subtype
                                        containerDescriptor:(STContainerTypeLayout *)layoutDescriptor];
    }

    return layoutDescriptor;
}

- (STContainerTypeLayout *)rootLayout
{
    id rootInstance;
    PajeEntityType *rootEntityType;
    STEntityTypeLayout *rootLayout;

    rootInstance = [self rootInstance];
    rootEntityType = [self entityTypeForEntity:rootInstance];
    rootLayout = [self descriptorForEntityType:rootEntityType];
    return (STContainerTypeLayout *)rootLayout;
}

- (void)renewLayoutDescriptors
{
    id rootInstance;
    PajeEntityType *rootEntityType;
    STContainerTypeLayout *rootLayout;
    
    [layoutDescriptors removeAllObjects];
    rootInstance = [self rootInstance];
    rootEntityType = [self entityTypeForEntity:rootInstance];
    rootLayout = (STContainerTypeLayout *)
                 [self createDescriptorForEntityType:rootEntityType
                                 containerDescriptor:nil];
    [rootLayout setOffsets];
    [self calcRectOfInstance:rootInstance
          ofLayoutDescriptor:rootLayout
                        minY:0];
}

- (NSArray *)layoutDescriptors
{
    return [layoutDescriptors allValues];
}


- (void)timeLimitsChanged
{
    [self hierarchyChanged];
}

- (void)hierarchyChanged
{
    [window setTitleWithRepresentedFilename:[self nameForContainer:[self rootInstance]]];

    if ([self startTime] == nil) return;

    [drawView saveMiddleTime];
    [drawView adjustTimeLimits];
    [self renewLayoutDescriptors];
    [drawView adjustSize];
    [hierarchyRuler refreshSizes];
    [scrollView setRulersVisible:YES];
[drawView doubleTimeScale:self];
[drawView halveTimeScale:self];
    [layoutController reset];
}

- (void)dataChangedForEntityType:(PajeEntityType *)entityType
{
    //FIXME
//    [self hierarchyChanged];
//    return;
    [drawView saveMiddleTime];
    [drawView adjustTimeLimits];
    [[self rootLayout] setOffsets];
    [self calcRectOfInstance:[self rootInstance]
          ofLayoutDescriptor:[self rootLayout]
                        minY:0];
    [drawView adjustSize];
    [hierarchyRuler refreshSizes];
//[scrollView setNeedsDisplay:YES];
}

- (void)limitsChangedForEntityType:(PajeEntityType *)entityType
{
    STEntityTypeLayout *layoutDescriptor;
    layoutDescriptor = [layoutDescriptors objectForKey:entityType];
    if (layoutDescriptor != nil
        && [layoutDescriptor drawingType] == PajeVariableDrawingType) {
        [(STVariableTypeLayout*)layoutDescriptor
                        setMinValue:[self minValueForEntityType:entityType]];
        [(STVariableTypeLayout*)layoutDescriptor
                        setMaxValue:[self maxValueForEntityType:entityType]];
    }
    // FIXME: redrawing could be limeted to rects of this entityType.
    [drawView setNeedsDisplay:YES];
}

- (void)changedTimeScale
{
    [self calcRectOfInstance:[self rootInstance]
          ofLayoutDescriptor:[self rootLayout]
                        minY:0];

    [drawView adjustSize];
}

- (void)colorChangedForEntityType:(PajeEntityType *)entityType
{
    [drawView setNeedsDisplay:YES];
}

- (void)orderChangedForContainerType:(PajeEntityType *)containerType;
{
    //FIXME
    [self hierarchyChanged];
}

- (void)timeSelectionChanged
{
    [drawView timeSelectionChanged];
}

- (void)containerSelectionChanged
{
    [drawView setNeedsDisplay:YES];
    [hierarchyRuler setNeedsDisplay:YES];
}

- (void)activateTool:(id)sender
/* sent by PajeController when the user selects this Tool */
{
    [window makeKeyAndOrderFront:self];
}

- (void)print:(id)sender
{
//    [[NSPrintOperation printOperationWithView:[window contentView]] runOperation]; 
    [window print:sender];
}

- (BOOL)isSelectedEntity:(id)entity
{
    id highlightedEntities;
    highlightedEntities = [drawView highlightedEntities];
    if (highlightedEntities != nil) {
        if ([highlightedEntities containsObject:entity]) {
            return YES;
        }
    }
    return [super isSelectedEntity:entity];
}
@end
