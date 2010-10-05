role Bennu::Compiler::State;

use Bennu::MOP;

my @!PACKAGE = Bennu::MOP::Package.new(:name<GLOBAL>);

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

method POP-PACKAGES {
    @!PACKAGE.pop;
}
