#ifndef _AnchorFilter_h_
#define _AnchorFilter_h_

/** AnchorFilter
 *  First filter in chain of filters.
 *  Must implement all filter queries and commands.
 *  Implements queries by accessing entities directly.
 *  Implements container and time selections.
 *  Implements other commands by logging "not implemented" message.
 */

#include "../General/PajeFilter.h"

@interface AnchorFilter : PajeFilter
{
    NSSet *selectedContainers;
    NSDate *selectionStartTime;
    NSDate *selectionEndTime;
}
@end

#endif
