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
        my $how = Bennu::MOP::ClassHOW->new(name => $class->name);
        my $what = $how->new_type_object;
        die "Class traits not yet implemented."
          if scalar @{ $class->traits };
        $self->scope_object($class->scope)->assign_static($class->name, $what);
        $self->PUSH_PACKAGE($what);
        my $ast = $self->lift_decls($class->body);
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
