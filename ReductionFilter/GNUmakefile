BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = ReductionFilter

ReductionFilter_PRINCIPAL_CLASS = BusyNode

ADDITIONAL_INCLUDE_DIRS = -I../General

ReductionFilter_RESOURCE_FILES = \
        BusyNode.gorm

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
