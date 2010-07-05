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
    @output.push('declare i32 @printf (i8*, ...)');
    @output.push('@INTPRINTF = internal constant [4 x i8] c"%d\0A\00"');
    @output.push('');
}

multi method emit(SIC::AST::Block $block, Str @output) {
    @output.push('define i32 @' ~ $block.name ~ ' () {');
    for $block.body -> $statement {
        self.emit($statement, @output);
    }
    @output.push('ret i32 0');
    @output.push('}');
}

multi method emit(SIC::AST::Assignment $statement, Str @output) {
    @output.push(local_var($statement.lhs.number) ~ 
                 ' = add i32 0, ' ~ $statement.rhs.value);
}

multi method emit(SIC::AST::SayCall $statement, Str @output) {
    my $temp = temp_var();
    @output.push($temp ~ ' = getelementptr [04 x i8]* @INTPRINTF, ' ~
                 'i64 0, i64 0');
    @output.push('call i32 (i8*, ...)* @printf(i8* ' ~ $temp ~ ', ' ~
                 'i32 ' ~ local_var($statement.argument.number) ~ ')');
}
