use MooseX::Declare;

role Bennu::Compiler::LiftDecls {
    use MooseX::MultiMethods;

    use Bennu::Decl qw(ClassDecl);
    use Bennu::MOP;

    multi method lift_decls ($ast) {
        $ast->walk(sub { $self->lift_decls($_[0]) });
    }

    multi method lift_decls(ClassDecl $class) {
        my $how = Bennu::MOP::ClassHOW->new(name => $class->name);
        my $what = $how->new_type_object;
        die "Class traits not yet implemented."
          if scalar @{ $class->traits };
        $self->PUSH_CLASS($what);
        my $ast = $self->lift_decls($class->body);
        $self->POP_CLASS;
        $ast;
    }
}
