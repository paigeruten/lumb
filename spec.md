# Current spec of the Lumb (`.lum`) file format

Note: This document only describes the features that the current version of the
code is trying to implement. `spec-future.md` contains *all* the features I am
currently envisioning for a `1.0` release, or beyond.

## Example

Here is an example of a reading log for a book you're reading. You would add a
new entry every day, entering the date, the chapter you're currently on, and
the number of pages you read that day.

```lum
date=Date author=Sym chapter=Num pages=Num

2016-08-28 :vonnegut chapter=1 pages=22
2016-08-29 :vonnegut chapter=2 pages=10
2016-08-30 :vonnegut chapter=2 pages=0
2016-08-31 :vonnegut chapter=4 pages=45
```

## File

A Lumb file should end in `.lum` and contain only text.

The first line must be a [structure](#structure) that defines the structure of
the entries that follow.

The rest of the lines contain zero or more [entries](#entries), one on each
non-blank line.

## Structure

A structure defines the slots and types of those slots that each entry will
fill out with values.

A structure occupies one line of text. It is made up of one or more structure
items separated by whitespace.

A structure item is an [identifier](#identifiers) (the slot name), followed by
an `=` char, followed by a [type](#types).

## Entries

An entry assigns values to the slots defined by the structure.

Each entry occupies one line of text. It is made up of one or more entry items
separated by whitespace.

An entry item is an [identifier](#identifiers) (the slot name), followed by an
`=` char, followed by a [value](#types).

An entry item may [elide](#elision) the slot name, so that it consists only of
a [value](#types).

## Identifiers

Identifiers are strings matching the regex `[a-z][a-zA-Z0-9_\-]`.

## Types

Each slot has a type, and each value has a type. When assigning a value to a
slot in an entry, the type of the value must match the type of the slot as
defined by the structure.

### Num

A number. Currently only positive and negative integers are supported.

Example values: `0`, `1`, `+42`, `-50`, `1000009`.

### Sym

A symbol is a `:` char followed by one or more non-whitespace characters.

Example values: `:foo`, `:abc123`, `:hello?`, `:[]`, `:!@#$%^&*()`, `:::`.

### Date

A date consists of a year, month, and day in the `YYYY-MM-DD` format.

Example values: `2016-09-23`, `1970-01-01`.

## Elision

Slot names may be elided in entries. In this case, the value is assigned to the
leftmost slot that hasn't been assigned a value yet.

