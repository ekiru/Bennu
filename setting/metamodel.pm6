use v6;
# Mostly a translation without micro-optimizations of the object system in
# Piumarta and Warth's "Open, extensible object models" paper. I plan to
# stick with at least a conceptually analogous base for the object system.
# Or at least, for the default metamodel. Given that it will be implemented
# in Perl 6 with a bunch of bootstrapping pragmas, other object models
# should be able to be implemented with equal control without relying on
# the default, although maybe that won't be necessary (perhaps the spec
# will eventually allow portable ways of creating new metamodels without
# relying on the default, though that problem may be unsolvable).

# One thing to note is that I haven't included casts in the code. I've not
# yet decided how to represent them syntactically yet.


# This gives us the raw-struct class trait.
use bootstrap::raw-struct;
# This gives us the raw-function sub trait.
use bootstrap::raw-function;
# This might not end up being used, but it means that only explicit return
# statements return from subs.
use bootstrap::explicit-return;
# All containers must be explicit.
use bootstrap::no-containers;
# bootstrap::c-ops makes Perl 6's ops do the appropriate C one.
# Note that == will be just C ==, not numeric equality.
use bootstrap::c-ops;
# Now we have some C types available. pointer[T] is equivalent to *T.
# void is valid as a pointer type and a return type.
use bootstrap::c-types <pointer char int void>;
# #include <stdio.h>
use bootstrap::libc::stdio <fprintf stderr>;
# #include <stdlib.h>
use bootstrap::libc::stdlib <NULL calloc realloc size_t>;
# #include <string.h>
use bootstrap::libc::string <strcmp strdup>;

class LowLevelHash { ... }

class Vtable { ... }
class Object { ... }
class Symbol { ... }

# do something to create the Method type, which is a variadic function
# with a single fixed argument of type pointer[Object] returning
# pointer[Object]
subset Method where True;
# Alternately, given that we probably will need to be using an array for
# parameter-passing, something like the following works, I think.
# subset Method where &:(pointer[Object], pointer[LowLevelArray]);

# Raw-struct basically means that it creates the equivalent of a C struct.
# Each attribute has imaginary accessors such that $foo.bar is C's foo.bar
# if $foo is an Object, and C's foo->bar if $foo is a pointer[Object].
# Probably. Maybe there'll be a different op for C's ->
class Object is raw-struct {
    has pointer[Vtable] $.vtable;
}

class LowLevelHash is raw-struct is Object {
    has int $.size;
    has int $.tally;
    has pointer[pointer[Object]] $.keys;
    has pointer[pointer[Object]] $.values;
}

# For raw-structs, inheritance just means sticking the parent's members
# at the front of it.
class Vtable is raw-struct is Object {
    has pointer[LowLevelHash] $.methods;
    has pointer[LowLevelHash] $.attributes;
    has pointer[Vtable] $.parent;
    has libc::size_t $.size;
}

class Symbol is raw-struct is Object {
    has pointer[char] $.string; # maybe have an explicit c-string type.
}

my pointer[Vtable] $low-level-hash-vt = $libc::NULL;
my pointer[Vtable] $vtable-vt = $libc::NULL;
my pointer[Vtable] $object-vt = $libc::NULL;
my pointer[Vtable] $symbol-vt = $libc::NULL;

my pointer[Object] $add-attribute-symbol = $libc::NULL;
my pointer[Object] $get-attribute-symbol = $libc::NULL;
my pointer[Object] $set-attribute-symbol = $libc::NULL;
my pointer[Object] $add-method-symbol = $libc::NULL;
my pointer[Object] $allocate-symbol = $libc::NULL;
my pointer[Object] $delegated-symbol = $libc::NULL;
my pointer[Object] $lookup-symbol = $libc::NULL;
my pointer[Object] $intern-symbol = $libc::NULL;
my pointer[Object] $get-symbol = $libc::NULL;
my pointer[Object] $set-symbol = $libc::NULL;

my pointer[Object] $vtable-symbol = $libc::NULL;
my pointer[Object] $methods-symbol = $libc::NULL;
my pointer[Object] $attributes-symbol = $libc::NULL;
my pointer[Object] $parent-symbol = $libc::NULL;
my pointer[Object] $string-symbol = $libc::NULL;

