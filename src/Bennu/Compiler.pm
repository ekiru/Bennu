use MooseX::Declare;

class Bennu::Compiler with (Bennu::Compiler::State, Bennu::Compiler::Compile, Bennu::Compiler::Parse, Bennu::Compiler::LiftDecls) {

}
