PERL = perl

all: grammar

grammar: src/Bennu/Grammar.pmc

src/Bennu/Grammar.pmc: src/Bennu/Grammar.pm6
	viv --noperl6lib -5 -o src/Bennu/Grammar.pmc src/Bennu/Grammar.pm6
