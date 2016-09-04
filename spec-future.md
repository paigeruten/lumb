* Structs
  * Defined on a single line at the top of the log file that contains a space-
    separated list of parts
  * Each part is one of:
    * A field-type pair, e.g. `name=Str`
    * A field-type pair with field or type elided, e.g. `Date` or `brushed`
    * An operator field name, which must be followed by a type in the next part
    * An include, e.g. `<parent>` or `...` or `...parent...`
    * A type-type pair, defining a type synonym usually for structs that
      include this one, e.g. `Dur=Num{s m=60 h=3600}`
  * Any field can have multiple names/aliases, by separating the different
    names with `/`, e.g. `name/names=[Str]`
    * Plurals can use the `name(s)=[Str]` syntax, which is sugar for the above
  * Structs can also have constraints, but I haven't figured out the syntax
* Entries
  * Each defined on a single line (except for a possible indented `Str` value)
    that contains a space-separated list of parts
  * Each part is one of:
    * A field-value pair, e.g. `pages=30`
    * A field-value pair with field or value elided, e.g. `30` or `brushed`
    * An operator
    * A missing data indicator, `...`, in which case the entry should have no
      other parts to it
    * A `*` character, which indicates that the entry is incomplete
* Comments
  * Start with `#` and proceed to the end of the line
  * Lines containing pipe strings or indented strings can't contain comments
* Types
  * `Bool`
    * Default field name: `bool`
    * Values: `true` / `yes` and `false` / `no`
    * In structs, `Bool` is the assumed type when the type is elided
    * In entries, the `true` and `false` values are rarely used, since fields
      are `false` by default and can be flipped to `true` by specifying just
      the field name and eliding the value
  * `Num`
    * Default field name: `num`, or the default unit if the `Num` uses units
    * A number, either integer or float (like JavaScript?)
    * Can contain underscores as separators, maybe even commas (commas could
      also be used as decimal points)
    * `Num` types can have units defined in curly braces after the `Num`
      * e.g. `dist=Num{km}` in the struct means you can do `100km` in the entry
      * e.g. `Num{km}` will have a default field name of `km`
      * e.g. `dur=Num{s m=60 h=3600}` means you can do `45s` or `2m` or `1h` in
        the entry, any of which will fill the same `dur` field but the numeric
        value will be multiplied by the unit chosen
        * You could also combine units, e.g. `1h45m`
      * e.g. `amount=Num{$}` means you can do `20$` but you can also use `$` as
        a field-name operator without any spacing, to do `$20`
      * e.g. `progress=Num{%=0.01}` means you can do `65%` and `0.65` will be
        stored in the field
      * Each unit name is also an alias of the field name
  * `Date`
    * Default field name: `date`
    * Values in the YYYY-MM-DD format
  * `Time`
    * Default field name: `time`
    * Values in the format HH:MM:SS, where the hour field may be one or two
      digits, the seconds field may be elided, and the value may be followed by
      `am` or `pm`
      * The minutes and seconds fields may both be elided, but then the value
        *must* end in `am` or `pm`
  * `Str`
    * Default field name: `str`
    * Values may be single-quoted or double-quoted
    * A `|` symbol in an entry starts a Str value that lasts until the end of
      the line
    * Consecutive indented lines after an entry are interpreted as one large
      Str value at the end of the entry (known as an indented `Str`)
  * `Sym` (subtype of `Str`)
    * Default field name: `sym`
    * Values start with a `:` followed by a string matching the regex
      `[a-z][a-z0-9\-_]*`
    * There is special syntax for an `Array` of `Sym`s in entries: curly braces
      containing a space-separated list of symbols, each matching the above
      regex
      * e.g. `{first second third}` is the same as `[:first :second :third]`
  * `Enum`
    * Default field name: `type`
    * In structs, an `Enum` type is defined as a space-separated list of one or
      more symbols wrapped in curly braces
    * Each symbol becomes usable as a value for that field in entries
    * Only one value may be selected for an `Enum` field
    * A default value may be defined in the struct by marking it with a `*`
    * Enum variants may have aliases, defined by separating them with `/`
    * Enum variants may be operators
    * e.g. `dir={send/->* recv/<-}` defines `send` and `->` as aliases and the
      default, and `recv` and `<-` as aliases
  * `Array`
    * Default field name: the contained type's default field name, but
      pluralized
    * Default value: `[]`
    * In structs, an `Array` type is defined as a pair of square brackets
      containing another type, e.g. `[Str]` for an `Array` of `Str`s
    * In entries, an `Array` value is a pair of square brackets containing zero
      or more space-separated values
    * Every type `T` is a subtype of type `[T]`
  * Fields whose type has subtypes can be filled with values of those subtypes
  * Any value can be wrapped in parentheses
* Operators
  * Special field-names or Enum values that consist only of symbols
  * Each operator in structs and entries must be delimited by spaces to form
    its own part (there are exceptions, like the value `$20`)
  * The type or value in the part following an operator will be associated with
    that operator field
  * Non-operator aliases can be defined normally in structs using `fieldname=`
    notation after the operator part
  * Operator aliases can be defined by having more than one operator part in a
    row, before the type part
  * Operator fields can also just be defined like any other field, with `=` and
    `/` for aliases, the other syntax is just sugar
  * Boolean operator fields can appear on their own like other Bool fields
    * This could be used to implement `*` to mark incomplete entries. Just add
      a constraint (warning-constraint?) in `base.lum` that `*` must be false
* Includes
  * `...` (child include spot for an abstract log)
  * `<parent>` (to include `parent.lum` at its default child spot, or just at the top)
  * `...parent...` (to include it at that spot)
  * Every struct definition implicitly includes `base` if a `base.lum` can be
    found
* Elisions
  * A type by itself uses a default field name, e.g. `Date` becomes `date=Date`
  * A field name by itself has type `Bool` (in structs) or value `true` (in entries)
  * Optional fields have a `?` after the type, and can be omitted in entries
    * `Array` types can be omitted and have a default value of `[]`
    * `Bool` types can be omitted and have a default value of `false`
    * All other fields are required unless marked as optional, in which case
      their default value is `nil`
  * Elided field names in entries are inferred based on the types and order of
    the values compared to the order of the fields in the struct
  * If a type is defined with a `!` after it, then the field name for that
    field cannot be elided
    * Implies that the field is optional
    * Operator fields have this behaviour by default
* Constraints
  * A struct can have additional constraints associated with it
  * Possible syntax: `!(date=^ || date=^+1)`
    * This would ensure that for each entry, the `date` field is equal to the
      `date` field of the previous entry, *or* the `date` field is equal to the
      previous `date` field plus one day. Constraints referring to the
      previous field would be ignored for entries whose previous field is `...`
      (which represents missing data)
* Symbol replacement
  * Each log, or perhaps a group of logs, may have a list of `Sym` values and
    what each symbol stands for as it is used on those logs. Symbols can only
    be replaced by strings, not any other value. Symbol replacements can be
    defined for specific fields of specific logs, or for entire logs, or
    globally defined.
  * When the log is parsed and processed into data structures, each `Sym` will
    be able to be looked up in the symbol table for its `Str` replacement
  * This allows users to have very succinct and easy-to-type logs, e.g. you can
    just type someone's first name, all lowercase, and then put their full
    unambiguous name in the symbol table
  * The list of symbols could go at the top of the log file, or in a separate
    file with a special extension and format
  * This may turn out to be useful enough to expand to replace symbols with
    other types of values, but we'll keep typechecking simple for now

