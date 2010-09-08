role Bennu::Compiler::Compile;

method compilefile($file) {
    self.parsefile($file);
}

method compile($source) {
    self.parse($source);
}
