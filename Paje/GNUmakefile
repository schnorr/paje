include $(GNUSTEP_MAKEFILES)/common.make
Paje_PRINCIPAL_CLASS = NSApplication

APP_NAME = Paje

Paje_APPLICATION_ICON = Paje.tiff
Paje_DOCICONS = traceFilePaje.tiff

ADDITIONAL_INCLUDE_DIRS = -I../General
ifeq ($(FOUNDATION_LIB), apple)
LDFLAGS += -F../General -framework PajeGeneral
else
LDFLAGS += -L../General/PajeGeneral.framework -lPajeGeneral
endif

Paje_MAIN_MODEL_FILE = Paje.gorm

Paje_RESOURCE_FILES = \
        Paje.gorm \
        Paje.nib \
        Paje.tiff \
        traceFilePaje.tiff \
        PajeInfo.plist \
        ../SpaceTimeViewer/near.tiff \
        ../SpaceTimeViewer/distant.tiff \
        ../SpaceTimeViewer/toselection.tiff \
        ../General/PajeEntityInspector.gorm \
        ../General/PajeEntityInspector.nib

Paje_OBJC_FILES = PajeController.m PajeTraceController.m PajeCheckPoint.m
Paje_OBJC_FILES += Paje_main.m

Paje_HEADER_FILES = PajeController.h PajeTraceController.h PajeCheckPoint.h

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble
