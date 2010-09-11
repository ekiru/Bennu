use MooseX::Declare;

class Bennu::Decl {

}

class Bennu::Decl::Variable is Bennu::Decl {
    has variable => (is => 'ro');
    has traits => (is => 'ro', default => sub { [] });
}
