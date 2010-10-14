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
}

class Variable is Bennu::Decl {
  has $.variable handles <desigilname sigil twigil>;
  has @.traits;
  has @.constraints; # type constraints

  submethod BUILD (:$.scope = 'my') { }

  method add-constraint ($constraint) {
      @.constraints.push($constraint);
  }
}
