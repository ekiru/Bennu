use MooseX::Declare;

class Bennu::MOP::Mu {
    has how => (is => 'rw');
    has defined => (is => 'ro');
}

class Bennu::MOP::ClassHOW extends Bennu::MOP::Mu {
    has name => (is => 'rw');

    method new_type_object() {
        Bennu::MOP::Mu->new(defined => 0, how => $self);
    }

    method add_attribute($obj, $attribute) {...}
}
