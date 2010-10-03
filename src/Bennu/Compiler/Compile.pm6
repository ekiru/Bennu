role Bennu::Compiler::Compile;

method compilefile($file) {
    my $ast = self.parsefile($file);
    $ast = self.lift-decls($ast);
}

method compile($source) {
    my $ast = self.parse($source);
    $ast = self.lift-decls($ast);
}
