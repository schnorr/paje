BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = EntityTypeFilter
EntityTypeSelector_PRINCIPAL_CLASS = EntityTypeSelector

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj

EntityTypeFilter_RESOURCE_FILES = EntityTypeSelector.gorm

EntityTypeFilter_OBJC_FILES = EntityTypeSelector.m

EntityTypeFilter_HEADER_FILES = EntityTypeSelector.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
