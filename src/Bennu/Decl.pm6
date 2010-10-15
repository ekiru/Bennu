class Bennu::Decl;

has $.scope is rw;

class Class is Bennu::Decl {
    has $.name;
    has $.body;
    has @.traits;

    submethod BUILD (:$.scope = 'our') { }
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
