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

class Bennu::Mu is rw {
    has Bennu::REPR $._REPR .= new;
    # Fake attributes are stored in the _REPR.
    # has ClassHOW $.HOW;
    # has ClassWHAT $.WHAT;
}

class Bennu::REPR {
    has %.storage;
}

# Metamodel-level classes.
# class ClassHOW is Mu {
    # has Str $.name;
    # has Method @.methods;
    # has Attribute @.attributes;
    # has ClassHOW @.parents;
# }

# class ClassWHAT is Mu {
#
# }

# class Attribute is Mu {
    # has Str $.name;
# }

# class Method is Mu {
    # has Str $.name;
    # has &.code;
# }

module Bennu;

# Type objects for the metamodel types.
our Bennu::Mu $Mu;
our Bennu::Mu $REPR;
our Bennu::Mu $ClassHOW;
our Bennu::Mu $ClassWHAT;
our Bennu::Mu $Attribute;
our Bennu::Mu $Method;

# ClassHOW objects for the metamodel types
our Bennu::Mu $HOWMu;
our Bennu::Mu $HOWREPR;
our Bennu::Mu $HOWClassHOW;
our Bennu::Mu $HOWClassWHAT;
our Bennu::Mu $HOWAttribute;
our Bennu::Mu $HOWMethod;

our sub get-attribute (Bennu::Mu $self, Str $attr) {
    $self._REPR.storage{$attr};
}

our sub set-attribute (Bennu::Mu $self, Str $attr, $value) {
    $self._REPR.storage{$attr} = $value;
}

our Bennu::ClassHOW sub ClassHOW-create (Str $name) {
    my $classHOW .= new;
    set-attribute $classHOW, 'ClassHOW::$!name', $name;
    set-attribute $classHOW, 'Mu::!HOW', $HOWClassHOW;
    $classHOW;
}

our sub ClassHOW-add-parent (Bennu::Mu $self, Bennu::Mu $parent) {
    get-attribute($self, 'ClassHOW::@!parents').push($parent);
}

our sub metamodel-init () {
    $HOWClassHOW = ClassHOW-create('ClassHOW');
    set-attribute $HOWClassHOW, 'Mu::$!HOW', $HOWClassHOW;

    $HOWMu = ClassHOW-create('Mu');
    classHOW-add-parent($HOWClassHOW, $HOWMu);
    ...
}
