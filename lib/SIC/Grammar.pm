grammar SIC::Grammar;

token TOP { 
    ^
    <version_line>
    <.newline> ** 2
    <environment>
    <.newline>
    <block> ** [<.newline> <.newline>]
#    <.ws> $
}

token newline { "\n" }

token indent { "    " }

token version_line {
    'This is SIC v' <version>
    || <.panic: 'Invalid version line.'>
}

token version { (\d\d\d\d '.' \d\d) }
    
token environment {
    'environment:' <.newline>
      [<indent> <pad>]+
      <indent> 'containers:' <.ws> "\[" '"Any()"'? "]" <.newline>
}

token pad {
    <ident> ':' <.newline>
      [<.ws> <pad_variable> <.newline>]*
}

token pad_variable {
    "\$" <alpha>+ ':' <.ws> '{' <.ws>? '"n" => ' [$<number>=\d+] ',' <.ws>
      '"type" => "container"' <.ws>? '}'
}

token block {
    'block' <.ws> "'" <ident> "':" <.newline>
      [<.ws> <statement>]**<.newline>
}

proto token statement {...}

token statement:sym<=> { <register> <.ws> <sym> <.ws> <value> }
token statement:sym<say> { <sym> <.ws> <register> }
token statement:sym<store> {
    <sym> <.ws> "'\$" (<alpha>+) "'," <.ws> <register>
}

token register { "\$" (\d+) }

proto token value {...}

token value:sym<constant> { (\d+) }
token value:sym<fetch> { <sym> <.ws> "'\$" (<alpha>+) "'" }
