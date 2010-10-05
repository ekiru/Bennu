role Bennu::Compiler::LiftDecls;

use Bennu::Decl;
use Bennu::MOP;

multi method lift-decls ($ast) {
    $ast.walk({ self.lift-decls($_) });
}

multi method lift-decls (Bennu::Decl::Class $class) {
    my $how = Bennu::MOP::ClassHOW.new(:name($class.name));
    my $what = $how.new-type-object;
    die "Class traits not yet implemented."
      if $class.traits.elems;
    $.scope-object($class.scope).assign-static($class.name, $what);
    $.PUSH-PACKAGE($what);
    LEAVE { $.POP-PACKAGE }
    self.lift-decls($class.body);
}
