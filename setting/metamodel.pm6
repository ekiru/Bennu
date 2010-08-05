use v6;
use bootstrap::raw-structs;
use bootstrap::explicit-return;
use bootstrap::no-containers;
use bootstrap::c-ops <sizeof + == * ??!!>;
use bootstrap::c-types <pointer char int void>;
use bootstrap::libc::stdio <fprintf stderr>;
use bootstrap::libc::stdlib <NULL calloc realloc size_t>;
use bootstrap::libc::string <strcmp strdup>;

class Vtable { ... }
class Object { ... }
class Symbol { ... }

# do something to create the Method type, which is a variadic function
# with a single fixed argument of type pointer[Object] returning
# pointer[Object]
subset Method where True;

class Object is raw-struct {
    has pointer[Vtable] $.vtable;
}

class Vtable is raw-struct is Object {
    has int $.size;
    has int $.tally;
    has pointer[pointer[Object]] $.keys;
    has pointer[pointer[Object]] $.values;
    has pointer[Vtable] $.parent;
}

class Symbol is raw-struct is Object {
    has pointer[char] $.string;
}

my pointer[Vtable] $vtable-vt = $libc::NULL;
my pointer[Vtable] $object-vt = $libc::NULL;
my pointer[Vtable] $symbol-vt = $libc::NULL;

my pointer[Object] $add-method-symbol = $libc::NULL;
my pointer[Object] $allocate-symbol = $libc::NULL;
my pointer[Object] $delegated-symbol = $libc::NULL;
my pointer[Object] $lookup-symbol = $libc::NULL;
my pointer[Object] $intern-symbol = $libc::NULL;

my pointer[Object] $symbol = $libc::NULL;
my pointer[Object] $symbol-list = $libc::NULL;

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
    $child.size = 2;
    $child.tally = 0;
    $child.keys = libc::calloc($child.size, sizeof(pointer[Object]));
    $child.values = libc::calloc($child.size, sizeof(pointer[Object]));
    $child.parent = $self;
    return $child;
}

my pointer[Object] sub $vtable-add-method(pointer[Vtable] $self,
				       pointer[Object] $key,
				       pointer[Object] $method)
  is raw-function {
    loop (my int $i = 0; i < $self.tally; ++$i) {
	if $key == $self.keys[$i] {
	    return $self.value[i] = $method;
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
    $self.values[$self.tally++] = $method;
    return $method;
}

my pointer[Object] sub vtable-lookup(pointer[Vtable] $self,
				     pointer[Object] $key)
  is raw-function {
    loop (my int $i = 0; $i < $self.tally; ++$i) {
	if $key == $self.keys[$i] {
	    return $self.values[i];
	}
    }
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
    vtable-add-method($symbol-list, $symbol, 0);
    return $symbol;
}

my pointer[Object] sub send(pointer[Object] $self,
			    pointer[Object] $message,
			    pointer[Object] *@args)
  is raw-function {
    return ($message == $lookup-symbol
	    ?? vtable-lookup($self, $message)
	    !! send($self, $lookup-symbol, $msg))($self, |@args);
}

my sub metamodel-init() {
    $vtable-vt = vtable-delegated($libc::NULL);
    $vtable-vt.vtable = $vtable-vt;

    $object-vt = vtable-delegated($libc::NULL);
    $object-vt.vtable = $vtable-vt;
    $vtable-vt.parent = $object-vt;

    $symbol-vt = vtable-delegated($object-vt);
    $symbol-list = vtable-delegated($libc::NULL);

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
}
