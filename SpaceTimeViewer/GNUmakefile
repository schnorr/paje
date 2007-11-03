BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = SpaceTimeViewer

SpaceTimeViewer_PRINCIPAL_CLASS = STController

ADDITIONAL_INCLUDE_DIRS = -I../General
ifeq ($(FOUNDATION_LIB), apple)
LDFLAGS += -F../General -framework General
else
#LDFLAGS += -lGeneral
endif

SpaceTimeViewer_RESOURCE_FILES = \
        STEntityTypeLayout.gorm \
        STEntityTypeLayout.nib \
        SpaceTime.gorm \
        SpaceTime.nib \
        crosscursor.tiff \
        distant.tiff \
        near.tiff \
        toselection.tiff

SpaceTimeViewer_OBJC_FILES = \
        DrawView.m \
        DrawView+Mouse.m \
        DrawView+Finding.m \
        DrawView+Positioning.m \
        DrawView+Drawing.m \
        STController.m \
        HierarchyRuler.m \
        Shape.m \
        STEntityTypeLayout.m \
        STEntityTypeLayoutController.m \
        STLayoutEditor.m

SpaceTimeViewer_HEADER_FILES = \
        DrawView.h \
        STController.h \
        HierarchyRuler.h \
        Shape.h \
	STEntityTypeLayout.h \
	STEntityTypeLayoutController.h \
        STLayoutEditor.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