my pointer[Object] $symbol = $libc::NULL;
my pointer[LowLevelHash] $symbol-list = $libc::NULL;

# raw-function basically means it's just like a normal C function.
# The actual detailed semantics of this, I don't know.
my pointer[LowLevelHash] low-level-hash-new() {
    my pointer[LowLevelHash] $result = alloc(sizeof LowLevelHash);
    $result.vtable = $low-level-hash-vtable;
    low-level-hash-init($result);
    return $result;
}

my void sub low-level-hash-init(pointer[LowLevelHash] $self) is raw-function {
    $self.size = 2;
    $self.tally = 0;
    $self.keys = libc::calloc($self.size, sizeof(pointer[Object]));
    $self.values = libc::calloc($self.size, sizeof(pointer[Object]));
}

my void low-level-hash-set(pointer[LowLevelHash] $self,
                           pointer[Object] $key,
                           pointer[Object] $value) {
    loop (my int $i = 0; i < $self.tally; ++$i) {
	if $key == $self.keys[$i] {
	    $self.value[i] = $value;
            return;
	}
    }
    if $self.tally == $self.size {
	$self.size *= 2;
	$self.keys = libc::realloc($self.keys,
				   sizeof(pointer[Object]) * $self.size);
	$self.values = libc::realloc($self.value,
				     sizeof(pointer[Object]) * $self.size);
    }
    $self.keys[$self.tally] = $key;
    $self.values[$self.tally++] = $value;
}

my pointer[Object] sub low-level-hash-get(pointer[LowLevelHash] $self,
                                          pointer[Object] $key)
  is raw-function {
    loop (my int $i = 0; $i < $self.tally; ++$i) {
	if $key == $self.keys[$i] {
	    return $self.values[i];
	}
    }
    return $libc::NULL;
}

my pointer[Object] sub vtable-add-attribute(pointer[Vtable] $self,
                                            pointer[Object] $key,
                                            int $offset)
  is raw-function {
    # Offsets are incremented by one to distinguish 0 from missing keys.
    low-level-hash-set($self, $key, $offset + 1);
    return $key;
}

my int sub vtable-get-attribute-offset(pointer[Vtable] $self,
                                       pointer[Object] $key) {
    my int $offset = low-level-hash-get $self.attributes, $key;
    return $offset - 1 if $offset;
    return object-get-attribute-offset $self.parent, $key if $self.parent;
    libc::fprintf($libc::stderr, "lookup failed \%p \%s\n", $self, $key.string);
    return -1;
}

my pointer[Object] sub object-get-attribute(pointer[Object] $self,
                                            pointer[Object] $key)
  is raw-function {
    my int $offset = vtable-get-attribute-offset $self.vtable, $key;
    return $libc::NULL if $offset == -1; # Need better error strategy.
    return deref $self + $offset;
}

my pointer[Object] sub object-set-attribute(pointer[Object] $self,
                                            pointer[Object] $key,
                                            pointer[Object] $value)
  is raw-function {
    my int $offset = vtable-get-attribute-offset $self.vtable, $key;
    return $libc::NULL = $value
      if $offset == -1; # segfaults are a very visible error condition.
    return deref($self + $offset) = $value;
}

my pointer[void] sub alloc(libc::size_t $size) is raw-function {
    return libc::calloc(1, $size + sizeof(pointer[Vtable]));
}

my pointer[Object] sub symbol-new(pointer[char] $string) is raw-function {
    my pointer[Symbol] $symbol = alloc(sizeof Symbol);
    $symbol.vtable = $symbol-vt;
    $symbol.string = libc::strdup($string);
    return $symbol;
}

my pointer[Object] sub vtable-allocate(pointer[Vtable] $self,
				       int $payload-size)
  is raw-function {
    my pointer[Object] $object = alloc($payload-size);
    $object.vtable = $self;
    return $object;
}

my pointer[Vtable] sub vtable-delegated(pointer[Vtable] $self)
  is raw-function {
    my pointer[Vtable] $child = vtable-allocate($self, sizeof(Vtable));
    if $self {
	$child.vtable = $self;
    } else {
	$child.vtable = $libc::NULL;
    }
    $child.methods = low-level-hash-new;
    $child.parent = $self;
    $child.size = $self.size if $self;
    return $child;
}

