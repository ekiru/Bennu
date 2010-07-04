grammar SIC::Grammar {
    token TOP { ^
        <version_line>
        <.newline> ** 2
        <environment>
        <.newline>
        <block> ** [<.newline> <.newline>]
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
            [<indent> <pad> <.newline>]+
             <indent> 'containers:' \s+ '[]' <.newline>
    }

    token pad { <ident> ':' }

    token block {
        'block' \s+ "'" <ident> "':" <.newline>
            [\s+ <statement> ] ** [<.newline>]
    }

    proto token statement {...}

    token statement:sym<=> { <variable> <.ws> <sym> <.ws> <constant> }
    token statement:sym<say> { <sym> <.ws> <variable> }

    token variable { "\$" (\d+) }

    token constant { (\d+) }
}
