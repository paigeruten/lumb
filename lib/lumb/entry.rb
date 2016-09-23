module Lumb
  class Entry
    attr_reader :items, :ws

    def initialize(structure, items, ws)
      @structure, @items, @ws = structure, items, ws

      @slots = Array.new(@structure.num_slots)
      @items.each do |item|
        if item.slot
          idx = @structure.slot_index(item.slot)
          raise "slot '#{item.slot}' doesn't exist" if idx.nil?
        else
          # leftmost empty slot
          idx = @slots.index(nil)
          raise "too many values in entry" if idx.nil?
        end
        @slots[idx] = item.value
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

    def to_a
      @slots.map { |s| s && s.value }
    end

    def to_h
      @slots.map.with_index { |s, i| [@structure.slot_name(i), @slots[i] && @slots[i].value] }.to_h
    end
  end

  class EntryItem
    attr_reader :slot, :value, :ws

    def initialize(slot, value, ws)
      @slot, @value, @ws = slot, value, ws
      @slot = @slot.to_sym if @slot
    end
  end
end

