BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = StatViewer

StatViewer_PRINCIPAL_CLASS = StatViewer

ADDITIONAL_INCLUDE_DIRS = -I../General

StatViewer_RESOURCE_FILES = StatViewer.gorm

StatViewer_OBJC_FILES = \
        StatViewer.m \
        PieCell.m \
        StatArray.m

StatViewer_HEADER_FILES = \
        StatViewer.h \
        PieCell.h \
        StatArray.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
