role Bennu::Compiler::State;

use Bennu::MOP;

my @!PACKAGE;
my @!SCOPE;
my @!CLASS;

submethod BUILD () {
    @!PACKAGE = Bennu::MOP::Package.new(:name<GLOBAL>)
    @!SCOPE = Bennu::MOP::Scope.new(:outer(@!PACKAGE[0]));
}

method CLASS {
    @!CLASS[*-1];
}

method PUSH-CLASS ($class) {
    @!CLASS.push($class);
}

method POP-CLASS {
    @!CLASS.pop;
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
