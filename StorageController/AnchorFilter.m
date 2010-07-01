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

- (PajeContainerType *)containerTypeForType:(PajeEntityType *)entityType
{
    return [entityType containerType];
}

- (double)minValueForEntityType:(PajeEntityType *)entityType
{
    return [entityType minValue];
}

- (double)maxValueForEntityType:(PajeEntityType *)entityType
{
    return [entityType maxValue];
}

- (double)minValueForEntityType:(PajeEntityType *)entityType
                    inContainer:(PajeContainer *)container
{
    return [container minValueForEntityType:entityType];
}

- (double)maxValueForEntityType:(PajeEntityType *)entityType
                        inContainer:(PajeContainer *)container
{
    return [container maxValueForEntityType:entityType];
}


- (NSArray *)allValuesForEntityType:(PajeEntityType *)entityType
{
    return [entityType allValues];
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

- (NSColor *)colorForValue:(id)value
              ofEntityType:(PajeEntityType *)entityType
{
    return [entityType colorForValue:value];
}

- (void)setColor:(NSColor *)color
        forValue:(id)value
    ofEntityType:(PajeEntityType *)entityType
{
    [entityType setColor:color forValue:value];
    [self colorChangedForEntityType:entityType];
}


- (NSColor *)colorForEntityType:(PajeEntityType *)entityType
{
    return [entityType color];
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

- (double)doubleValueForEntity:(PajeEntity *)entity
{
    return [entity doubleValue];
}

- (double)minValueForEntity:(PajeEntity *)entity
{
    return [entity minValue];
}

- (double)maxValueForEntity:(PajeEntity *)entity
{
    return [entity maxValue];
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

- (id)valueForEntity:(id<PajeEntity>)entity
{
    return [entity value];
}

- (int)imbricationLevelForEntity:(id<PajeEntity>)entity
{
    return [entity imbricationLevel];
}

- (BOOL)isAggregateEntity:(id<PajeEntity>)entity
{
    return [entity isAggregate];
}

- (unsigned)subCountForEntity:(id<PajeEntity>)entity
{
    return [entity subCount];
}

- (NSColor *)subColorAtIndex:(unsigned)index
                   forEntity:(id<PajeEntity>)entity
{
    return [entity subColorAtIndex:index];
}

- (id)subValueAtIndex:(unsigned)index
            forEntity:(id<PajeEntity>)entity
{
    return [entity subValueAtIndex:index];
}

- (double)subDurationAtIndex:(unsigned)index
                   forEntity:(id<PajeEntity>)entity
{
    return [entity subDurationAtIndex:index];
}

- (unsigned)subCountAtIndex:(unsigned)index
                  forEntity:(id<PajeEntity>)entity
{
    return [entity subCountAtIndex:index];
}


- (NSString *)descriptionForEntity:(id<PajeEntity>)entity
{
    return [entity description];
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


- (void)setColor:(NSColor *)color
       forEntity:(id<PajeEntity>)entity
{
    [entity setColor:color];
    [self colorChangedForEntityType:[self entityTypeForEntity:entity]];
}


@end

