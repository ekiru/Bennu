module Bennu::MOP;

class Mu {
    has $.how is rw;
}

class ClassHOW is Mu {
    method add-attribute($obj, $attribute) {...}
}
