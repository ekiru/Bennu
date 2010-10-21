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
    # First, we need to separate the traits that must be applied
    # before creating the class object from those that must be applied
    # after creating it.
    my @decl-traits, @class-traits;
    for $class.traits -> $trait {
        if $trait ~~ Bennu::Decl::Trait {
            push @decl-traits, $trait;
        } else {
            push @class-traits, $trait;
        }
    }

    # Now we can apply the pre-meta-object traits.
    for @decl-traits -> $trait {
        $trait.apply($class);
    }

    # Build the class meta-objects and properly connect them.
    my $how = Bennu::MOP::ClassHOW.new(:name($class.name));
    my $what = $how.new-type-object;
    my $who = Bennu::MOP::Package.new(:name($class.name));
    $what.who = $who;

    # Now we can apply the traits that can be applied directly to
    # the type-object. This might be wrong.
    for @class-traits -> $trait {
        $trait.apply($who);
    }

    # Set up the type-object and the package in the scope.
    $.scope-object($class.scope).assign-static($class.name, $what);
    my $package-name = $class.name ~ '::';
    $.scope-object($class.scope).assign-static($package-name, $who);

    # Walk the children.
    $.PUSH-CLASS($what);
    $.PUSH-PACKAGE($who);
    LEAVE { $.POP-CLASS; $.POP-PACKAGE; }
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
