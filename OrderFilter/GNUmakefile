BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje
GNUSTEP_MAKEFILES = $(GNUSTEP_SYSTEM_ROOT)/Makefiles
include $(GNUSTEP_MAKEFILES)/common.make

OrderFilter_PRINCIPAL_CLASS = Order

BUNDLE_NAME = OrderFilter

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj

OrderFilter_RESOURCE_FILES = Order.gorm

OrderFilter_OBJC_FILES = Order.m OrderKey.m

OrderFilter_HEADER_FILES = Order.h Order.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
