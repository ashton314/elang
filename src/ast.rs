#[derive(Debug)]
pub enum Ast<'a> {
    // Integers are the only numbers supported so far
    Int(i64),
    // Variable references (includes references to built-in operators like `+`)
    Var(&'a str),
    // Function calls are represented as a function name and a list of expressions
    Call(&'a str, Vec<&'a Ast<'a>>)
}
