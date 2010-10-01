use MooseX::Declare;

class Bennu::MOP::Mu {
    has how => (is => 'rw');
}

class Bennu::MOP::ClassHOW extends Bennu::MOP::Mu {
    method add_attribute($obj, $attribute) {...}
}
