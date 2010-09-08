use MooseX::Declare;

class Bennu::AST {

}

class Bennu::AST::CompilationUnit is Bennu::AST {
    has statementlist => (is => 'ro');
}

# Statement-ish ASTS

class Bennu::AST::StatementList is Bennu::AST {
    has children => (is => 'ro', default => sub { [] });

    method push($child) {
        push @{$self->children}, $child;
    }
}

class Bennu::AST::Labelled is Bennu::AST {
    has statement => (is => 'ro');
}

# Compound expression ASTs

class Bennu::AST::Call is Bennu::AST {
    has function => (is => 'ro', isa => 'Str');
    has args => (is => 'ro', default => sub { [] });
}

# Lexical variable lookups

class Bennu::AST::Lexical is Bennu::AST {
    has name => (is => 'ro', isa => 'Str');
}

# Literal-ish data structures

class Bennu::AST::Parcel is Bennu::AST {

}

# Numbers

class Bennu::AST::Integer is Bennu::AST {
    has value => (is => 'ro', isa => 'Int');
}

class Bennu::AST::NaN is Bennu::AST {

}

class Bennu::AST::Inf is Bennu::AST {

}
