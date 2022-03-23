// Parser for our language

use crate::ast::*;
use crate::ast::Ast::*;

use std::str::FromStr;

// use nom::bytes::complete::*;
use nom::character::complete::*;
use nom::branch::alt;
use nom::combinator::{map, recognize};
use nom::multi::{many0};
use nom::sequence::{delimited, pair};
use nom::IResult;

fn parse_int(input: &str) -> IResult<&str, Ast> {
    map(delimited(space0, digit1, space0), |i| {
        let num = i64::from_str(i).unwrap();
        Int(num)
    })(input)
}

fn parse_var(input: &str) -> IResult<&str, Ast> {
    let (rest, name) = parse_identifier(input)?;
    Ok((rest, Var(name)))
}

fn parse_identifier(input: &str) -> IResult<&str, &str> {
    let (rest, i) = recognize(pair(alpha1, many0(alphanumeric1)))(input)?;
    Ok((rest, i))
}

fn parse_expr(input: &str) -> IResult<&str, Ast> {
    delimited(space0, alt((parse_int, parse_var)), space0)(input)
}

pub fn parse(input: &str) -> IResult<&str, Ast> {
    parse_expr(input)
}
