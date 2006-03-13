GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Paje
VERSION = 1.4.0

AGGREGATE_NAME = Paje

SUBPROJECTS = \
	General \
	Paje \
	FileReader \
	PajeEventDecoder \
	PajeSimulator \
	StorageController \
	EntityTypeFilter \
	FieldFilter \
	ContainerFilter \
	OrderFilter \
	ReductionFilter \
	ImbricationFilter \
	SpaceTimeViewer \
	StatViewer

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble
