use v6;

class SIC::AST {

}

class SIC::AST::Environment {...}
class SIC::AST::Register {...}
class SIC::AST::Constant {...}
class SIC::AST::Lexical {...}

class SIC::AST::File is SIC::AST {
    has $.version is rw = '';
    has SIC::AST::Environment $.env is rw; #predeclare.
}

class SIC::AST::Environment is SIC::AST {
    has %.constants;
    has %.blocks;
    has %.lexicals;
}

class SIC::AST::Block is SIC::AST {
    has Str $.name is rw;
    has SIC::AST::Environment $.env is rw;
    has @.body;
}

class SIC::AST::Statement is SIC::AST { }

class SIC::AST::Assignment is SIC::AST::Statement {
    has SIC::AST::Register $.lhs is rw;
    has SIC::AST::Constant $.rhs is rw;
}

class SIC::AST::Fetch is SIC::AST::Statement {
    has SIC::AST::Register $.lhs is rw;
    has SIC::AST::Lexical $.rhs is rw;
}

class SIC::AST::SayCall is SIC::AST::Statement {
    has SIC::AST::Register $.argument is rw;

    method new($class: $argument) {
        $class.bless(*, :$argument);
    }
}

class SIC::AST::Store is SIC::AST::Statement {
    has Str $.variable is rw;
    has SIC::AST::Register $.register is rw;
}

class SIC::AST::Register is SIC::AST {
    has Int $.number is rw;
}

class SIC::AST::Value is SIC::AST {
    method LLVMvalue {...}
}

class SIC::AST::Constant is SIC::AST {
    has Int $.value is rw;

    method Str {
        ~$.value;
    }
}

class SIC::AST::Lexical is SIC::AST {
    has Str $.name is rw;

    method Str { '%' ~ $.name; }
}
