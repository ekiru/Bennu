use MooseX::Declare;

role Bennu::Compiler::LiftDecls {
    method lift_decls ($ast) {
        $ast;
    }
}
