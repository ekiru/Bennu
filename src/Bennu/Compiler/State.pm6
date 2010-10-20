role Bennu::Compiler::State;

use Bennu::MOP;

my @!PACKAGE;
my @!SCOPE;

submethod BUILD () {
    @!PACKAGE = Bennu::MOP::Package.new(:name<GLOBAL>)
    @!SCOPE = Bennu::MOP::Scope.new(:outer(@!PACKAGE[0]));
}

method CLASS {
    for @!PACKAGE -> $package {
        return $package if $package.type eq 'class';
    }
    die '::?CLASS not found.';
}

method PACKAGE {
    @!PACKAGE[*-1];
}

method PUSH-PACKAGE ($package) {
    @!PACKAGE.push($package);
}

method POP-PACKAGE {
    @!PACKAGE.pop;
}

method SCOPE ($scope) {
    @!SCOPE[*-1];
}

method PUSH-SCOPE ($scope) {
    @!SCOPE.push($scope);
}

method POP-SCOPE {
    @!SCOPE.pop;
}
