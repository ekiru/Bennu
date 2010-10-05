use MooseX::Declare;

role Bennu::Compiler::State {
    has _STATE_CLASS => (is => 'ro', default => sub { [] });

    method CLASS () { $self->_STATE_CLASS()->[-1] }

    method PUSH_CLASS ($class) {
        push @{ $self->_STATE_CLASS() }, $class;
    }

    method POP_CLASS () {
        pop @{ $self->_STATE_CLASS() };
    }
}
