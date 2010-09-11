package Bennu::Actions;
use 5.010;

use warnings;

use MooseX::Declare;

# Taken from Niezca.
{
    package CursorBase;

    no warnings 'redefine';
    sub _REDUCE { my $self = shift;
        my $S = shift;
        my $meth = shift;
        my $key = $meth;
        $key .= ' ' . $_[0] if @_;

        $self->{_reduced} = $key;
        $self->{_from} = $S;
        if ($::ACTIONS) {
            $::ACTIONS->REDUCE($meth, $self, @_);
        }
        $self->deb("REDUCE $key from " . $S . " to " . $self->{_pos}) if &CursorBase::DEBUG() & &DEBUG::matchers();
        $self;
    }
}

class Bennu::Actions {
    my %carped;
    method REDUCE($cl: $meth, $m) {
        eval {
            my ($snd, $spec);
            if ($meth =~ /^(.*)__S_\d\d\d(.*)$/) {
                $meth = "$1__S_$2";
                $snd  = "$1__S_ANY";
                $spec = $2;
            }
            if ($cl->can($meth)) {
                return $cl->$meth($m);
            } elsif ($snd && $cl->can($snd)) {
                return $cl->$snd($m, $spec);
            } elsif (!( $carped{$meth}++ )) {
                die("Action method $meth not yet implemented");
            }
        };

        if ($@) {
            my $foo = $@;
            $foo =~ s/^(?:[^\n]*\n){5}\K.*//s;
            $m->sorry($foo);
        }
    }

    use Bennu::AST;

    method ws($m) { }
    method vws($m) { }
    method unv($m) { }

    method unspacey($m) { }
    method begid($m) { }
    method spacey($m) { }
    method nofun($m) { }

    method unitstart($m) { }

    method comp_unit($m) {
        $m->{_ast} = 
          Bennu::AST::CompilationUnit->new(statementlist =>
                                           $m->{statementlist}{_ast});
}

    method unitstopper($m) { }

    method stdstopper($m) { }
    method stopper($m) { }

    method ident($m) {
        $m->{_ast} = $m->Str;
    }

    method identifier($m) {
        $m->{_ast} = $m->Str;
    }

    method longname($m) {
        if (@{$m->{colonpair}}) {
            $m->sorry("Adverbs to longnames not yet implemented.");
        }
        $m->{_ast} = $m->{name}{_ast};
    }

    method name($m) {
        if (@{$m->{morename}}) {
            $m->sorry("Package-qualified names not yet implemented.");
        }
        $m->{_ast} = $m->{identifier}{_ast};
    }

    method desigilname($m) {
        given ($m) {
            when (exists $m->{variable}) {
                $m->sorry("Sigil contextualizers not yet implemented.");
            }
            default {
                $m->{_ast} = $m->{longname}{_ast};
            }
        }
    }

    method sigil($m) {
        $m->{_ast} = $m->Str;
    }
    method sigil__S_Dollar($m) { }

    method twigil($m) {
        $m->{_ast} = $m->Str;
    }
    method twigil__S_Dot($m) { }
    method twigil__S_Bang($m) { }

    method typename($m) {
        my $type;
        if (exists $m->{identifier}) {
            $m->sorry('::$?CLASS not yet implemented.');
        }
        else {
            $type = $m->{longname}{_ast};
        }
        if (@{$m->{typename}}) {
            $m->sorry('infix:<of> not yet implemented.');
        }
        else {
            if (@{$m->{param}}) {
                $m->sorry('Parameterized types not yet implemented.');
            }
            if (@{$m->{whence}}) {
                $m->sorry('WHENCE not yet implemented.');
            }
            else {
                $m->{_ast} = $type;
            }
        }
    }

    method termish($m) { }

    method EXPR($m) { }

    method arglist($m) {
        given ($m->{EXPR}{_ast}) {
            when (not defined($_)) {
                $m->{_ast} = [];
            }
            when ($_ && $_->isa('Bennu::AST::Parcel')) {
                $m->{_ast} = $_;
            }
            default {
                $m->{_ast} = [ $_ ];
            }
        }
    }

