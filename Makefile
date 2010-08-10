STDBASE:=$(shell pwd)/STD_checkout
STDENV=PERL5LIB=$(STDBASE) PERL6LIB=$(STDBASE):$(STDBASE)/lib

all: .STD_build_stamp

.STD_checkout_stamp: STD_REVISION
	if [ ! -d STD_checkout ]; then \
	    svn checkout http://svn.pugscode.org/pugs/src/perl6@`cat STD_REVISION` STD_checkout; \
	else \
	    svn update -r`cat STD_REVISION` STD_checkout; \
	fi
	touch .STD_checkout_stamp

.STD_build_stamp: .STD_checkout_stamp
	cd STD_checkout && make && ./tryfile STD.pm6
	touch .STD_build_stamp