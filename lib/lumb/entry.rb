module Lumb
  class Entry
    attr_reader :items, :ws

    def initialize(structure, items, ws)
      @structure, @items, @ws = structure, items, ws

      @slots = []
      @items.each do |item|
        @slots[@structure.slot_index(item.slot)] = item.value
      end

      @structure.items.each.with_index do |item, idx|
        if @slots[idx].nil?
          raise "slot '#{item.slot}' is missing from entry"
        elsif @slots[idx].type != item.type
          raise "type mismatch: expected '#{item.type}', got '#{@slots[idx].type}'"
        end
      end
    end

    def slot(name)
      @slots[@structure.slot_index(name)]
    end
  end

  class EntryItem
    attr_reader :slot, :value, :ws

    def initialize(slot, value, ws)
      @slot, @value, @ws = slot.to_sym, value, ws
    end
  end
end

