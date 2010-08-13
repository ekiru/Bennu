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

class Bennu::Mu {
    has Bennu::REPR $._REPR;
    # Fake attributes are stored in the _REPR.
    # has ClassHOW $.HOW;
    # has ClassWHAT $.WHAT;

    submethod BUILD () {
        $!_REPR = Bennu::REPR.new;
    }
}

class Bennu::REPR {
    has %.storage;
};

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

our Bennu::Mu sub Mu-new (Bennu::Mu $WHAT, Bennu::Mu $HOW) {
    my Bennu::Mu $self .= new;
    set-attribute $self, 'Mu::$!HOW', $HOW;
    set-attribute $self, 'Mu::$!WHAT', $WHAT;
    $self;
}

our sub Mu-HOW (Bennu::Mu $self) {
    get-attribute $self, 'Mu::$!HOW';
}

our sub Mu-WHAT (Bennu::Mu $self) {
    get-attribute $self, 'Mu::$!WHAT';
}

our sub ClassHOW-new (Bennu::Mu $WHAT, Str $name) {
    my $self = Mu-new $ClassHOW, $HOWClassHOW;
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

our sub ClassHOW-add-method (Bennu::Mu $self, Bennu::Mu $method) {
    get-attribute($self, 'ClassHOW::@!methods').push($method);
}

# Wrong MRO currently but we can fix that later.
our sub ClassHOW-find-method (Bennu::Mu $self, Str $name) {
    for get-attribute($self, 'ClassHOW::@!methods') -> $method {
        return $method if $method.name eq $name;
    }
    for get-attribute($self, 'ClassHOW::@!parents') -> $parent {
        my $method = send $parent, 'find-method', $name;
        return $method if $method;
    }
    die "Method $name not found in class {get-attribute $self, 'ClassHOW::$!name'}";
}

our sub Protoobject-new (Bennu::Mu $WHAT, Bennu::Mu $HOW) {
    my $self = Mu-new $WHAT, $HOWClassHOW;
    set-attribute $self, 'Mu::$!WHAT', $self;
    $self;
}

our sub Attribute-new (Bennu::Mu $WHAT, Str $name) {
    my $self = Mu-new $Attribute, $HOWAttribute;
    set-attribute $self, 'Attribute::$!name', $name;
    $self;
}

our sub Method-new (Bennu::Mu $WHAT, Str $name, &code) {
    my $self = Mu-new $Method, $HOWMethod;
    set-attribute $self, 'Method::$!name', $name;
    set-attribute $self, 'Method::&!code', &code;
    $self;
}

our sub send (Bennu::Mu $self, Str $method-name, *@args) {
    my $method;
    if $method-name eq 'find-method'
      && Mu-HOW($self) === $HOWClassHOW {
        $method = ClassHOW-find-method $self, $method;
    } else {
        $method = send Mu-HOW($self), 'find-method', $method-name;
    }
    get-attribute($method, 'Method::&!code').($self, |@args);
}

our sub metamodel-init () {
    $HOWClassHOW = ClassHOW-new $ClassHOW, 'ClassHOW';
    set-attribute $HOWClassHOW, 'Mu::$!HOW', $HOWClassHOW;

    $ClassHOW = Protoobject-new $ClassHOW, $HOWClassHOW;
    set-attribute $HOWClassHOW, 'Mu::$!WHAT', $ClassHOW;

    $HOWMu = ClassHOW-new $ClassHOW, 'Mu';
    ClassHOW-add-parent $HOWClassHOW, $HOWMu;
    $Mu = Protoobject-new $Mu, $HOWMu;

    $HOWAttribute = ClassHOW-new $ClassHOW, 'Attribute';
    ClassHOW-add-parent $HOWAttribute, $HOWMu;
    $Attribute = Protoobject-new $Attribute, $HOWAttribute;

    ClassHOW-add-attribute $HOWMu, Attribute-new($Attribute, 'Mu::$!HOW');
    ClassHOW-add-attribute $HOWMu, Attribute-new($Attribute, 'Mu::$!WHAT');
    ClassHOW-add-attribute $HOWClassHOW, Attribute-new($Attribute, 'ClassHOW::$!name');
    ClassHOW-add-attribute $HOWClassHOW, Attribute-new($Attribute, 'ClassHOW::@!methods');
    ClassHOW-add-attribute $HOWClassHOW, Attribute-new($Attribute, 'ClassHOW::@!attributes');
    ClassHOW-add-attribute $HOWClassHOW, Attribute-new($Attribute, 'ClassHOW::@!parents');
    ClassHOW-add-attribute $HOWAttribute, Attribute-new($Attribute, 'Attribute::$!name');

    $HOWMethod = ClassHOW-new $ClassHOW, 'Method';
    ClassHOW-add-parent $HOWMethod, $HOWMu;
    $Method = Protoobject-new $Method, $HOWMethod;
    ClassHOW-add-attribute $HOWMethod, Attribute-new($Attribute, 'Method::$!name');
    ClassHOW-add-attribute $HOWMethod, Attribute-new($Attribute, 'Method::&!code');

    ClassHOW-add-method $HOWMu, Method-new($Method, 'HOW', &Mu-HOW);
    ClassHOW-add-method $HOWMu, Method-new($Method, 'WHAT', &Mu-WHAT);
    ClassHOW-add-method $HOWClassHOW, Method-new($Method, 'add-method', &ClassHOW-add-method);
}

metamodel-init();
