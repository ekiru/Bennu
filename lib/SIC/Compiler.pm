use v6;

use SIC::AST;
use SIC::Grammar;
use SIC::Actions;

class SIC::Compiler;

our $VERSION = '2010.08';

my $temp_count = 0;
sub temp_var () {
    '%__temp_' ~ $temp_count++;
}


sub local_var($n) {
    '%__local_' ~ $n;
}

multi method compile(Str $sic) {
    return self.new.compile($sic) unless self.defined;
    my $parse = SIC::Grammar.parse($sic, :actions(SIC::Actions.new));
    die "Could not parse." unless $parse;
    my SIC::AST::File $ast = $parse.ast;
    return self.compile($ast);
}

multi method compile(SIC::AST::File $ast) {
    my Str @output;

    self.emit-header($ast, @output);

    self.emit($_, @output) for $ast.env.blocks.values;

    return @output;
}

multi method emit-header(SIC::AST::File $file, Str @output) {
    @output.push('%obj = type opaque*');
    @output.push('declare void @bennu_init()');
    @output.push('declare %obj @bennu_int_new (i32)');
    @output.push('declare %obj @bennu_say (%obj)');
    @output.push('');
}

multi method emit(SIC::AST::Block $block, Str @output) {
    @output.push('define i32 @' ~ $block.name ~ ' () {');
    if $block.name eq 'main' {
        @output.push('call void @bennu_init()');
    }
    for $block.body -> $statement {
        self.emit($statement, @output);
    }
    @output.push('ret i32 0');
    @output.push('}');
}

multi method emit(SIC::AST::Assignment $statement, Str @output) {
    @output.push(local_var($statement.lhs.number) ~ 
                 ' = call %obj @bennu_int_new(i32 ' ~
                 $statement.rhs ~ ')');
}

multi method emit(SIC::AST::Fetch $statement, Str @output) {
    @output.push(local_var($statement.lhs.number) ~ 
                 ' = bitcast %obj ' ~ $statement.rhs ~ ' to %obj');
}

multi method emit(SIC::AST::SayCall $statement, Str @output) {

    @output.push('call %obj @bennu_say(%obj ' ~
                 local_var($statement.argument.number) ~ ')');
}

multi method emit (SIC::AST::Store $statement, Str @output) {
    @output.push('%' ~ $statement.variable ~ ' = bitcast %obj ' ~
                 local_var($statement.register.number) ~ ' to %obj');
}
