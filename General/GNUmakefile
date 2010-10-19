#BUNDLE_INSTALL_DIR=$(GNUSTEP_BUNDLES)/Paje

include $(GNUSTEP_MAKEFILES)/common.make

FRAMEWORK_NAME = General

LIBRARIES_DEPEND_UPON += $(FND_LIBS) $(GUI_LIBS) $(OBJC_LIBS)

General_OBJC_FILES = \
	Comparing.m \
	FilteredEnumerator.m \
	PSortedArray.m \
	TranslationTable.m \
	PTime.m \
	NSUserDefaults+Additions.m \
	NSColor+Additions.m \
	ColoredSwitchButtonCell.m \
	NSString+Additions.m \
	NSMatrix+Additions.m \
	NSObject+Additions.m \
	NSArray+Additions.m \
	UniqueString.m \
	NSDate+Additions.m \
	MultiEnumerator.m \
	SourceCodeReference.m \
	NSDictionary+Additions.m \
	PajeFilter.m \
	HierarchyBrowser.m \
	PajeType.m \
	PajeContainer.m \
	PajeEntity.m \
	PajeEntityInspector.m \
	GNUstep+Additions.m \
	DataScanner.m \
	PajeEvent.m \
	SourceTextController.m \
	Association.m \
	CondensedEntitiesArray.m \
	EntityChunk.m \
	ChunkArray.m \
	CStringCallBacks.m

General_HEADER_FILES = \
	Comparing.h \
	FilteredEnumerator.h \
	Protocols.h \
	PSortedArray.h \
	TranslationTable.h \
	PTime.h \
	NSUserDefaults+Additions.h \
	NSColor+Additions.h \
	ColoredSwitchButtonCell.h \
	NSString+Additions.h \
	NSMatrix+Additions.h \
	NSObject+Additions.h \
	NSArray+Additions.h \
	UniqueString.h \
	FoundationAdditions.h \
	NSDate+Additions.h \
	MultiEnumerator.h \
	Macros.h \
	SourceCodeReference.h \
	NSDictionary+Additions.h \
	PajeFilter.h \
	HierarchyBrowser.h \
	PajeType.h \
	PajeContainer.h \
	PajeEntity.h \
	PajeEntityInspector.h \
	DataScanner.h \
	PajeEvent.h \
	SourceTextController.h \
	Association.h \
	CondensedEntitiesArray.h \
	EntityChunk.h \
	ChunkArray.h\
	CStringCallBacks.h

General_RESOURCE_FILES = \
	HierarchyBrowser.gorm \
	HierarchyBrowser.nib \
	PajeEntityInspector.gorm \
	PajeEntityInspector.nib \
	SourceTextViewer.gorm \
	SourceTextViewer.nib

PROJECT_HEADERS = \
	Protocols.h \
	PSortedArray.h \
	FilteredEnumerator.h \
	TranslationTable.h \
	PTime.h \
	NSUserDefaults+Colors.h \
	ColoredButtonCell.h \
	UniqueString.h \
	FoundationAdditions.h \
	MultiEnumerator.h \
	Macros.h \
	EntityDescriptor.h \
	SourceCodeReference.h \
	NSDictionary+Additions.h \
	NSString+Additions.h \
	NSArray+Additions.h \
	PajeFilter.h \
	CondensedEntitiesArray.h \
	EntityChunk.h \
	ChunkArray.h\
	CStringCallBacks.h

-include GNUmakefile.preamble
#include $(GNUSTEP_MAKEFILES)/bundle.make
include $(GNUSTEP_MAKEFILES)/framework.make
-include GNUmakefile.postamble
