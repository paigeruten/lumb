module Lumb
  class Structure
    attr_reader :items, :ws

    def initialize(items, ws)
      @items, @ws = items, ws

      @slots = {}
      @items.map.with_index do |item, idx|
        @slots[item.slot] = idx
      end
    end

    def slot_index(name)
      @slots[name.to_sym]
    end

    def slot_type(name_or_index)
      name_or_index = slot_index(name_or_index) unless name_or_index.is_a? Fixnum
      @items[name_or_index].type
    end
  end

  class StructureItem
    attr_reader :slot, :type, :ws

    def initialize(slot, type, ws)
      @slot, @type, @ws = slot.to_sym, type.to_sym, ws

      if not [:Num, :Sym, :Date].include? @type
        raise "unrecognized type #{@type}"
      end
    end
  end
end

