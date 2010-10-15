module Bennu::MOP;

class Mu {
    has $.how is rw;
}

class Scope is Mu {
}

class Package is Mu {
    has $.name;
    has %!static-definitions;
    has %!static-names;

    method type { 'package' }

    method assign-static($name, $value) {
        %!static-names{$name} = 1;
        %!static-definitions{$name} = $value;
    }
}

class ClassWHAT is Package {
    method defined { False }
    method type { 'class' }
}

class ClassHOW is Mu {
    has $!name is rw;
    has @!attributes;
    has @!methods;

    method new-type-object {
        ClassWHAT.new(:how(self), :$.name);
    }

    method add-attribute($obj, $attribute) {
        return $obj.how.add-attribute($obj, $attribute)
          unless $obj.how eqv self;
        @.attributes.push($attribute);
    }

    method add-method($obj, $method) {
        return $obj.how.add-method($obj, method)
          unless $obj.how eqv self;
        @.methods.push($methods);
    }
}

class Attribute is Mu {
    has $.name;
    has Bool $.private;
    has @.constraints;
    has @.traits;
}

class Method is Scope {
    has $.name;
    has $.body is rw;
    has @.traits;
}
