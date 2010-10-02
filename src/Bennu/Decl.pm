use MooseX::Declare;

class Bennu::Decl {
    has scope => (is => 'rw', builder => '_build_scope');
}

class Bennu::Decl::Class extends Bennu::Decl {
    has name => (is => 'ro');
    has body => (is => 'ro');
    has traits => (is => 'ro', default => sub { [] });

    method _build_scope () { 'our' }
}

class Bennu::Decl::Method extends Bennu::Decl {
    has name => (is => 'ro');
    has body => (is => 'ro');
    has traits => (is => 'ro', default => sub { [] });

    method _build_scope () { 'has' }

    method default_signature ($class:) { return; }
}

class Bennu::Decl::Variable extends Bennu::Decl {
    has variable => (is => 'ro');
    has traits => (is => 'ro', default => sub { [] });

    method _build_scope () { 'my' }
}
