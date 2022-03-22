pub enum Ast {
    // Integers are the only numbers supported so far
    Int(i64),
    // Variable references (includes references to built-in operators like `+`)
    Var(&str),
    // Function calls are represented as a function name and a list of expressions
    Call(&str, Vec<Expr>)
}
