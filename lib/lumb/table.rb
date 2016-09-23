module Lumb
  class Table
    attr_reader :structure, :entries, :ws_pre, :ws_mid, :ws_post

    def initialize(structure, entries, ws_pre, ws_mid, ws_post)
      @structure, @entries = structure, entries
      @ws_pre, @ws_mid, @ws_post = ws_pre, ws_mid, ws_post
    end

    def to_a
      entries.map(&:to_a)
    end

    def to_h
      { :structure => structure.to_h, :entries => entries.map(&:to_h) }
    end
  end
end

