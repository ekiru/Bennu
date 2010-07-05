use v6;

use SIC::Grammar;

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

ok ($/ = SIC::Grammar.parse($sic)), 'Parses the SIC for "say 42;".';
ok $<version_line><version> eq '2010.08', 'Parses the version line.';
