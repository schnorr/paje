BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

AggregatingFilter_PRINCIPAL_CLASS = AggregatingFilter

BUNDLE_NAME = AggregatingFilter

ADDITIONAL_INCLUDE_DIRS = -I../General
ifeq ($(FOUNDATION_LIB), apple)
	LDFLAGS += -F../General -framework PajeGeneral
else
	AggregatingFilter_BUNDLE_LIBS += -lPajeGeneral
	ADDITIONAL_LIB_DIRS += -L../General/PajeGeneral.framework/Versions/Current
endif

AggregatingFilter_OBJC_FILES = \
        AggregatingFilter.m \
        AggregateEvent.m \
        AggregateState.m \
        AggregateValue.m \
        AggregateLink.m \
        EntityAggregator.m \
	AggregatingChunk.m \
	AggregatingChunkArray.m

AggregatingFilter_HEADER_FILES = \
        AggregatingFilter.h \
        AggregateEvent.h \
        AggregateState.h \
        AggregateValue.h \
        AggregateLink.h \
        EntityAggregator.h \
	AggregatingChunk.h \
	AggregatingChunkArray.h

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble m.template \
h.template

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

