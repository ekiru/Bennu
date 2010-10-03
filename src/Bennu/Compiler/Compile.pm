use MooseX::Declare;
use v5.10.0;

role Bennu::Compiler::Compile {
    requires 'parsefile';
    requires 'parse';

    requires 'lift_decls';

    method compilefile($file) {
        my $ast = $self->parsefile($file);
        $ast = $self->lift_decls($ast);
    }

    method compile($source) {
        my $ast = $self->parse($source);
        $ast = $self->lift_decls($ast);
    }
}
