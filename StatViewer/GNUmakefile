BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = StatViewer

StatViewer_PRINCIPAL_CLASS = StatViewer

ADDITIONAL_INCLUDE_DIRS = -I../General
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework PajeGeneral
else
	StatViewer_BUNDLE_LIBS += -lPajeGeneral
	ADDITIONAL_LIB_DIRS += -L../General/PajeGeneral.framework/Versions/Current
endif

StatViewer_RESOURCE_FILES = \
	StatViewer.gorm \
	StatViewer.nib

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
