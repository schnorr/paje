BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = ReductionFilter

ReductionFilter_PRINCIPAL_CLASS = BusyNode

ADDITIONAL_INCLUDE_DIRS = -I../General

ReductionFilter_RESOURCE_FILES = \
        BusyNode.gorm \
        ReduceEntityInspector.gorm

ReductionFilter_OBJC_FILES = \
        BusyNode.m \
        BusyArray.m \
        BusyDate.m \
        ReduceEntity.m \
        ReduceEntityType.m \
        ReduceEntityInspector.m

ReductionFilter_HEADER_FILES = \
        BusyNode.h \
        BusyArray.h \
        BusyDate.h \
        ReduceEntity.h \
        ReduceEntityType.h \
        ReduceEntityInspector.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
