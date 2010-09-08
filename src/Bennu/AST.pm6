class Bennu::AST;

class CompilationUnit is Bennu::AST {
    has $.statementlist;
}

# Statement-ish ASTS

class StatementList is Bennu::AST {
    has @.statements handles <push> = [] ;
}

class Labelled is Bennu::AST {
    has $.statement;
}

# Compound expression ASTs

class Call is Bennu::AST {
    has $.function;
    has @.args;
}

# Lexical variable lookups

class Lexical is Bennu::AST {
    has Str $.name;
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
