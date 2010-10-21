use MooseX::Declare;

role Bennu::Compiler::State {
    use Bennu::MOP;

    has _STATE_CLASS => (is => 'ro', default => sub { [] });

    has _STATE_PACKAGE =>
      (is => 'ro',
       default => sub { [Bennu::MOP::Package->new(name => 'GLOBAL')] });
    has _STATE_SCOPE =>
      (is => 'ro', lazy => 1,
       default => method () {
           [Bennu::MOP::Scope->new(outer => $self->_STATE_PACKAGE->[0])];
       });

    method CLASS () { $self->_STATE_CLASS()->[-1] }

    method PUSH_CLASS ($class) {
        push @{ $self->_STATE_CLASS() }, $class;
    }

    method POP_CLASS () {
        pop @{ $self->_STATE_CLASS() };
    }

    method PACKAGE () { $self->_STATE_PACKAGE()->[-1] }

    method PUSH_PACKAGE ($package) {
        push @{ $self->_STATE_PACKAGE() }, $package;
    }

    method POP_PACKAGE () {
        pop @{ $self->_STATE_PACKAGE() };
    }

    method SCOPE () { $self->_STATE_SCOPE()->[-1] }

    method PUSH_SCOPE ($class) {
        push @{ $self->_STATE_SCOPE() }, $class;
    }

    method POP_SCOPE () {
        pop @{ $self->_STATE_SCOPE() };
    }
}
