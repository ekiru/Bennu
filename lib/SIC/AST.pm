use v6;

class SIC::AST {

}

class SIC::AST::Environment {...}
class SIC::AST::Register {...}
class SIC::AST::Value {...}

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

class SIC::AST::Statement is SIC::AST {
}

class SIC::AST::Assignment is SIC::AST::Statement {
    has SIC::AST::Register $.lhs is rw;
    has SIC::AST::Value $.rhs is rw;

    method new($class: $lhs, $rhs) {
        $class.bless(*, :$lhs, :$rhs);
    }
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

class SIC::AST::Fetch is SIC::AST::Value {
    has Str $.variable is rw;

    method LLVMvalue {
        "\%$.variable";
    }
}

class SIC::AST::Constant is SIC::AST {
    has Int $.value is rw;

    method LLVMvalue {
        ~$.value;
    }
}
