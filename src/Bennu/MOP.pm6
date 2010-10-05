module Bennu::MOP;

class Mu {
    has $.how is rw;
    has $.defined;
}

class ClassHOW is Mu {
    has $.name is rw;

    method new-type-object {
        Mu.new(:defined(False), :how(self));
    }

    method add-attribute($obj, $attribute) {...}
}