my pointer[Object] sub vtable-add-method(pointer[Vtable] $self,
				       pointer[Object] $key,
				       pointer[Object] $method)
  is raw-function {
    low-level-hash-set($self.methods, $key, $method);
    return $method;
}

my pointer[Object] sub vtable-lookup(pointer[Vtable] $self,
				     pointer[Object] $key)
  is raw-function {
    my pointer[Object] $result = 
      low-level-hash-get($self.methods, $key);
    return $result if $result;
    return send($self.parent, $lookup-symbol, $key) if $self.parent;
    libc::fprintf($libc::stderr, "lookup failed \%p \%s\n", $key.string);
    return $libc::NULL;
}

my pointer[Object] sub symbol-intern(pointer[Object] $self,
				     pointer[char] $string)
  is raw-function {
    my pointer[Object] $symbol;
    loop (my int $i = 0; $i < $symbol-list.tally; ++$i) {
	$symbol = $symbol-list.keys[$i];
	unless libc::strcmp($string, $symbol.string) {
	    return $symbol;
	}
    }
    $symbol = symbol-new($string);
    low-level-hash-set($symbol-list, $symbol, 1);
    return $symbol;
}

# Frankly, I'm not sure how this translates to C. I'm not sure how to do
# this in C without forcing everything to use some sort of array for
# parameters. That's probably necessary anyway so *@args will probably
# instead need to be some kind of low-level array.
my pointer[Object] sub send(pointer[Object] $self,
			    pointer[Object] $message,
			    pointer[Object] *@args)
  is raw-function {
    return (($message == $lookup-symbol && $self.vtable == $vtable-vt)
	    ?? vtable-lookup($self, $message)
	    !! send($self, $lookup-symbol, $msg))($self, |@args);
}

my sub metamodel-init() {
    $low-level-hash-vt = vtable-delegated($libc::NULL);
    $low-level-hash-vt.vtable.methods.vtable = $low-level-hash-vt;
    $low-level-hash-vt.vtable.attributes.vtable = $low-level-hash-vt;
    $symbol-list = low-level-hash-new;

    $vtable-vt = vtable-delegated($libc::NULL);
    $vtable-vt.vtable = $vtable-vt;

    $object-vt = vtable-delegated($libc::NULL);
    $object-vt.vtable = $vtable-vt;
    $vtable-vt.parent = $object-vt;

    $low-level-hash-vt.parent = $object-vt;
    $low-level-hash-vt.vtable = $vtable-vt;

    $symbol-vt = vtable-delegated($object-vt);

    $lookup-symbol = symbol-intern $libc::NULL, "lookup";
    vtable-add-method $vtable-vt, $lookup-symbol, &vtable-lookup;

    $add-method-symbol = symbol-intern $libc::NULL, "add-method";
    vtable-add-method $vtable-vt, $add-method-symbol, &vtable-add-method;

    $allocate-symbol = symbol-intern $libc::NULL, "allocate";
    send $vtable-vt, $add-method-symbol, $allocate-symbol, &vtable-allocate;
    $symbol = send $symbol-vt, $allocate-symbol, sizeof(Symbol);

    $intern-symbol = symbol-intern $libc::NULL, "intern";
    send $symbol-vt, $add-method-symbol, $intern-symbol, &symbol-intern;

    $delegated-symbol = send $symbol, $intern-symbol, "delegated";
    send $vtable-vt, $add-method-symbol, $delegated-symbol, &vtable-delegated;

    $get-symbol = send $symbol, $intern-symbol, "get";
    send $low-level-hash-vt, $add-method-symbol, $get-symbol, &low-level-hash-get;

    $set-symbol = send $symbol, $intern-symbol, "set";
    send $low-level-hash-vt, $add-method-symbol, $set-symbol, &low-level-hash-set;

    $add-attribute-symbol = send $symbol, $intern-symbol, "add-attribute";
    send $vtable-vt, $add-method-symbol, $add-attribute-symbol, &vtable-add-attribute;

    $get-attribute-symbol = send $symbol, $intern-symbol, "get-attribute";
    send $object-vt, $add-method-symbol, $get-attribute-symbol, &object-get-attribute;

    $set-attribute-symbol = send $symbol, $intern-symbol, "set-attribute";
    send $object-vt, $add-method-symbol, $set-attribute-symbol, &object-set-attribute;   
}
