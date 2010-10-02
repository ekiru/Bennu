use MooseX::Declare;

class Bennu::Decl {
    has scope => (is => 'rw');
}

class Bennu::Decl::Class extends Bennu::Decl {
    has name => (is => 'ro');
    has body => (is => 'ro');
    has traits => (is => 'ro', default => sub { [] });
}

class Bennu::Decl::Variable extends Bennu::Decl {
    has variable => (is => 'ro');
    has traits => (is => 'ro', default => sub { [] });
}
