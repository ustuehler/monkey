require 'monkey/accounting'

module Monkey::Accounting

  class Commodity < String

    attr_accessor :flags, :precision, :smaller, :larger

    def initialize(symbol)
      super(symbol)

      @flags = 0
      @precision = 0
      @smaller = nil
      @larger = nil
    end

    def add_flags(flags)
      @flags |= flags
    end

    @@table ||= {}

    def self.coerce(value)
      case value
      when Commodity
        value
      else
        find(value.to_s) or raise ArgumentError,
          "can't coerce #{value.inspect} into #{self}"
      end
    end

    def self.create(symbol)
      symbol = symbol.to_s
      if @@table.has_key? symbol
        raise "commodity already exists: " +
          symbol.inspect
      else
        @@table[symbol] = Commodity.new(symbol)
      end
    end

    def self.find(symbol)
      symbol = symbol.to_s
      @@table[symbol]
    end

    @@null_commodity ||= Commodity.create('')
    @@default_commodity = nil unless defined? @@default_commodity

    def self.null_commodity
      @@null_commodity
    end

    def self.default_commodity
      @@default_commodity
    end

    def self.default_commodity=(commodity)
      @@default_commodity = commodity
    end

  end

end
