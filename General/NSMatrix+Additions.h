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
#ifndef _NSMatrix_Additions_h_
#define _NSMatrix_Additions_h_

// NSMatrix+Additions.h
//
// NSMatrix (NSDraggingDestination)
// Category to NSMatrix that allows it's delegate to receive
// dragging destination messages.
// To receive draggingEntered: messages, the delegate has to implement
// -matrix:(NSMatrix *)m draggingEntered:(id <NSDraggingInfo>)sender
// messages, and so on (see NSDraggingDestination protocol).
//
// NSMatrix (Additions)
// defines a method that returns the cell in a point, or nil

#include <AppKit/AppKit.h>

@protocol MatrixDraggingDelegate
- (NSDragOperation)matrix:(NSMatrix *)matrix
          draggingEntered:(id <NSDraggingInfo>)sender;
- (NSDragOperation)matrix:(NSMatrix *)matrix
          draggingUpdated:(id <NSDraggingInfo>)sender;
- (void)matrix:(NSMatrix *)matrix
    draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)matrix:(NSMatrix *)matrix
    prepareForDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)matrix:(NSMatrix *)matrix
    performDragOperation:(id <NSDraggingInfo>)sender;
- (void)matrix:(NSMatrix *)matrix
    concludeDragOperation:(id <NSDraggingInfo>)sender;
@end

@interface NSMatrix (NSDraggingDestination)
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender;
- (void)draggingExited:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender;
@end

@interface NSMatrix (Additions)
- (id)cellAtPoint:(NSPoint)p;
@end

#endif
