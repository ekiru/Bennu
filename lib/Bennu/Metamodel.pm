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
our Bennu::Mu $Attribute;
our Bennu::Mu $Method;

# ClassHOW objects for the metamodel types
our Bennu::Mu $HOWMu;
our Bennu::Mu $HOWREPR;
our Bennu::Mu $HOWClassHOW;
our Bennu::Mu $HOWAttribute;
our Bennu::Mu $HOWMethod;

our sub get-attribute (Bennu::Mu $self, Str $attr) {
    $self._REPR.storage{$attr};
}

our sub set-attribute (Bennu::Mu $self, Str $attr, $value) {
    $self._REPR.storage{$attr} = $value;
}

our Bennu::Mu sub Mu-new ($HOW, $WHAT) {
    my Bennu::Mu $self .= new;
    set-attribute $self, 'Mu::$!HOW', $HOW;
    set-attribute $self, 'Mu::$!WHAT', $WHAT;
    $self;
}

our sub ClassHOW-new (Str $name) {
    my $self = Mu-new $HOWClassHOW, $ClassHOW;
    set-attribute $self, 'ClassHOW::$!name', $name;
    set-attribute $self, 'ClassHOW::@!methods', [];
    set-attribute $self, 'ClassHOW::@!attributes', [];
    set-attribute $self, 'ClassHOW::@!parents', [];
    $self;
}

our sub ClassHOW-add-parent (Bennu::Mu $self, Bennu::Mu $parent) {
    get-attribute($self, 'ClassHOW::@!parents').push($parent);
}

our sub ClassHOW-add-attribute (Bennu::Mu $self, Bennu::Mu $attribute) {
    get-attribute($self, 'ClassHOW::@!attributes').push($attribute);
}

our sub Protoobject-new (Bennu::Mu $HOW) {
    my $self = Mu-new $HOW, Nil;
    set-attribute $self, 'Mu::$!WHAT', $self;
    $self;
}

our sub Attribute-new (Str $name) {
    Mu-new $HOWAttribute, $Attribute;
}

our sub metamodel-init () {
    $HOWClassHOW = ClassHOW-new('ClassHOW');
    set-attribute $HOWClassHOW, 'Mu::$!HOW', $HOWClassHOW;

    $ClassHOW = Protoobject-new $HOWClassHOW;
    set-attribute $HOWClassHOW, 'Mu::$!WHAT', $ClassHOW;

    $HOWMu = ClassHOW-new('Mu');
    classHOW-add-parent($HOWClassHOW, $HOWMu);
    $Mu = Protoobject-new($HOWMu);

    $HOWAttribute = ClassHOW-new('Attribute');
    ClassHOW-add-parent($HOWAttribute, $HOWMu);
    $Attribute = Protoobject-new $HOWAttribute;
    ...
}
