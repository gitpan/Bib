#------------------------------------------------------------
# Makefile for Text::Bib
#------------------------------------------------------------


# Replace this with the path to your Perl5 libraries.
#    Examples: /usr/lib/perl, or /usr/local/lib/perl.
PERL5LIB = 'EDIT YOUR MAKEFILE'


SHELL=/bin/sh


all: 
	@echo ""
	@echo "Choices are..."
	@echo "   make install   -- installs the library modules"
	@echo "   make test      -- runs the sample code"
	@echo ""

install:
	@if [ ! -d ${PERL5LIB} ]; then \
	  echo 'INVALID PERL5LIB: EDIT YOUR MAKEFILE!!!' ; exit -1;\
	fi
	if [ ! -d ${PERL5LIB}/Text ]; then \
	  mkdir ${PERL5LIB}/Text; \
	fi
	cp ./Text/Bib.pm ${PERL5LIB}/Text/

test:
	perl sample/sample < sample/sample.bib




# This is for my use only...

documented:
	(cd Text ; pod2html2 Bib.pm )
	mv Text/Bib.pm.html doc
	(cd Text ; pod2man Bib.pm > ../doc/Bib.pm.1 )

dist: documented
	mkdist -tgz Bib-`rcsversion Text/Bib.pm`	

#------------------------------------------------------------
