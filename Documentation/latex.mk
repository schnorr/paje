
LATEX_FILES?=$(wildcard *.tex)

LATEX_MASTER?=$(LATEX_FILES)

all: $(LATEX_MASTER:%.tex=%.ps)

%.pdf: %.dvi
	dvipdf $*

%.ps: %.dvi
	dvips $* -o

%.dvi: %.tex
	latex $*.tex

.PHONY: clean
clean::
	$(RM) $(foreach suffix,.log .aux .toc .bbl .blg .ind .idx .ilg .dvi .ps, \
		$(addsuffix $(suffix),$(LATEX_FILES:%.tex=%)))
