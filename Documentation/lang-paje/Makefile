
LATEX_MASTER=lang-paje.tex

include ../latex.mk

lang-paje.dvi: %.dvi: %.tex %.bib $(LATEX_FILES)
	latex $*
	bibtex $*
	makeindex $*
	latex $*
	latex $*
