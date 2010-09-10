class Bennu::Actions;

use Bennu::AST;

method ws($/) { }
method vws($/) { }
method begid($/) { }
method spacey($/) { }

method unitstart($/) { }

method comp_unit($/) {
    make Bennu::AST::CompilationUnit.new(statementlist =>
                                         $<statementlist>.ast);
}

method unitstopper($/) { }

method stdstopper($/) {}
method stopper($/) { }

method ident($/) {
    make ~$/;
}

method identifier($/) {
    make ~$/;
}

method sigil($/) {
    make ~$/;
}
method sigil:sym<$>($/) { }

method twigil($/) {
    make ~$/;
}
method twigil:sym<.>($/) { }

method termish($/) { }

method EXPR($/) { }

method arglist($/) {
    given $<EXPR>.ast {
        when not *.defined {
            make [];
        }
        when Bennu::AST::Parcel {
            make $_;
        }
        default {
            make [ $_ ];
        }
    }
}

method args($/) {
    when $<moreargs> :exists {
        $/.sorry("Bennu can't handle listop(...): ... yet.");
    }
    when $<semiarglist> :exists {
        make $<semiarglist>.ast;
    }
    when $<arglist>.elems {
        make $<arglist>[0].ast;
    }
    default {
        make [];
    }
}

method term:sym<identifier>($/) {
    my $ident = $<identifier>.ast;
    when $/.is_name($<identifier>.Str) {
        make Bennu::AST::Lexical.new(name => $ident);
    }
    default {
        my $args = $<args>.ast;
        make Bennu::AST::Call.new(function =>
                                  Bennu::AST::Lexical.new(name =>
                                                          '&' ~ $ident),
                                  args => $args);
    }
}

method term:sym<value>($/) {
    make $<value>.ast;
}

method value:sym<number>($/) {
    make $<number>.ast;
}

method decint($/) {
    make Bennu::AST::Integer.new(value => $/.Str.subst(/_/, '').Int);
}

method integer($/) {
    when $<binint> :exists {
        make $<binint>.ast;
    }
    when $<octint> :exists {
        make $<octint>.ast;
    }
    when $<hexint> :exists {
        make $<hexint>.ast;
    }
    when $<decint> :exists {
        make $<decint>.ast;
    }
}

method number($/) {
    given ~$/ {
        when $<integer> :exists {
            make $<integer>.ast;
        }
        when $<dec_number> :exists {
            make $<dec_number>.ast;
        }
        when $<rad_number> :exists {
            make $<rad_number>.ast;
        }
        when 'NaN' {
            make Bennu::AST::NaN.new;
        }
        when 'Inf' {
            make Bennu::AST::Inf.new;
        }
    }
}

method statementlist($/) {
    my $ast = Bennu::AST::StatementList.new;
    for @($<statement>) -> $statement {
        $ast.push($statement.ast);
    }
    make $ast;
}

method statement($/) {
    when $<label> :exists {
        make Bennu::AST::Labelled.new(statement => $<statement>.ast);
    }
    when $<statement_control> :exists {
        make $<statement_control>.ast;
    }
    when $<EXPR> :exists {
        when $<statement_mod_loop> {
            my $loop = $<statement_mod_loop>[0].ast;
            $loop.body = $<EXPR>.ast;
            make $loop;
        }
        when $<statement_mod_cond> {
            my $cond = $<statement_mod_cond>[0].ast;
            $cond.body = $<EXPR>.ast;
            make $cond;
        }
        default {
            make $<EXPR>.ast;
        }
    }
}

method eat_terminator($/) { }

method terminator($/) { }
method terminator:sym<;>($/) { }
