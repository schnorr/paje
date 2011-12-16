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
#include "NSMatrix+Additions.h"

@implementation NSMatrix (NSDraggingDestination)
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    id del = [self delegate];
    SEL sel = @selector(matrix:draggingEntered:);
    if (del && [del respondsToSelector:sel])
        return [del matrix:self draggingEntered:sender];
    else
        return NSDragOperationNone;//[super draggingEntered:sender];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    id del = [self delegate];
    SEL sel = @selector(matrix:draggingUpdated:);
    if (del && [del respondsToSelector:sel])
        return [del matrix:self draggingUpdated:sender];
    else
        return NSDragOperationNone;//[super draggingUpdated:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    id del = [self delegate];
    SEL sel = @selector(matrix:draggingExited:);
    if (del && [del respondsToSelector:sel])
        [del matrix:self draggingExited:sender];
    else
        return;//[super draggingExited:sender];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    id del = [self delegate];
    SEL sel = @selector(matrix:prepareForDragOperation:);
    if (del && [del respondsToSelector:sel])
        return [del matrix:self prepareForDragOperation:sender];
    else
        return NO;//[super prepareForDragOperation:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    id del = [self delegate];
    SEL sel = @selector(matrix:performDragOperation:);
    if (del && [del respondsToSelector:sel])
        return [del matrix:self performDragOperation:sender];
    else
        return NO;//[super performDragOperation:sender];
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    id del = [self delegate];
    SEL sel = @selector(matrix:concludeDragOperation:);
    if (del && [del respondsToSelector:sel])
        [del matrix:self concludeDragOperation:sender];
    else
        return;//[super concludeDragOperation:sender];
}
@end

@implementation NSMatrix (Additions)
- (id)cellAtPoint:(NSPoint)p
{
    NSInteger row, column;

    if ([self getRow:&row column:&column forPoint:p])
        return [self cellAtRow:row column:column];
    return nil;
}
@end
