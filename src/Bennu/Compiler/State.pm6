role Bennu::Compiler::State;

my @!CLASS;

method CLASS { @!CLASS[*-1] }

method PUSH-CLASS ($class) {
    @!CLASS.push($class);
}

method POP-CLASS {
    @!CLASS.pop;
}
