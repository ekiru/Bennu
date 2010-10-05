use MooseX::Declare;
use 5.010;

role Bennu::Compiler::LiftDecls {
    use MooseX::MultiMethods;

    use Bennu::Decl qw(ClassDecl);
    use Bennu::MOP;

    method scope_object ($scope) {
        given ($scope) {
            when ('our') {
                return $self->PACKAGE;
            }
            default {
                die "No scope object for scope $scope."
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
}
