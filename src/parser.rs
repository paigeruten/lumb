use chomp::prelude::*;
use chomp::parsers::skip_while1; // not currently in prelude
use chomp::ascii::*;

fn is_identifier_char(c: u8) -> bool {
    is_lowercase(c) || is_digit(c) || c == b'-' || c == b'_'
}

fn identifier<I: U8Input>(i: I) -> SimpleResult<I, (I::Token, I::Buffer)> {
    parse!{i;
        let first = satisfy(is_lowercase);
        let rest  = take_while(is_identifier_char);
        ret (first, rest)
    }
}

fn number<I: U8Input>(i: I) -> SimpleResult<I, i32> {
    parse!{i;
        signed(decimal)
    }
}

fn typename<I: U8Input>(i: I) -> SimpleResult<I, (I::Token, I::Buffer)> {
    parse!{i;
        let first = satisfy(is_uppercase);
        let rest  = take_while(is_lowercase);
        ret (first, rest)
    }
}

fn entry_item<I: U8Input>(i: I) -> SimpleResult<I, (I::Buffer, i32)> {
    parse!{i;
        let (field, _) = matched_by(identifier);
                         token(b'=');
        let value = number();
        ret (field, value)
    }
}

fn struct_item<I: U8Input>(i: I) -> SimpleResult<I, (I::Buffer, I::Buffer)> {
    parse!{i;
        let (field, _) = matched_by(identifier);
                         token(b'=');
        let (typ, _)   = matched_by(typename);
        ret (field, typ)
    }
}

fn log_entry<I: U8Input>(i: I) -> SimpleResult<I, Vec<(I::Buffer, i32)>> {
    parse!{i;
        let items = sep_by1(entry_item, |i| skip_while1(i, is_horizontal_space));
                    skip_while(is_horizontal_space);
                    skip_while1(is_end_of_line);
        ret items
    }
}

fn log_struct<I: U8Input>(i: I) -> SimpleResult<I, Vec<(I::Buffer, I::Buffer)>> {
    parse!{i;
        let items = sep_by1(struct_item, |i| skip_while1(i, is_horizontal_space));
                    skip_while(is_horizontal_space);
                    skip_while1(is_end_of_line);
        ret items
    }
}

fn log_file<I: U8Input>(i: I) -> SimpleResult<I, (Vec<(I::Buffer, I::Buffer)>, Vec<Vec<(I::Buffer, i32)>>)> {
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
        assert_eq!(parse_only(identifier, b"date0-xyz "), Ok((b'd', &b"ate0-xyz"[..])));
        assert_eq!(parse_only(identifier, b"a."), Ok((b'a', &b""[..])));
        assert_eq!(parse_only(identifier, b"abc-_-_."), Ok((b'a', &b"bc-_-_"[..])));
        assert_eq!(parse_only(identifier, b"asdF"), Ok((b'a', &b"sd"[..])));
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
        assert_eq!(parse_only(typename, b"Num"), Ok((b'N', &b"um"[..])));
        assert_eq!(parse_only(typename, b"Str"), Ok((b'S', &b"tr"[..])));
        assert_eq!(parse_only(typename, b"FixNum"), Ok((b'F', &b"ix"[..])));
        assert!(parse_only(typename, b"asdf").is_err());
    }

    #[test]
    fn test_entry_item() {
        assert_eq!(parse_only(entry_item, b"chapter=12"), Ok((&b"chapter"[..], 12)));
    }

    #[test]
    fn test_struct_item() {
        assert_eq!(parse_only(struct_item, b"chapter=Num"), Ok((&b"chapter"[..], &b"Num"[..])));
    }

    #[test]
    fn test_log_entry() {
        assert_eq!(parse_only(log_entry, b"abc=123  xyz=-42 a_b_c-1=0   \n\n\nasdf"),
                   Ok(vec![(&b"abc"[..], 123),
                           (&b"xyz"[..], -42),
                           (&b"a_b_c-1"[..], 0)]));
    }

    #[test]
    fn test_log_struct() {
        assert_eq!(parse_only(log_struct, b"abc=Num  xyz=Str a_b_c-1=Bool  \n\n\nasdf"),
                   Ok(vec![(&b"abc"[..], &b"Num"[..]),
                           (&b"xyz"[..], &b"Str"[..]),
                           (&b"a_b_c-1"[..], &b"Bool"[..])]));
    }

    #[test]
    fn test_log_file() {
        assert_eq!(parse_only(log_file, b"abc=Num xyz=Num\n\nabc=1 xyz=2\nabc=3 xyz=4\n"),
                   Ok((vec![(&b"abc"[..], &b"Num"[..]), (&b"xyz"[..], &b"Num"[..])],
                       vec![
                         vec![(&b"abc"[..], 1), (&b"xyz"[..], 2)],
                         vec![(&b"abc"[..], 3), (&b"xyz"[..], 4)]])));
    }

    #[test]
    fn test_parser() {
        let data = include_bytes!("../examples/tests/0.1.0.lum");
        assert!(parse_only(log_file, data).is_ok());
    }
}

