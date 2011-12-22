BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = ReductionFilter

ReductionFilter_PRINCIPAL_CLASS = BusyNode

ADDITIONAL_INCLUDE_DIRS = -I../General
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework PajeGeneral
else
	ReductionFilter_BUNDLE_LIBS += -lPajeGeneral
	ADDITIONAL_LIB_DIRS += -L../General/PajeGeneral.framework/Versions/Current
endif

ReductionFilter_RESOURCE_FILES = \
        ReductionFilter.gorm \
        ReductionFilter.nib

ReductionFilter_OBJC_FILES = \
        BusyNode.m \
        BusyArray.m \
        BusyDate.m \
        ReduceEntity.m \
        ReduceEntityType.m

ReductionFilter_HEADER_FILES = \
        BusyNode.h \
        BusyArray.h \
        BusyDate.h \
        ReduceEntity.h \
        ReduceEntityType.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
