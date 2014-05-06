FILES=contract.ps
TOP=/tc/work/PP

#
# This is designed to be included from a lower level directory
# TOP should be defined to the top of the PP tree
# FILES should be define to the desired targets (.ps or .pdf files)

TEXINPUTS=:.
FILTER=$(TOP)/bin/tidyop.pl
LATEX2HTML=latex2html -html_version 4.0,math,frame \
	-show_section_numbers  -accent_images textrm \
	-local_icons -bottom_navigation


%.ps:		%.dvi
		dvips -f <$< >$@

%.dvi:		%.tex tccontract.cls
		latex $* | $(FILTER)
		latex $* >/dev/null
		latex $* | $(FILTER)
		rm $*.aux $*.log

%.tex:		%.tip
		pic -t <$< >$@

%.tex:		%.notes
		pic -t <$< >$@

%.pdf:		%.ps
		ps2pdf  $*.ps > $@

%.html:		%.tex
		latex $* | $(FILTER)
		latex $* >/dev/null
		$(LATEX2HTML) -dir $@ $<

all:		$(FILES)

clean:
		rm -fr *.pdf *.ps *.log *.aux *.dvi *~ *.html
		[ -r *.notes ] && rm -f *_notes.tex


