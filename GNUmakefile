GNUSTEP_INSTALLATION_DOMAIN = USER

include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Paje
VERSION = 1.97

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
	StatViewer \
	AggregatingFilter

OTHERSRCS = Makefile.preamble Makefile Makefile.postamble

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/aggregate.make
-include GNUmakefile.postamble
