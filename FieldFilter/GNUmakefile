BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = FieldFilter
FieldFilter_PRINCIPAL_CLASS = FieldFilter

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj

FieldFilter_RESOURCE_FILES = FieldFilter.gorm

FieldFilter_OBJC_FILES = \
        FieldFilter.m \
        FieldFilterDescriptor.m

FieldFilter_HEADER_FILES = \
        FieldFilter.h \
        FieldFilterDescriptor.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
