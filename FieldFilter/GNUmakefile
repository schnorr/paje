BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = FieldFilter
FieldFilter_PRINCIPAL_CLASS = FieldFilter

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework PajeGeneral
else
	FieldFilter_BUNDLE_LIBS += -lPajeGeneral
	ADDITIONAL_LIB_DIRS += -L../General/PajeGeneral.framework/Versions/Current
endif

FieldFilter_RESOURCE_FILES = \
	FieldFilter.gorm \
	FieldFilter.nib

FieldFilter_OBJC_FILES = \
        FieldFilter.m \
        FieldFilterDescriptor.m

FieldFilter_HEADER_FILES = \
        FieldFilter.h \
        FieldFilterDescriptor.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
