use MooseX::Declare;

class Bennu::Decl {
    use MooseX::Types -declare => [qw(ClassDecl VariableDecl)];

    class_type ClassDecl, { class => 'Bennu::Decl::Class' };

    class_type VariableDecl, { class => 'Bennu::Decl::Variable' };

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
    use Bennu::MOP;

    has variable => (is => 'ro', handles => [qw(desigilname sigil twigil)]);
    has traits => (is => 'ro', default => sub { [] });
    has constraints => (is => 'ro', default => sub { [] });

    method _build_scope () { 'my' }

    method add_constraint ($constraint) {
        push @{ $self->constraints }, $constraint;
    }

    method Attribute {
        Bennu::MOP::Attribute->new(name => $self->desigilname,
                                   private => $self->twigil ne '.',
                                   constraints => $self->constraints,
                                   traits => $self->traits);
    }
}
