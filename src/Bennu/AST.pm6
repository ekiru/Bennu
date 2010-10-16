class Bennu::AST;

class CompilationUnit is Bennu::AST {
    has $.statementlist handles <walk>;
}

# Blocky ASTs

class Block is Bennu::AST {
    has $.body;
}

# Statement-ish ASTS

class StatementList is Bennu::AST {
    has @.statements handles <push> = [] ;

    method walk (&cb) {
        for @.statements -> $statement is rw {
            $statement .= &cb;
        }
        self;
    }
}

class Conditional is Bennu::AST {
    has @.conditions;
    has @.blocks;
    has $.otherwise is rw;

    method walk (&cb) {
        for @.conditions -> $condition is rw {
            $condition .= &cb;
        }
        for @.blocks -> $block is rw {
            $block .= &cb;
        }
        $.otherwise .= &cb;
        self;
    }
}

class Labelled is Bennu::AST {
    has $.statement;
}

class Noop is Bennu::AST {

}

# Compound expression ASTs

class Call is Bennu::AST {
    has $.function;
    has @.args;
}

class MethodCall is Bennu::AST {
    has $.name;
    has @.args handles <unshift>;
}

# Lexical variable lookups

class Lexical is Bennu::AST {
    has Str $.desigilname;
    has $.twigil is rw = '';
    has $.sigil = '';
}

# Literal-ish data structures

class Parcel is Bennu::AST {

}

# Numbers

class Integer is Bennu::AST {
    has Int $.value;
}

class NaN is Bennu::AST {

}

class Inf is Bennu::AST {

}
