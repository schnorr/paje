BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = StatViewer

StatViewer_PRINCIPAL_CLASS = StatViewer

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj

StatViewer_RESOURCE_FILES = StatViewer.gorm

StatViewer_OBJC_FILES = \
        PieCell.m \
        StatViewer.m \
        StatArray.m \
        StatValue.m

StatViewer_HEADER_FILES = \
        PieCell.h \
        StatViewer.h \
        StatArray.h \
        StatValue.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
