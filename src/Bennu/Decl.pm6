class Bennu::Decl;

has $.scope is rw;

class Class is Bennu::Decl {
    has $.name;
    has $.body;
    has @.traits;
    has Bool $.ll-class

    submethod BUILD (:$.scope = 'our', $!ll-class = False) { }
}
class Method is Bennu::Decl {
    has $.name;
    has $.body;
    has @.traits;

    submethod BUILD (:$.scope = 'has') { }

    method default_signature { return; }

    method Method {
         # Don't initialize body because it has to be lift-decl'ed first.
        Bennu::MOP::Method.new(:$.name, :@.traits);
    }
}

class Variable is Bennu::Decl {
    use Bennu::MOP;

    has $.variable handles <desigilname sigil twigil>;
    has @.traits;
    has @.constraints; # type constraints

    submethod BUILD (:$.scope = 'my') { }

    method add-constraint ($constraint) {
        @.constraints.push($constraint);
    }

    method Attribute {
        my $private = $.twigil ne '.';
        Bennu::MOP::Attribute.new(:name($.desigilname),
                                  :$private,
                                  :@.constraints,
                                  :@.traits);
    }
}

# Bennu::Decl::Trait is used to handle traits that must be processed
# prior to the declaration-lifting stage.
class Trait {
    method apply($obj) {...}
}

class LLClassTrait is Trait {
    method apply($class) {
        $class.ll-class = True;
        $class;
    }
}
