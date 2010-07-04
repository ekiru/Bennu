use v6;

use SIC::AST;

class SIC::Actions;

method TOP ($/) {
    my SIC::AST::File $file .= new;
    $file.version = $<version_line>.ast;
    $file.env = $<environment>.ast;

    for $<block> -> $block {
        $file.env.blocks{$block.ast.name} = $block.ast;
    }

    make $file;
}

method version_line ($/)  {
    unless $<version> eq '2010.08' {
        die 'SIC::Compiler version ' ~ '2010.08' ~
            " cannot compile SIC version $<version>.";
    }
    make ~$<version>;
}

method environment ($/) {
    my SIC::AST::Environment $env .= new;
    for $<pad> -> $pad {
        $env.blocks{$pad.ast} = 1;
        # This will later get filled in with the actual block.
    }
    make $env;
}

method pad ($/) {
    make ~$<ident>;
}

method block ($/) {
    my SIC::AST::Block $block .= new;
    $block.name = ~$<ident>;
    $block.env = SIC::AST::Environment.new;
    for $<statement> -> $statement {
        $block.body.push($statement.ast);
        for $statement.ast.find-locals -> $local {
            $block.env.variables{$local} = 1;
        }
        for $statement.ast.find-constants -> $constant {
            $block.env.constants{$constant} = 1;
        }
    }

    make $block;
}

method statement:sym<=> ($/) {
    make SIC::AST::Assignment.new($<variable>.ast, $<constant>.ast);
}

method statement:sym<say> ($/) {
    make SIC::AST::SayCall.new($<variable>.ast);
}

method variable ($/) {
    make SIC::AST::Variable.new(:number($0));
}

method constant ($/) {
    make SIC::AST::Constant.new(:value($0));
}
