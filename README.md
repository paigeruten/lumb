# Lumb

*Note: This document talks about a lot of features that aren't done yet, it's
called README-driven development. To see the current state of what's
implemented, see `spec.md`.*

Lumb is a text file format for personal logging. For example, you can use it
to log:

  * What you read
  * When you sleep
  * What you eat
  * What you spend money on
  * Your travels
  * Time spent on projects
  * Configuration changes you make to your computer
  * Good/bad habits

You get to define all the data fields that each log contains. Any log entry can
be followed by an associated indented block of text, so you can use it as a
journal, or a journal that happens to have lots of computer-readable data
associated with each entry.

The format is designed for (1) manually typing new entries quickly, and (2)
maximum human readability and also prettiness.

## Example

Here is an example that allows you to log your money.

```lum
Date amount=Num{$} {tx* gift loan owed} dir={send/-> recv/<- earn/<~} to/from=Str comment=Str?

(2009-08-14) $3         -> "Pirate O's" | Sangria Señorial
(2009-08-19) $8         -> :diner       | Omelette & grapefruit juice
(2009-08-22) $12        -> :diner       | Chickpea burger
(2009-08-26) $150  owed -> :bloodcastle | Teeth cleaning
(2010-07-10) $170       -> :store       | Water filtration system
(2010-07-10) $4.23      -> :store       | 1.02 lb of black forest ham
(2010-07-10) $6.37      -> :store       | 1.42 lb of havarti
(2010-07-10) $1.29      -> :store       | Baguette
(2010-07-10) $3.29      -> :store       | Sunflower seed bread
(2010-07-10) $1.45      -> :store       | Four plums
(2010-07-10) $1.39      -> :store       | Tupperware-like container ("POLYBOX")
(2010-07-10) $1.09      -> :store       | Two cans, garbanzo beans
(2010-07-10) $0.79      -> :store       | Two cloves garlic (on sale)
(2010-07-10) $3.99      -> :store       | One bread tin
(2010-07-10) $1.89      -> :store       | Three cucumbers
(2010-07-10) $2.12      -> :store       | Sales tax for the above (8.2%)
(2010-07-12) $200  loan <- 'Paul Allen' | ???
(2012-12-13) $12        <~ :heddy       | Sold a story idea
(2013-04-12) $50        -> :carmichael  | Conceptual advertisement
(2013-04-19) $400  gift <- :anonymous   | Cashing in on my fame
(2013-04-19) $400  gift -> :anonymous   | Gave it all back
```

For more examples, look in the `examples` directory.

*Note: This is not my money log, I actually got this off a machine called
`georgie`, which I stumbled upon as a result of a mistyped IP address. The file
was `/floppy/money.lum`, and I managed to `scp` it to my machine, thus rescuing
and now reviving a lost file format. I tried to `scp` a few other
interesting-looking files (e.g. I seem to remember `jerktoast.rb`, and
`poignant2.yml`) but I got `scp: /dev/fd0: Input/output error`. Someone had
ejected the diskette. I still log in to Old Georgie every couple months, but so
far no one seems to be touching it. Poor thing has 1231 days of uptime and no
disk to boot from.*

## Type-checking

When you execute the `lumb` command with no arguments, it will go through all
your `.lum` files (in `~/logs/` by default), parsing and type-checking each
one. If there is a parse error or type error, it will complain, and tell you
how to fix it. This helps keep your logs consistent and orderly.

## Constraints

You can define additional constraints on your logs. For example, I give you
`daily.lum`:

```lum
Date !(date=^ || date=^+1) !(exists(date=$today))
```

This defines two constraints. The first one ensures that for each entry, the
`date` field is either the same as the previous entry's `date` field, or the
previous entry's `date` field plus one day. The second constraint ensures that
there is an entry for today's date. Together, this makes sure that an entry has
been made in the log for every single day from the first entry's `date` to the
present day. If you miss a day, you get an error. If you are unable to fill in
an entry for a certain period of time, you can place a `...` on its own line in
the log to represent missing data, and the constraint will be ignored for those
days. You can also mark today's entry with a `*` to mark it as incomplete, and
you'll get a warning until you complete the entry and remove the mark. That way
you can make sure not to leave behind any unfinished entries with weird data.

## Includes

The above file (`daily.lum`) can be included into any log like this:

```lum
<daily> brush floss
```

This sticks the `date` field from `daily.lum` along with its constraints onto
the front of this log, which defines `brush` and `floss` Boolean fields. Now
you are forced to account for every single day in this log, even if that day's
entry is blank (just a date).

If there is a `base.lum` in the `~/logs/` directory, it gets included by
default into all your logs. Mine looks like this:

```lum
Date ... notes=Str?
```

This sticks a `date` field on the front of all your logs, and a `notes` field
at the end.