    method args($m) {
        given ($m) {
            when (exists $m->{moreargs}) {
                $m->sorry("Bennu can't handle listop(...): ... yet.");
            }
            when (exists $m->{semiarglist}) {
                $m->{_ast} = $m->{semiarglist}{_ast};
            }
            when (@{$m->{arglist}} != 0) {
                $m->{_ast} = $m->{arglist}[0]{_ast};
            }
            default {
                $m->{_ast} = [];
            }
        }
    }

    method term($m) { }

    method term__S_identifier($m) {
        my $ident = $m->{identifier}{_ast};
        given ($m->{identifier}->Str) {
            when ($m->is_name($m->{identifier}->Str)) {
                $m->{_ast} = Bennu::AST::Lexical->new(name => $ident);
            }
            default {
                my $args = $m->{args}{_ast};
                $m->{_ast} = Bennu::AST::Call->new(function => 
                                                   Bennu::AST::Lexical->new(name =>
                                                                            '&' . $ident),
                                                   args => $args);
            }
        }
    }

    method term__S_variable($m) {
        $m->{_ast} = $m->{variable}{_ast};
    }

    method term__S_value($m) {
        $m->{_ast} = $m->{value}{_ast};
    }

    method value($m) { }
    method value__S_number($m) {
        $m->{_ast} = $m->{number}{_ast};
    }

    method decint($m) {
        my $int = $m->Str;
        $int =~ s/_//;
        $m->{_ast} = Bennu::AST::Integer->new(value => $int + 0);
    }

    method integer($m) {
        given ($m) {
            when (exists $_->{binint}) {
                $m->{_ast} = $_->{binint}{_ast};
            }
            when (exists $_->{octint}) {
                $m->{_ast} = $_->{octint}{_ast};
            }
            when (exists $_->{hexint}) {
                $m->{_ast} = $_->{hexint}{_ast};
            }
            when (exists $_->{decint}) {
                $m->{_ast} = $_->{decint}{_ast};
            }
        }
    }


    method number($m) {
        given ($m->Str) {
            when (exists $m->{integer}) {
                $m->{_ast} = $m->{integer}{_ast};
            }
            when (exists $m->{dec_number}) {
                $m->{_ast} = $m->{dec_number}{_ast};
            }
            when (exists $m->{rad_number}) {
                $m->{_ast} = $m->{rad_number}{_ast};
            }
            when ('NaN') {
                $m->{_ast} = Bennu::AST::NaN->new;
            }
            when ('Inf') {
                $m->{_ast} = Bennu::AST::Inf->new;
            }
        }
    }

    method statementlist($m) {
        my $ast = Bennu::AST::StatementList->new;
        for my $statement (@{$m->{statement}}) {
            $ast->push($statement->{_ast});
        }
        $m->{_ast} = $ast;
    }

    method statement($m) {
        given ($m) {
            when (exists $m->{label}) {
                $m->{_ast} =
                  Bennu::AST::Labelled->new(statement =>
                                            $m->{statement}{_ast});
            }
            when (exists $m->{statement_control}) {
                $m->{_ast} = $_->{statement_control}{_ast};
            }
            when (exists $m->{EXPR}) {
                when (@{$m->{statement_mod_loop}}) {
                    my $loop = $m->{statement_mod_loop}[0]{_ast};
                    $loop->body($m->{EXPR}{_ast});
                    $m->{_ast} = $loop;
                }
                when (@{$m->{statement_mod_cond}}) {
                    my $cond = $m->{statement_mod_cond}[0]{_ast};
                    $cond->body($m->{EXPR}{_ast});
                    $m->{_ast} = $cond;
                }
                default {
                    $m->{_ast} = $m->{EXPR}{_ast};
                }
            }
        }
    }

    method eat_terminator($m) { }

    method terminator($m) { }
    method terminator__S_Semi($m) { }
}
