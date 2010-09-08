use MooseX::Declare;
use v5.10.0;

role Bennu::Compiler::Compile {
    requires 'parsefile';
    requires 'parse';

    method compilefile($file) {
        return $self->parsefile($file);
    }

    method compile($source) {
        return $self->parse($source);
    }
}
