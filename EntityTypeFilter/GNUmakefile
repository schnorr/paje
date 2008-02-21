BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

BUNDLE_NAME = EntityTypeFilter
EntityTypeSelector_PRINCIPAL_CLASS = EntityTypeSelector

ADDITIONAL_INCLUDE_DIRS = -I../General.bproj
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework General
else
	EntityTypeFilter_BUNDLE_LIBS += -lGeneral
	ADDITIONAL_LIB_DIRS += -L../General/General.framework/Versions/Current
endif

EntityTypeFilter_RESOURCE_FILES = \
    EntityTypeSelector.gorm \
    EntityTypeSelector.nib

EntityTypeFilter_OBJC_FILES = EntityTypeSelector.m

EntityTypeFilter_HEADER_FILES = EntityTypeSelector.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
