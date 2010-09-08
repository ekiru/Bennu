role Bennu::Compiler::Parse;

use Bennu::Grammar;
use Bennu::Actions;

method parsefile($file) {
    Bennu::Grammar.parsefile($file,
                             :setting<CORE>,
                             :actions(Bennu::Actions)).ast;
}

method parse($source) {
    Bennu::Grammar.parse($source,
                         :setting<CORE>,
                         :actions(Bennu::Actions)).ast;
}
