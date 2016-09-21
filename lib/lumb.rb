require 'parslet'

module Lumb
  class Parser < Parslet::Parser
    rule(:newlines)    { match['\r\n'].repeat(1) }
    rule(:space)       { match[' \t\r\n'].repeat(1) }
    rule(:hspace)      { match[' \t'].repeat(1) }
    rule(:delim_space) { hspace | newlines.present? }

    rule(:identifier)  { match['a-z'] >> match['a-z0-9_-'].repeat }
    rule(:type)        { match['A-Z'] >> match['a-z'].repeat }
    rule(:number)      { match['0-9'].repeat(1) }

    rule(:struct_item) {
      identifier.as(:field) >>
      str('=')              >>
      type.as(:type)        >>
      delim_space.as(:ws)
    }

    rule(:entry_item) {
      identifier.as(:field) >>
      str('=')              >>
      number.as(:value)     >>
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

    rule(:file) {
      space.maybe.as(:ws_pre)  >>
      struct.as(:struct)        >>
      space.maybe.as(:ws_mid)  >>
      entry.repeat.as(:entries) >>
      space.maybe.as(:ws_post)
    }

    root(:file)
  end

  class Transform < Parslet::Transform
    rule(:field => simple(:field), :type => simple(:type), :ws => simple(:ws)) {
      StructItem.new(field, type, ws)
    }
    rule(:field => simple(:field), :value => simple(:value), :ws => simple(:ws)) {
      EntryItem.new(field, value, ws)
    }
    rule(:items => sequence(:items), :ws => simple(:ws)) {
      if items.first.is_a? StructItem
        LogStruct.new(items, ws)
      else
        LogEntry.new(items, ws)
      end
    }
    rule(:ws_pre => simple(:ws_pre), :struct => simple(:struct), :ws_mid => simple(:ws_mid), :entries => sequence(:entries), :ws_post => simple(:ws_post)) {
      LogFile.new(struct, entries, ws_pre, ws_mid, ws_post)
    }
  end

  class StructItem
    def initialize(field, type, ws)
      @field, @type, @ws = field, type, ws
    end

    def to_s
      "#{@field}=#{@type}#{@ws}"
    end
  end

  class EntryItem
    def initialize(field, value, ws)
      @field, @value, @ws = field, value, ws
    end

    def to_s
      "#{@field}=#{@value}#{@ws}"
    end
  end

  class LogStruct
    def initialize(items, ws)
      @items, @ws = items, ws
    end

    def to_s
      "#{@items.join}#{@ws}"
    end
  end

  class LogEntry
    def initialize(items, ws)
      @items, @ws = items, ws
    end

    def to_s
      "#{@items.join}#{@ws}"
    end
  end

  class LogFile
    def initialize(struct, entries, ws_pre, ws_mid, ws_post)
      @struct, @entries, @ws_pre, @ws_mid, @ws_post = struct, entries, ws_pre, ws_mid, ws_post
    end

    def to_s
      "#{@ws_pre}#{@struct}#{@ws_mid}#{@entries.join}#{@ws_post}"
    end
  end

  def self.parse(str)
    Transform.new.apply(Parser.new.parse(str))
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
  end
end

