use v6;

# This is the beginning of a prototype, on top of Rakudo, of the meta-model
# I plan to implement for Bennu. If I'm lucky, this will either not be a
# terrible way to implement it or it will develop into a non-terrible way
# to implement it. If I'm *REALLY* lucky, This won't be too hard to nail
# down to something that I can bootstrap and generate C from.

# At least, hopefully it won't be too hard to translate it into something
# bootstrappable. 

class Bennu::Mu { ... }
class Bennu::REPR { ... }
class Bennu::ClassHOW { ... }
class Bennu::ClassWHAT { ... }
class Bennu::Attribute { ... }
class Bennu::Method { ... }

class Bennu::Mu is rw {
    has Bennu::REPR $._REPR .= new;
    # Fake attributes are stored in the _REPR.
    # has Bennu::ClassHOW $._HOW;
    # has Bennu::ClassWHAT $._WHAT;
}

class Bennu::REPR {
    has %.storage;
}

class Bennu::ClassHOW is Bennu::Mu {
    # has Str $.name;
    # has Bennu::Method @.methods;
    # has Bennu::Attribute @.attributes;
    # has Bennu::ClassHOW @.parents;
    # has Bennu::ClassREPR $.REPR;
}

class Bennu::ClassWHAT is Bennu::Mu {

}

class Bennu::Attribute is Bennu::Mu {
    # has Str $.name;
}

class Bennu::Method is Bennu::Mu {
    # has Str $.name;
    # has &.code;
}

module Bennu;

# Type objects for the metamodel types.
our Bennu::ClassWHAT $Mu;
our Bennu::ClassWHAT $REPR;
our Bennu::ClassWHAT $ClassHOW;
our Bennu::ClassWHAT $ClassWHAT;
our Bennu::ClassWHAT $Attribute;
our Bennu::ClassWHAT $Method;

# ClassHOW objects for the metamodel types
our Bennu::ClassHOW $HOWMu;
our Bennu::ClassHOW $HOWREPR;
our Bennu::ClassHOW $HOWClassHOW;
our Bennu::ClassHOW $HOWClassWHAT;
our Bennu::ClassHOW $HOWAttribute;
our Bennu::ClassHOW $HOWMethod;

our sub get-attribute (Bennu::Mu $self, Str $attr) {
    $self._REPR.storage{$attr};
}

our sub set-attribute (Bennu::Mu $self, Str $attr, $value) {
    $self._REPR.storage{$attr} = $value;
}

our Bennu::ClassHOW sub ClassHOW-create (Str $name) {
    my Bennu::ClassHOW $classHOW .= new;
    set-attribute $classHOW, 'ClassHOW::$!name', $name;
    set-attribute $classHOW, 'Mu::!HOW', $HOWClassHOW;
    $classHOW;
}

our sub ClassHOW-add-parent (Bennu::ClassHOW $self, Bennu::ClassHOW $parent) {
    get-attribute($self, 'ClassHOW::@!parents').push($parent);
}

our sub metamodel-init () {
    $HOWClassHOW = ClassHOW-create('ClassHOW');
    set-attribute $HOWClassHOW, 'Mu::$!HOW', $HOWClassHOW;

    $HOWMu = ClassHOW-create('Mu');
    classHOW-add-parent($HOWClassHOW, $HOWMu);
    ...
}
