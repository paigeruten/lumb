require 'date'

module Lumb
  class Value
    attr_reader :type, :value, :raw

    def initialize(type, raw)
      @type = type
      @value = nil
      @raw = raw

      case @type
      when :Num
        @value = @raw.to_i
      when :Sym
        @value = @raw.to_s[1..-1].to_sym
      when :Date
        @value = Date.parse(@raw)
      end
    end
  end
end

