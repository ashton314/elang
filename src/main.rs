use elang::parser;
use elang::compiler;
use std::io::{self, Write};

fn main() {
    loop {
        print!("\nExpr: ");
        io::stdout().flush().unwrap(); // the print! macro doesn't flush STDOUT by default

        let mut to_parse = String::new();
        io::stdin()
            .read_line(&mut to_parse)
            .expect("Failed to get an expression");

        to_parse.pop();         // to_parse.strip_suffix("\n"); <-- non-destructive version

        if to_parse == "quit" || to_parse == "exit" {
            println!("Aufwiedersehen!");
            std::process::exit(0)
        }

        match parser::parse(to_parse.as_str()) {
            Ok((rest, tree)) => {
                if rest.len() > 0 {
                    println!("Unparsed: '{}'", rest);
                }
                dbg!(tree);

                compiler::comp().unwrap();
                // println!("{}", serde_json::to_string(&tree).unwrap());
                // println!("{}", serde_json::to_string_pretty(&tree).unwrap());
            },
            Err(msg) => {
                println!("Error: {}", msg)
            }
        }
    }
}
