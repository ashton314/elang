// Parser for our language

use crate::ast::*;
use crate::ast::Ast::*;

use std::str::FromStr;

use nom::bytes::complete::*;
use nom::character::complete::*;
use nom::combinator::{map};
use nom::sequence::{delimited};
use nom::IResult;

fn parse_int(input: &str) -> IResult<&str, Ast> {
    map(delimited(space0, digit1, space0), |i| {
        let num = i64::from_str(i).unwrap();
        Int(num)
    })(input)
}

pub fn parse(input: &str) -> IResult<&str, Ast> {
    parse_int(input)
}
