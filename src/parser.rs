use chomp::prelude::*;
use chomp::ascii::*;
use std::str::from_utf8_unchecked;

fn is_identifier_char(c: u8) -> bool {
    is_lowercase(c) || is_digit(c) || c == b'-' || c == b'_'
}

fn identifier<I: U8Input>(i: I) -> SimpleResult<I, String>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
        let first = satisfy(is_lowercase);
        let rest = take_while(is_identifier_char);
        ret {
            let rest_str = unsafe { from_utf8_unchecked(&*rest) };
            Some(first as char).into_iter().chain(rest_str.chars()).collect()
        }
    }
}

fn number<I: U8Input>(i: I) -> SimpleResult<I, i32> {
    parse!{i;
        signed(decimal)
    }
}

fn typename<I: U8Input>(i: I) -> SimpleResult<I, String>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
        let first = satisfy(is_uppercase);
        let rest = take_while(is_lowercase);
        ret {
            let rest_str = unsafe { from_utf8_unchecked(&*rest) };
            Some(first as char).into_iter().chain(rest_str.chars()).collect()
        }
    }
}

fn entry_item<I: U8Input>(i: I) -> SimpleResult<I, (String, i32)>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
        let field = identifier();
                    token(b'=');
        let value = number();
        ret (field, value)
    }
}

fn struct_item<I: U8Input>(i: I) -> SimpleResult<I, (String, String)>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
        let field = identifier();
                    token(b'=');
        let typenm = typename();
        ret (field, typenm)
    }
}

fn log_entry<I: U8Input>(i: I) -> SimpleResult<I, Vec<(String, i32)>>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
        let items = sep_by1(entry_item, |i| take_while1(i, is_horizontal_space));
                    skip_while(is_horizontal_space);
                    take_while1(is_end_of_line);
        ret items
    }
}

fn log_struct<I: U8Input>(i: I) -> SimpleResult<I, Vec<(String, String)>>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
        let items = sep_by1(struct_item, |i| take_while1(i, is_horizontal_space));
                    skip_while(is_horizontal_space);
                    take_while1(is_end_of_line);
        ret items
    }
}

fn log_file<I: U8Input>(i: I) -> SimpleResult<I, (Vec<(String, String)>, Vec<Vec<(String, i32)>>)>
    where I::Buffer: ::std::ops::Deref<Target=[u8]>
{
    parse!{i;
                      skip_while(is_whitespace);
        let strukt =  log_struct();
                      skip_while(is_whitespace);
        let entries = many(log_entry);
                      skip_while(is_whitespace);
                      eof();
        ret (strukt, entries)
    }
}

#[cfg(test)]
mod tests {
    use super::{identifier, number, typename, entry_item, struct_item};
    use super::{log_entry, log_struct, log_file};

    use chomp::parse_only;

    #[test]
    fn test_identifier() {
        assert_eq!(parse_only(identifier, b"date0-xyz "), Ok("date0-xyz".to_string()));
        assert_eq!(parse_only(identifier, b"a."), Ok("a".to_string()));
        assert_eq!(parse_only(identifier, b"abc-_-_."), Ok("abc-_-_".to_string()));
        assert_eq!(parse_only(identifier, b"asdF"), Ok("asd".to_string()));
        assert!(parse_only(identifier, b"Asdf").is_err());
        assert!(parse_only(identifier, b"_asdf").is_err());
    }

    #[test]
    fn test_number() {
        assert_eq!(parse_only(number, b"123"), Ok(123));
        assert_eq!(parse_only(number, b"+123"), Ok(123));
        assert_eq!(parse_only(number, b"-123"), Ok(-123));
        assert_eq!(parse_only(number, b"1234567890"), Ok(1234567890));
    }

    #[test]
    fn test_type() {
        assert_eq!(parse_only(typename, b"Num"), Ok("Num".to_string()));
        assert_eq!(parse_only(typename, b"Str"), Ok("Str".to_string()));
        assert_eq!(parse_only(typename, b"FixNum"), Ok("Fix".to_string()));
        assert!(parse_only(typename, b"asdf").is_err());
    }

    #[test]
    fn test_entry_item() {
        assert_eq!(parse_only(entry_item, b"chapter=12"), Ok(("chapter".to_string(), 12)));
    }

    #[test]
    fn test_struct_item() {
        assert_eq!(parse_only(struct_item, b"chapter=Num"), Ok(("chapter".to_string(), "Num".to_string())));
    }

    #[test]
    fn test_log_entry() {
        assert_eq!(parse_only(log_entry, b"abc=123  xyz=-42 a_b_c-1=0   \n\n\nasdf"),
                   Ok(vec![("abc".to_string(), 123),
                           ("xyz".to_string(), -42),
                           ("a_b_c-1".to_string(), 0)]));
    }

    #[test]
    fn test_log_struct() {
        assert_eq!(parse_only(log_struct, b"abc=Num  xyz=Str a_b_c-1=Bool  \n\n\nasdf"),
                   Ok(vec![("abc".to_string(), "Num".to_string()),
                           ("xyz".to_string(), "Str".to_string()),
                           ("a_b_c-1".to_string(), "Bool".to_string())]));
    }

    #[test]
    fn test_log_file() {
        assert_eq!(parse_only(log_file, b"abc=Num xyz=Num\n\nabc=1 xyz=2\nabc=3 xyz=4\n"),
                   Ok((vec![("abc".to_string(), "Num".to_string()), ("xyz".to_string(), "Num".to_string())],
                       vec![
                         vec![("abc".to_string(), 1), ("xyz".to_string(), 2)],
                         vec![("abc".to_string(), 3), ("xyz".to_string(), 4)]])));
    }

    #[test]
    fn test_parser() {
        let data = include_bytes!("../examples/tests/0.1.0.lum");
        assert!(parse_only(log_file, data).is_ok());
    }
}

