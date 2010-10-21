module Bennu::MOP;

class Mu {
    has $.how is rw;
    has $.who is rw;
    has $.repr is rw;
    has Bool $.defined is rw;
}

class Scope is Mu {
    has $.outer;
}

class Package is Mu {
    has $.name;
    has %!static-definitions;
    has %!static-names;

    method type { 'package' }

    method assign-static(@name, $value) {
        if @name == 1 {
            %!static-names{@name[0]} = 1;
            %!static-definitions{@name[0]} = $value;
        } elsif %!static-definitions{@name[0]} :exists {
            my $child = %!static-definitions{@name[0]};
            $child.assign-static(@name[1 .. *-1], $value);
        } else {
            die "Attempted to assign to non-existent package " ~
              $.name ~ '::' ~ @name[0] ~ ".";
        }
    }
}

class ClassWHAT is Mu {
}

class ClassHOW is Mu {
    has $!name is rw;
    has @!attributes;
    has @!methods;
    has $!instance-repr;

    submethod BUILD(:$!name, :@!attributes, :@!methods, :$!instance-repr) {
        $!instance-repr .= new(:class($self));
    }

    method new-type-object {
        $!instance-repr.create-type-object($self);
    }

    method add-attribute($obj, $attribute) {
        return $obj.how.add-attribute($obj, $attribute)
          unless $obj.how eqv self;
        @!attributes.push($attribute);
        $!instance-repr.add-attribute($attribute);
    }

    method add-method($obj, $method) {
        return $obj.how.add-method($obj, method)
          unless $obj.how eqv self;
        @!methods.push($methods);
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

class REPR is Mu {
    has $.class; # the how the repr is associated with.
}

class P6opaqueREPR is REPR {
}

class LLClassREPR is REPR {
    has @!attributes;

    method create-type-object($how) {
        Bennu::MOP::ClassWHAT.new(:$how, :repr(self), :defined(False));
    }

    method add-attribute($attribute) {
        @!attributes.push($attribute);
    }
}
