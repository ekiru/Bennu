use MooseX::Declare;

class Bennu::MOP::Mu {
    has how => (is => 'rw');
}

class Bennu::MOP::Package extends Bennu::MOP::Mu {
    has name => (is => 'ro');
    has static_definitions => (is => 'ro', default => sub { {} });
    has static_names => (is => 'ro', default => sub { {} });

    method assign_static($name, $value) {
        $self->static_names->{$name} = 1;
        $self->static_definitions->{$name} = $value;
    }
}

class Bennu::MOP::ClassWHAT extends Bennu::MOP::Package {
    method defined() { 0 }
    method type() { 'class' }
}

class Bennu::MOP::ClassHOW extends Bennu::MOP::Mu {
    has name => (is => 'rw');

    method new_type_object() {
        Bennu::MOP::ClassWHAT->new(how => $self, name => $self->name);
    }

    method add_attribute($obj, $attribute) {...}
}
