BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

OrderFilter_PRINCIPAL_CLASS = Order

BUNDLE_NAME = OrderFilter

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj
ifeq ($(FOUNDATION_LIB), apple)
LDFLAGS += -framework General
else
LDFLAGS += -lGeneral
endif

OrderFilter_RESOURCE_FILES = \
	Order.gorm \
	Order.nib

OrderFilter_OBJC_FILES = Order.m OrderKey.m

OrderFilter_HEADER_FILES = Order.h Order.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
