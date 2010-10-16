use MooseX::Declare;

class Bennu::AST {

}

class Bennu::AST::CompilationUnit is Bennu::AST {
    has statementlist => (is => 'ro', handles => [qw(walk)]);
}

# Blocky ASTs

class Bennu::AST::Block is Bennu::AST {
    has body => (is => 'ro');
}

# Statement-ish ASTS

class Bennu::AST::StatementList is Bennu::AST {
    has statements => (is => 'ro', default => sub { [] });

    method push($child) {
        push @{$self->statements}, $child;
    }

    method walk($cb) {
        for (@{ $self->statements }) {
            $_ = $cb->($_);
        }
        $self;
    }
}

class Bennu::AST::Conditional is Bennu::AST {
    has conditions => (is => 'ro', default => sub { [] });
    has blocks => (is => 'ro', default => sub { [] });
    has otherwise => (is => 'rw');

    method walk($cb) {
        for (@{ $self->conditions }) {
            $_ = $cb->($_);
        }
        for (@{ $self->blocks }) {
            $_ = $cb->($_);
        }
        $self->otherwise($cb->($self->otherwise));
        $self;
    }
}

class Bennu::AST::Labelled is Bennu::AST {
    has statement => (is => 'ro');
}

class Bennu::AST::Noop is Bennu::AST {

}

# Compound expression ASTs

class Bennu::AST::Call is Bennu::AST {
    has function => (is => 'ro');
    has args => (is => 'ro', default => sub { [] });
}

class Bennu::AST::MethodCall is Bennu::AST {
    has name => (is => 'ro');
    has args => (is => 'rw', default => sub { [] });

    method unshift($arg) {
        unshift @{$self->args}, $arg;
    }

    method walk($cb) {
        for (@{ $self->args }) {
            $_ = $cb->($_);
        }
        $self;
    }
}

# Lexical variable lookups

class Bennu::AST::Lexical is Bennu::AST {
    has desigilname => (is => 'ro', isa => 'Str');
    has sigil => (is => 'ro', default => '');
    has twigil => (is => 'rw', default => '');

    method walk ($cb) {
        $self;
    }
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
