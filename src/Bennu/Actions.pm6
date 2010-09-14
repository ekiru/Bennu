class Bennu::Actions;

use Bennu::AST;
use Bennu::Decl;

method ws($/) { }
method vws($/) { }
method unv($/) { }

method unspacey($/) { }
method begid($/) { }
method spacey($/) { }
method nofun($/) { }

method unitstart($/) { }

method comp_unit($/) {
    make Bennu::AST::CompilationUnit.new(statementlist =>
                                         $<statementlist>.ast);
}

method unitstopper($/) { }

method stdstopper($/) {}
method stopper($/) { }

method infixstopper($/) { }

method curlycheck($/) { }

method ident($/) {
    make ~$/;
}

method identifier($/) {
    make ~$/;
}

method longname($/) {
    if $<colonpair>.elems {
        $/.sorry("Adverbs to longnames not yet implemented.");
    }
    make $<name>.ast;
}

method name($/) {
    if $<morename>.elems {
        $/.sorry("Package-qualified names not yet implemented.");
    }
    make $<identifier>.ast;
}

method scoped($/) {
    when $<declarator> :exists {
        make $<declarator>.ast;
    }
    default {
        $/.sorry("Non-simple scoped declarations not yet implemented.");
    }
}

method declarator($/) {
    when $<variable_declarator> :exists {
        make $<variable_declarator>.ast;
    }
    default {
        $/.sorry("Not all declarators are supported.");
    }
}

method variable_declarator($/) {
    if $<shape>.elems {
        $/.sorry("Shaped variable declarations not yet implemented.");
    }
    if $<post_constraint>.elems {
        $/.sorry("Post constraints on variables not yet implemented.");
    }
    my @traits = $<trait>.map(*.ast);
    make Bennu::Decl::Variable.new(variable => $<variable>.ast,
                                   :@traits);
}

method multi_declarator($/) { }
method multi_declarator:sym<null>($/) {
    make $<declarator>.ast;
}

method variable($/) {
    my $ast;
    if $<desigilname> :exists {
        $ast = Bennu::AST::Lexical.new(name => $<sigil> ~ $<twigil> ~ $<desigilname>);
    }
    else {
        $/.sorry("Non-simple variables not yet implemented.");
    }

    if $<postcircumfix>.elems {
        my $post = $<postcircumfix>[0].ast;
        $post.args.unshift($ast);
        $ast = $post;
    }
    make $ast;
}

method desigilname($/) {
    when $<variable> :exists {
        $/.sorry("Contextualizing sigils not yet implemented.");
    }
    default {
        make $<longname>.ast;
    }
}

method sigil($/) {
    make ~$/;
}
method sigil:sym<$>($/) { }

method twigil($/) {
    make ~$/;
}
method twigil:sym<.>($/) { }
method twigil:sym<!>($/) { }

method typename($/) {
    my $type;
    if $<identifier> :exists {
        # ::?CLASS
        $/.sorry('::?CLASS not yet implemented.');
    }
    else {
        $type = $<longname>.ast;
    }
    if +$<typename> {
        # typename of typename
        $/.sorry('infix:<of> not yet implemented.');
    }
    else {
        if +$<param> {
            $/.sorry('Parameterized types not yet implemented.');
        }
        if +$<whence> {
            $/.sorry('WHENCE not yet implemented.');
        }
        else {
            make $type;
        }
    }
}

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

method POST($/) {
    if $<postfix_prefix_meta_operator>.elems {
        $/.sorry('postfix_prefix_meta_operator not yet implemented.');
        return;
    }
    if $<dotty> :exists {
        make $<dotty>.ast;
    }
    elsif $<privop> :exists {
       make $<privop>.ast;
    }
    else {
        make $<postop>.ast;
    } 
}

method POSTFIX($/) {
    my $ast;
    if $<dotty> :exists {
        $ast = $<dotty>.ast;
    }
    else {
        $/.sorry('Non-dotty postfixes not yet implemented.');
        return;
    }
    $ast.arg = $<arg>.ast;
    make $ast;
}

method infix($/) {
    make Bennu::AST::Lexical.new(name => '&infix:<' ~ $/<sym> ~ '>';
}

method infix:sym<+>($/) { }

method term($/) { }

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

method term:sym<scope_declarator>($/) {
    make $<scope_declarator>.ast;
}

method term:sym<value>($/) {
    make $<value>.ast;
}

method term:sym<variable>($/) {
    make $<variable>.ast;
}

method dotty($/) { }
method dotty:sym<.>($/) {
    make $<dottyop>.ast;
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
