ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

BUNDLE_INSTALL_DIR=$(GNUSTEP_INSTALLATION_DIR)/Library/Bundles/Paje

include $(GNUSTEP_MAKEFILES)/common.make

StorageController_PRINCIPAL_CLASS = Encapsulate

BUNDLE_NAME = StorageController

ADDITIONAL_INCLUDE_DIRS = -I../General

StorageController_OBJC_FILES = Encapsulate.m

StorageController_HEADER_FILES = Encapsulate.h

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble m.template \
h.template

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

endif
