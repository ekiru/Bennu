use MooseX::Declare;

role Bennu::Compiler::State {
    use Bennu::MOP;

    has _STATE_PACKAGE =>
      (is => 'ro',
       default => sub { [Bennu::MOP::Package->new(name => 'GLOBAL')] });

    method CLASS () {
        for my $package (@{ $self->_STATE_PACKAGE }) {
            return $package if $package->type eq 'class';
        }
        die '::?CLASS not found.';
    }

    method PACKAGE () { $self->_STATE_PACKAGE()->[-1] }

    method PUSH_PACKAGE ($class) {
        push @{ $self->_STATE_PACKAGE() }, $class;
    }

    method POP_PACKAGE () {
        pop @{ $self->_STATE_PACKAGE() };
    }
}
