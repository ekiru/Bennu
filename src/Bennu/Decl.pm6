class Bennu::Decl;

has $.scope is rw;

class Class is Bennu::Decl {
    has $.name;
    has $.body;
    has @.traits;
}

class Variable is Bennu::Decl {
  has $.variable;
  has @.traits;
}
