#[derive(Debug)]
pub enum Ast<'a> {
    // Integers are the only numbers supported so far
    Int(i64),
    // Variable references (includes references to built-in operators like `+`)
    Var(&'a str),
    // Lists, of which function calls are a special case
    Lst(Vec<&'a Ast<'a>>)
}
