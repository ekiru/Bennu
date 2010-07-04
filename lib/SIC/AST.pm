use v6;

class SIC::AST {

}

class SIC::AST::Environment {...}
class SIC::AST::Variable {...}
class SIC::AST::Constant {...}

class SIC::AST::File is SIC::AST {
    has $.version is rw = '';
    has SIC::AST::Environment $.env is rw; #predeclare.
}

class SIC::AST::Environment is SIC::AST {
    has %.constants;
    has %.blocks;
    has %.variables;
}

class SIC::AST::Block is SIC::AST {
    has Str $.name is rw;
    has SIC::AST::Environment $.env is rw;
    has @.body;
}

class SIC::AST::Statement is SIC::AST {
}

class SIC::AST::Assignment is SIC::AST::Statement {
    has SIC::AST::Variable $.lhs is rw;
    has SIC::AST::Constant $.rhs is rw;

    method new($class: $lhs, $rhs) {
        $class.bless(*, :$lhs, :$rhs);
    }

    method find-constants { $.rhs; }
    method find-locals { $.lhs; }
}

class SIC::AST::SayCall is SIC::AST::Statement {
    has SIC::AST::Variable $.argument is rw;

    method new($class: $argument) {
        $class.bless(*, :$argument);
    }

    method find-constants { Nil; }
    method find-locals { Nil; }
}


class SIC::AST::Variable is SIC::AST {
    has Int $.number is rw;
}

class SIC::AST::Constant is SIC::AST {
    has Int $.value is rw;
}
