BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

OrderFilter_PRINCIPAL_CLASS = Order

BUNDLE_NAME = OrderFilter

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework PajeGeneral
else
	OrderFilter_BUNDLE_LIBS += -lPajeGeneral
	ADDITIONAL_LIB_DIRS += -L../General/PajeGeneral.framework/Versions/Current
endif

OrderFilter_RESOURCE_FILES = \
	Order.gorm \
	Order.nib

OrderFilter_OBJC_FILES = Order.m OrderKey.m

OrderFilter_HEADER_FILES = Order.h Order.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
