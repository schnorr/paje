BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = ContainerFilter
ContainerFilter_PRINCIPAL_CLASS = ContainerSelector

ADDITIONAL_INCLUDE_DIRS = -I../General

ContainerFilter_RESOURCE_FILES = ContainerSelector.gorm

ContainerFilter_OBJC_FILES = ContainerSelector.m

ContainerFilter_HEADER_FILES = ContainerSelector.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
