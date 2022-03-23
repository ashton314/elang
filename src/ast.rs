/// Ast enum represents the processed AST we get from the Racket side of the compiler.
#[derive(Debug)]
pub enum Ast<'a> {
    // Integers are the only numbers supported so far
    Int(i64),
    // Variables
    Var(&'a str),
    // Top-level definitions
    Defn(&'a str, Box<Ast<'a>>),
    // Function calls
    Funcall(&'a str, Vec<Ast<'a>>),
    // Lambdas: argument list and list of exprs as body
    Lambda(Vec<&'a str>, Vec<Ast<'a>>),
    // Let blocks: list of tuples var → binding; list of exprs as body
    Let(Vec<(&'a str, Ast<'a>)>, Vec<Ast<'a>>)
}
