BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = SpaceTimeViewer

SpaceTimeViewer_PRINCIPAL_CLASS = STController

ADDITIONAL_INCLUDE_DIRS = -I../General

SpaceTimeViewer_RESOURCE_FILES = \
        STEntityTypeLayout.gorm \
        SpaceTime.gorm \
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
	STEntityTypeLayoutController.m

SpaceTimeViewer_HEADER_FILES = \
        DrawView.h \
        STController.h \
        HierarchyRuler.h \
        Shape.h \
	STEntityTypeLayout.h \
	STEntityTypeLayoutController.h

SpaceTimeViewer_PSWFILES = drawline.psw

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
