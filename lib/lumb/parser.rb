require 'parslet'

module Lumb
  class Parser < Parslet::Parser
    rule(:newlines)    { match['\r\n'].repeat(1) }
    rule(:space)       { match[' \t\r\n'].repeat(1) }
    rule(:hspace)      { match[' \t'].repeat(1) }
    rule(:delim_space) { hspace | newlines.present? }

    rule(:slot)        { match['a-z'] >> match['a-zA-Z0-9_-'].repeat }
    rule(:type)        { match['A-Z'] >> match['a-z'].repeat }
    rule(:number)      { (match['+-'].maybe >> match['0-9'].repeat(1)).as(:number) }
    rule(:symbol)      { (str(':') >> match['\S'].repeat(1)).as(:symbol) }
    rule(:date) {
      (match['0-9'].repeat(4, 4) >>
       str('-') >>
       match['0-9'].repeat(2, 2) >>
       str('-') >>
       match['0-9'].repeat(2, 2)).as(:date)
    }

    rule(:value) {
      date | number | symbol
    }

    rule(:struct_item) {
      slot.as(:slot)      >>
      str('=')            >>
      type.as(:type)      >>
      delim_space.as(:ws)
    }

    rule(:entry_item) {
      slot.as(:slot)      >>
      str('=')            >>
      value.as(:value)    >>
      delim_space.as(:ws)
    }

    rule(:struct) {
      struct_item.repeat(1).as(:items) >>
      newlines.as(:ws)
    }

    rule(:entry) {
      entry_item.repeat(1).as(:items) >>
      newlines.as(:ws)
    }

    rule(:table) {
      space.maybe.as(:ws_pre)  >>
      struct.as(:struct)        >>
      space.maybe.as(:ws_mid)  >>
      entry.repeat.as(:entries) >>
      space.maybe.as(:ws_post)
    }

    root(:table)
  end

  class Transform < Parslet::Transform
    rule(:number => simple(:number)) {
      Value.new(:Num, number)
    }
    rule(:symbol => simple(:symbol)) {
      Value.new(:Sym, symbol)
    }
    rule(:date => simple(:date)) {
      Value.new(:Date, date)
    }
    rule(:slot => simple(:slot), :type => simple(:type), :ws => simple(:ws)) {
      StructureItem.new(slot, type, ws)
    }
    rule(:slot => simple(:slot), :value => simple(:value), :ws => simple(:ws)) {
      EntryItem.new(slot, value, ws)
    }
    rule(:items => sequence(:items), :ws => simple(:ws)) { |dict|
      items, ws = dict[:items], dict[:ws]

      if items.first.is_a? StructureItem
        @structure = Structure.new(items, ws)
      else
        Entry.new(@structure, items, ws)
      end
    }
    rule(:ws_pre => simple(:ws_pre), :struct => simple(:struct), :ws_mid => simple(:ws_mid), :entries => sequence(:entries), :ws_post => simple(:ws_post)) {
      Table.new(struct, entries, ws_pre, ws_mid, ws_post)
    }
  end

  def self.parse(str)
    Transform.new.apply(Parser.new.parse(str))
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
    raise
  end
end

