# Current spec of the Lumb (`.lum`) file format

Note: This document only describes the features that the current version of the
code is trying to implement. `spec-future.md` contains *all* the features I am
currently envisioning for a `1.0` release, or beyond.

## Example

Here is an example of a reading log for a book you're reading. You would add a
new entry every day, entering the date, the chapter you're currently on, and
the number of pages you read that day.

```lum
date=Num chapter=Num pages=Num

date=20160828 chapter=1 pages=22
date=20160829 chapter=2 pages=10
date=20160830 chapter=2 pages=0
date=20160831 chapter=4 pages=45
```

## File

A Lumb file should end in `.lum` and contain only text.

The first line must be a [log struct](#log-struct) that defines the structure
of the log entries that follow.

The rest of the lines contain zero or more [log entries](#log-entries), one on
each non-blank line.

## Log Struct

A log struct defines the fields and types of those fields that each log entry
will fill out with values.

A log struct occupies one line of text. It is made up of one or more struct
items separated by whitespace.

A struct item is an [identifier](#identifiers) (the field name), followed by an
`=` char, followed by a [type](#types).

## Log Entries

A log entry assigns values to the fields defined by the log struct.

Each log entry occupies one line of text. It is made up of one or more entry
items separated by whitespace.

An entry item is an [identifier](#identifiers) (the field name), followed by an
`=` char, followed by a [value](#types).

## Identifiers

Identifiers are strings matching the regex `[a-z][a-z0-9_\-]`.

## Types

Each field has a type, and each value has a type. When assigning a value to a
field in a log entry, the type of the value must match the type of the field as
defined by the log struct.

### Num

A number. Currently only positive and negative integers are supported.

Example values: `0`, `1`, `42`, `-50`, `1000001`.

