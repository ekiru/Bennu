use MooseX::Declare;
use v5.10.0;

role Bennu::Compiler::Parse {
    use Bennu::Grammar;
    use Bennu::Actions;

    method parsefile($file) {
        return Bennu::Grammar->parsefile($file,
                                  setting => 'CORE',
                                  actions => Bennu::Actions->new)
            ->{_ast};
    }

    method parse($source) {
        return Bennu::Grammar->parse($source,
                              setting => 'CORE',
                              actions => Bennu::Actions->new)
            ->{_ast};
    }
    
}
