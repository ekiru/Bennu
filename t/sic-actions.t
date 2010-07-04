use v6;

use SIC::Grammar;
use SIC::Actions;
use SIC::AST;

use Test;

plan 2;

my $sic =
    'This is SIC v2010.08' ~"\n" ~
    "\n" ~
    'environment:' ~ "\n" ~
    '    main:' ~ "\n" ~
    '    containers: []' ~ "\n" ~
    "\n" ~
    'block \'main\':' ~ "\n" ~
    '    $0 = 42' ~ "\n" ~
    '    say $0' ~ "\n";

my $parse = SIC::Grammar.parse($sic, :actions(SIC::Actions.new));

isa_ok $parse.ast, SIC::AST::File,
    'TOP.ast correctly produces a File AST.';
is $parse.ast.version, '2010.08', 'Correct version for the AST.';
