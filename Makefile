# Shamelessly stolen from http://github.com/masak/yapsi/blob/master/Makefile
# With alpha replaced with perl6 & SOURCES changed to my sources.

PERL6 = perl6

SOURCES=lib/SIC/AST.pm lib/SIC/Grammar.pm \
	lib/SIC/Actions.pm lib/SIC/Compiler.pm

PIRS=$(SOURCES:.pm=.pir)

all: $(PIRS)

%.pir: %.pm
	env PERL6LIB=`pwd`/lib $(PERL6) --target=pir --output=$@ $<

clean:
	rm -f $(PIRS)

test: all
	env PERL6LIB=`pwd`/lib prove -e '$(PERL6)' -r --nocolor t/
