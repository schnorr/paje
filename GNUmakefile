GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_USER_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Paje
VERSION = 1.2.0

AGGREGATE_NAME = Paje

SUBPROJECTS = \
	General \
	Paje \
	FileReader \
	PajeEventDecoder \
	PajeSimulator \
	StorageController \
	EntityTypeFilter \
	ContainerFilter \
	OrderFilter \
	ReductionFilter \
	ImbricationFilter \
	SpaceTimeViewer

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble
