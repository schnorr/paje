#include "AnchorFilter.h"

#include "../General/PajeEntityInspector.h"
#include "../General/Macros.h"

@implementation AnchorFilter

- (id)initWithController:(PajeTraceController *)c
{
    [super initWithController:c];
    //Assign(selectedContainers, [NSSet set]);
    Assign(selectedContainers, [[[NSSet alloc] init] autorelease]);
    selectionStartTime = nil;
    selectionEndTime = nil;
    return self;
}

- (void)dealloc
{
    Assign(selectedContainers, nil);
    Assign(selectionStartTime, nil);
    Assign(selectionEndTime, nil);
    [super dealloc];
}

- (void)setSelectedContainers:(NSSet *)containers
{
    Assign(selectedContainers, containers);
    [self containerSelectionChanged];
}

- (NSSet *)selectedContainers
{
    return selectedContainers;
}

- (void)setSelectionStartTime:(NSDate *)from endTime:(NSDate *)to
{
    Assign(selectionStartTime, from);
    Assign(selectionEndTime, to);
    [self timeSelectionChanged];
}

- (NSDate *)selectionStartTime
{
    return selectionStartTime;
}

- (NSDate *)selectionEndTime
{
    return selectionEndTime;
}

- (void)setOrder:(NSArray *)containers
ofContainersTyped:(PajeEntityType *)containerType
     inContainer:(PajeContainer *)container
{
    NSLog(@"Must include filter to change container order");
}

- (void)hideEntityType:(PajeEntityType *)entityType
{
    NSLog(@"Must include filter to hide entity types");
}

- (void)hideSelectedContainers
{
    NSLog(@"Must include filter to hide containers");
}

- (void)inspectEntity:(id<PajeEntity>)entity
{
    Class inspectorClass = nil;
    Class class = [(NSObject *)entity class];

    while ((inspectorClass == nil) && (class != [class superclass])) {
        NSString *inspName;
        inspName = [NSStringFromClass(class)
                                       stringByAppendingString:@"Inspector"];
        inspectorClass = NSClassFromString(inspName);
        class = [class superclass];
    }
    if (inspectorClass != nil) {
        [(PajeEntityInspector *)[inspectorClass inspector]
                                    inspectEntity:entity withFilter:self];
    }

//    [entity inspect];
}


//
// Queries
//


// Queries for entity types

- (NSArray *)containedTypesForContainerType:(PajeEntityType *)containerType
{
    if ([containerType isContainer]) {
        return [(PajeContainerType *)containerType containedTypes];
    } else {
        return [NSArray array];
    }
}

- (PajeEntityType *)containerTypeForType:(PajeEntityType *)entityType
{
    return [entityType containerType];
}

- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType
{
    if ([entityType respondsToSelector:@selector(minValue)])
        return [(PajeVariableType *)entityType minValue];
    else
        return [NSNumber numberWithInt:0];
}

- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType
{
    if ([entityType respondsToSelector:@selector(maxValue)])
        return [(PajeVariableType *)entityType maxValue];
    else
        return [NSNumber numberWithInt:0];
}

- (NSNumber *)minValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container
{
    if ([container respondsToSelector:@selector(minValueForEntityType:)])
        return [(id)container minValueForEntityType:entityType];
    else
        return [NSNumber numberWithInt:0];
}

- (NSNumber *)maxValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container
{
    if ([container respondsToSelector:@selector(maxValueForEntityType:)])
        return [(id)container maxValueForEntityType:entityType];
    else
        return [NSNumber numberWithInt:0];
}


- (NSArray *)allNamesForEntityType:(PajeEntityType *)entityType
{
    return [entityType allNames];
}

- (NSString *)descriptionForEntityType:(PajeEntityType *)entityType
{
    return [entityType description];
}

- (BOOL)isHiddenEntityType:(PajeEntityType *)entityType
{
    return NO;
}

- (PajeDrawingType)drawingTypeForEntityType:(PajeEntityType *)entityType
{
    return [entityType drawingType];
}

- (NSColor *)colorForName:(NSString *)name
             ofEntityType:(PajeEntityType *)entityType
{
    return [entityType colorForName:name];
}

- (void)setColor:(NSColor *)color
         forName:(NSString *)name
    ofEntityType:(PajeEntityType *)entityType
{
    [entityType setColor:color forName:name];
    [self colorChangedForEntityType:entityType];
}


- (NSColor *)colorForEntityType:(PajeEntityType *)entityType
{
    if ([entityType respondsToSelector:@selector(color)])
        return [entityType color];
    return [NSColor blackColor];
}

- (NSArray *)fieldNamesForEntityType:(PajeEntityType *)entityType
{
    return [entityType fieldNames];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
          forEntityType:(PajeEntityType *)entityType
{
    return [entityType valueOfFieldNamed:fieldName];
}




// Queries for entities

- (NSNumber *)valueForEntity:(PajeEntity *)entity
{
    if ([entity respondsToSelector:@selector(value)])
        return [(id)entity value];
    else
        return [NSNumber numberWithInt:0];
}

- (PajeContainer *)containerForEntity:(id<PajeEntity>)entity;
{
    return [entity container];
}
- (PajeEntityType *)entityTypeForEntity:(id<PajeEntity>)entity;
{
    return [entity entityType];
}
- (PajeContainer *)sourceContainerForEntity:(id<PajeLink>)entity;
{
    return [entity sourceContainer];
}
- (PajeEntityType *)sourceEntityTypeForEntity:(id<PajeLink>)entity;
{
    return [entity sourceEntityType];
}
- (PajeContainer *)destContainerForEntity:(id<PajeLink>)entity;
{
    return [entity destContainer];
}
- (PajeEntityType *)destEntityTypeForEntity:(id<PajeLink>)entity;
{
    return [entity destEntityType];
}

- (NSColor *)colorForEntity:(id<PajeEntity>)entity
{
    return [entity color];
}

- (NSDate *)startTimeForEntity:(id<PajeEntity>)entity;
{
    return [entity startTime];
}

- (NSDate *)endTimeForEntity:(id<PajeEntity>)entity;
{
    return [entity endTime];
}

- (NSDate *)timeForEntity:(id<PajeEntity>)entity
{
    return [entity time];
}

- (PajeDrawingType)drawingTypeForEntity:(id<PajeEntity>)entity
{
    return [entity drawingType];
}

- (NSString *)nameForEntity:(id<PajeEntity>)entity
{
    return [entity name];
}

- (int)imbricationLevelForEntity:(id<PajeEntity>)entity
{
    return [entity imbricationLevel];
}


- (NSString *)descriptionForEntity:(id<PajeEntity>)entity
{
    return [NSString stringWithFormat:@"%@ [%@ in %@ %@]",
        [entity name], [entity entityType],
        [[entity container] entityType], [entity container]];
}

- (BOOL)canHighlightEntity:(id<PajeEntity>)entity
{
    return YES;
}

- (BOOL)isSelectedEntity:(id<PajeEntity>)entity
{
    return NO;
}


- (NSArray *)fieldNamesForEntity:(id<PajeEntity>)entity
{
    return [entity fieldNames];
}

- (id)valueOfFieldNamed:(NSString *)fieldName
              forEntity:(id<PajeEntity>)entity
{
    return [entity valueOfFieldNamed:fieldName];
}


- (void)setColor:(NSColor *)color forEntity:(id<PajeEntity>)entity
{
    [entity setColor:color];
    [self colorChangedForEntityType:[self entityTypeForEntity:entity]];
}


@end

