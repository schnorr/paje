BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

ImbricationFilter_PRINCIPAL_CLASS = InsetLimit

BUNDLE_NAME = ImbricationFilter

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework PajeGeneral
else
	ImbricationFilter_BUNDLE_LIBS += -lPajeGeneral
	ADDITIONAL_LIB_DIRS += -L../General/PajeGeneral.framework/Versions/Current
endif

ImbricationFilter_RESOURCE_FILES = \
	InsetLimit.gorm \
	InsetLimit.nib

ImbricationFilter_OBJC_FILES = InsetLimit.m

ImbricationFilter_HEADER_FILES = InsetLimit.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
