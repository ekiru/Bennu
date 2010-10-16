role Bennu::Compiler::LiftDecls;

use Bennu::AST;
use Bennu::Decl;
use Bennu::MOP;

multi method scope-object('has') { $.CLASS }

multi method scope-object('our') {
    $.PACKAGE;
}

multi method scope-object($scope) {
    die "No scope object for '$scope' scope.";
}

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

multi method lift-decls (Bennu::Decl::Method $meth-decl) {
    die "Method traits not yet implemented."
      if $meth_decl.traits.elems;
    die "Non-has-scoped methods not yet implemented."
      unless $meth_decl.scope eq 'has';
    my $method = $meth-decl.Method;
    my $WHAT = $.scope-object('has');
    $WHAT.how.add-method($WHAT, $method);
    $.PUSH-SCOPE($method);
    LEAVE { $.POP-SCOPE }
    $method.body = $.lift-decls($meth-decl.body);
    $method;
}

multi method lift-decls (Bennu::Decl::Variable $variable) {
    die "Variable traits not yet implemented."
      if $variable.traits.elems;
    if ($variable.scope eq 'has') {
        die "Lexical aliases for private variables not twr implemented."
          unless $variable.twigil eq '.'|'!';
        my $WHAT = $.scope-object($variable.scope);
        $WHAT.how.add-attribute($WHAT, $variable.Attribute);
        return Bennu::AST::Noop.new; # This might be wrong.
    }
    else {
        die "Not yet implemented variable type.";
    }
}
