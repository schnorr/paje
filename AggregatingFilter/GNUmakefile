ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

include $(GNUSTEP_MAKEFILES)/common.make

AggregatingFilter_PRINCIPAL_CLASS = AggregatingFilter

BUNDLE_NAME = AggregatingFilter

ADDITIONAL_INCLUDE_DIRS = -I../General

AggregatingFilter_OBJC_FILES = \
        AggregatingFilter.m \
        AggregateEvent.m \
        AggregateState.m \
        AggregateValue.m \
        AggregateLink.m \
        EntityAggregator.m \
	AggregatingChunkArray.m

AggregatingFilter_HEADER_FILES = \
        AggregatingFilter.h \
        AggregateEvent.h \
        AggregateState.h \
        AggregateValue.h \
        AggregateLink.h \
        EntityAggregator.h \
	AggregatingChunkArray.h

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble m.template \
h.template

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

endif
