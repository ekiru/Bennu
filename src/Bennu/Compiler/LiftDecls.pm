use MooseX::Declare;
use 5.010;

role Bennu::Compiler::LiftDecls {
    use MooseX::MultiMethods;

    use Bennu::AST;
    use Bennu::Decl qw(ClassDecl MethodDecl VariableDecl);
    use Bennu::MOP;

    method scope_object ($scope) {
        given ($scope) {
            when ('has') {
                return $self->CLASS;
            }
            when ('our') {
                return $self->PACKAGE;
            }
            default {
                die "No scope object for '$scope' scope."
            }
        }
    }

    multi method lift_decls ($ast) {
        $ast->walk(sub { $self->lift_decls($_[0]) });
    }

    multi method lift_decls(ClassDecl $class) {
        # First, we need to separate the traits that must be applied
        # before creating the class object from those that must be applied
        # after creating it.
        my (@decl_traits, @class_traits);
        for my $trait (@{ $class->traits }) {
            if ($trait->isa('Bennu::Decl::Trait')) {
                push @decl_traits, $trait;
            } else {
                push @class_traits, $trait;
            }
        }

        # Now we can apply the pre-meta-object traits.
        for my $trait (@decl_traits) {
            $trait->apply($class);
        }

        # Build the class meta-objects and properly connect them.
        my $how = Bennu::MOP::ClassHOW->new(name => $class->name);
        my $what = $how->new_type_object;
        my $who = Bennu::MOP::Package->new(name => $class->name);
        $what->who($who);

        # Now we can apply the traits that can be applied directly to
        # the type-object. This might be wrong.
        for my $trait (@class_traits) {
            $trait->apply($who);
        }

        # Set up the type-object and the package in the scope.
        $self->scope_object($class->scope)->assign_static($class->name, $what);
        my @package_name = @{ $class->name };
        $package_name[-1] .= '::';
        $self->scope_object($class->scope)->assign_static(\@package_name, $who);

        # Walk the children.
        $self->PUSH_CLASS($what);
        $self->PUSH_PACKAGE($what->who);
        my $ast = $self->lift_decls($class->body);
        $self->POP_CLASS;
        $self->POP_PACKAGE;
        $ast;
    }

    multi method lift_decls (MethodDecl $meth_decl) {
        die "Method traits not yet implemented."
          if scalar @{ $meth_decl->traits };
        die "Non-has-scoped methods not yet implemented."
          unless $meth_decl->scope eq 'has';
        my $method = $meth_decl->Method;
        my $WHAT = $self->scope_object('has');
        $WHAT->how->add_method($WHAT, $method);
        $self->PUSH_SCOPE($method);
        $method->body($self->lift_decls($meth_decl->body));
        $self->POP_SCOPE;
        $method;
    }

    multi method lift_decls(VariableDecl $variable) {
        die "Variable traits not yet implemented."
          if scalar @{ $variable->traits };
        if ($variable->scope eq 'has') {
            die "Lexical aliases for private variables not twr implemented."
              unless $variable->twigil ~~ ['.', '!'];
            my $WHAT = $self->scope_object($variable->scope);
            my $attribute = $variable->Attribute;
            $WHAT->how->add_attribute($WHAT, $attribute);
            return Bennu::AST::Noop->new;
        }
        else {
            die "Not yet implemented variable type.";
        }
    }
}
