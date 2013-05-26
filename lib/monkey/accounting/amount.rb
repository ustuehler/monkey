require 'bigdecimal'

require 'monkey/accounting'

module Monkey::Accounting

  # The +Amount+ class represents an amount of a commodity, like
  # money of a certain currency, stock shares, or work hours.
  #
  # The implementation of this class is based to a large extent on
  # amount.cc from the original ledger program (see
  # http://ledger-cli.org).
  class Amount
    attr_accessor :quantity, :commodity, :precision

    # Creates an amount from +commodity+ and +quantity+.  +commodity+
    # is a (possibly empty) string denoting a fictional or a well-known
    # currency, stock symbol or other unit.  +quantity+ is a numeric
    # value accepted by the BigDecimal.new constructor.
    def initialize(commodity, quantity)
      # Determine the initial precision from the quantity argument.
      s = case quantity
          when BigDecimal
            quantity.to_s('F')
          else
            quantity.to_s
          end
      @precision = s.length - s.rindex('.') - 1

      @commodity = commodity
      @quantity = BigDecimal.new(quantity)
    end

    def +(x); same_currency_op x, :+; end
    def -(x); same_currency_op x, :-; end

    def *(x); numeric_op x, :*; end
    def /(x); numeric_op x, :/; end

    def -@
      a = self.class.new @commodity, -@quantity
      a.precision = @precision
      a
    end

    # Coerces +value+ into an +Amount+ instance.  If +value+ is not
    # already an +Amount+, it should be a +String+ accepted by the
    # #parse method.
    def self.coerce(value)
      case value
      when Amount
        value
      when String
        parse value
      else
        raise ArgumentError, "can't coerce #{value.inspect} into #{self}"
      end
    end

    COMMODITY_STYLE_DEFAULT   = 0x0000
    COMMODITY_STYLE_SEPARATED = 0x0001
    COMMODITY_STYLE_SUFFIXED  = 0x0002
    COMMODITY_STYLE_THOUSANDS = 0x0004
    COMMODITY_STYLE_EUROPEAN  = 0x0008

    AMOUNT_PARSE_DEFAULT    = 0x0000
    AMOUNT_PARSE_NO_MIGRATE = 0x0001
    AMOUNT_PARSE_NO_REDUCE  = 0x0004

    # Parse the given +input+ object as a sequence of characters.
    # The +input+ object must have a #chars method that returns an
    # +Enumerator+ over a sequence of single-character strings.
    def self.parse(input, flags = AMOUNT_PARSE_DEFAULT)
      chars = BetterEnumerator.new(input.chars)
      negative = false
      comm_flags = 0

      begin
        if (c = chars.peek_next_nonws) == '-'
          negative = true
          chars.next
          c = chars.peek_next_nonws
        end

        if c =~ /\d/
          quantity = parse_quantity(chars)

          if !chars.eof? and (n = chars.peek) != "\n"
            comm_flags |= COMMODITY_STYLE_SEPARATED if n =~ /\s/

            symbol = parse_commodity(chars)

            comm_flags |= COMMODITY_STYLE_SUFFIXED if !symbol.empty?

            price, date, tag = parse_annotations(chars) if
              !chars.eof? and (n = chars.peek) != "\n"
          else
            symbol = ''
          end
        else
          symbol = parse_commodity(chars)

          if (chars.peek rescue nil) and (n = chars.peek) != "\n"
            comm_flags |= COMMODITY_STYLE_SEPARATED if n =~ /\s/

            quantity = parse_quantity(chars)

            price, date, tag = parse_annotations(chars) if
              !quantity.empty? and !chars.eof? and
              (n = chars.peek) != "\n"
          else
            quantity = ''
          end
        end

        raise ParseError, "can't parse #{input.inspect}: " +
          "no quantity for amount" if quantity.empty?

        newly_created = false

        if symbol.empty?
          commodity = Commodity.null_commodity
        else
          if !(commodity = Commodity.find(symbol))
            commodity = Commodity.create(symbol)
            newly_created = true
          end

          # TODO: support annotated commodities
        end

        last_comma = quantity.rindex(',')
        last_period = quantity.rindex('.')

        if last_comma and last_period
          comm_flags |= COMMODITY_STYLE_THOUSANDS
          if last_comma > last_period
            comm_flags |= COMMODITY_STYLE_EUROPEAN
            precision = quantity.length - last_comma - 1
          else
            precision = quantity.length - last_period - 1
          end
        elsif last_comma and (!Commodity.default_commodity ||
                              (Commodity.default_commodity.flags &
                               COMMODITY_STYLE_EUROPEAN) != 0)
          comm_flags |= COMMODITY_STYLE_EUROPEAN
          precision = quantity.length - last_comma - 1
        elsif last_period and (commodity.flags &
                               COMMODITY_STYLE_EUROPEAN) == 0
          precision = quantity.length - last_period - 1
        else
          precision = 0
        end

        if (flags & AMOUNT_PARSE_NO_MIGRATE) == 0
          commodity.add_flags comm_flags
          if precision > commodity.precision
            commodity.precision = precision
          end
        else
          # FIXME: quantity->flags |= BIGINT_KEEP_PREC ???
        end

        quantity.gsub!(/[,.]/, '')
        if precision > 0
          int = quantity[0...-precision]
          frac = quantity[-precision..-1]
          quantity = "#{int}.#{frac}"
        end
        quantity = "-#{quantity}" if negative
        quantity = BigDecimal.new quantity

        if (flags & AMOUNT_PARSE_NO_REDUCE) == 0
          while commodity.smaller
            quantity *= commodity.smaller.quantity
            commodity = commodity.smaller.commodity
          end
        end

        amount = new commodity, quantity
        amount.precision = precision
        amount
      rescue ParseError => e
        raise ParseError, "can't parse #{input.inspect}: " +
          e.message
      rescue StopIteration => e
        raise ParseError, "can't parse #{input.inspect}: " +
          "unexpected end of input (backtrace follows)\n" +
          e.backtrace.join("\n")
      end
    end

    def to_s
      if precision == 0
        quant_str = quantity.round.to_s
      else
        int, frac = quantity.round(precision).to_s('F').split('.')

        if (commodity.flags & COMMODITY_STYLE_THOUSANDS) != 0
          int_ts = ''
          while int.length > 3
            int_left = int[0...-3]
            int_ts = "#{int_left},#{int[-3..-1]}"
            int = int_left
          end
          int = int_ts
        end

        quant_str = int +
          ((commodity.flags & COMMODITY_STYLE_EUROPEAN) != 0 ?
           ',' : '.') +
          ('0' * (precision - frac.length)) +
          frac
      end

      if (commodity.flags & COMMODITY_STYLE_SUFFIXED) != 0
        quant_str +
          ((commodity.flags & COMMODITY_STYLE_SEPARATED) != 0 ?
           ' ' : '') +
          commodity.to_s
      else
        commodity.to_s +
          ((commodity.flags & COMMODITY_STYLE_SEPARATED) != 0 ?
           ' ' : '') +
          quant_str
      end
    end

    private

    def same_currency_op(x, op)
      x = self.class.coerce(x)

      if x.commodity != @commodity
        raise ArgumentError, "non-matching commodity for #{x}, " +
          "expected #{@commodity}"
      end

      new_quantity = @quantity.send(op, x.quantity)

      # TODO: handle price
      result = self.class.new(commodity, new_quantity)
      result.precision = [@precision, x.precision].max
      result
    end

    def numeric_op(x, op)
      raise ArgumentError, "non-numeric argument for #{op}: " +
        x.inspect unless x.is_a? Numeric

      new_quantity = @quantity.send(op, x)

      # TODO: handle price
      result = self.class.new(commodity, new_quantity)
      result.precision = @precision
      result
    end

    class ParseError < RuntimeError
    end

    class BetterEnumerator < Enumerator
      def peek_next_nonws
        while (c = peek) =~ /\s/
          self.next
        end
        c
      end

      def eof?
        begin
          self.peek
          false
        rescue StopIteration
          true
        end
      end

      def read_while(&block)
        s = ''
        while yield(c = peek)
          if (c = self.next) == '\\'
            c = self.next
          end
          s << c
          break if eof?
        end
        s
      end
    end

    # Invalid commodity characters
    INVALID_CHARS = " \t\n\r0123456789.,;-+*/^?:&|!=<>{}[]()@"

    def self.parse_commodity(chars)
      if chars.peek_next_nonws == '"'
        chars.next
        symbol = chars.read_while { |c| !"\n\"".include?(c) }
        raise ParseError, "unterminated quoted commodity symbol: " +
          symbol.inspect if chars.peek != '"'
        chars.next
      else
        symbol = chars.read_while { |c| !INVALID_CHARS.include?(c) }
      end
      symbol
    end

    def self.parse_quantity(chars)
      chars.peek_next_nonws
      chars.read_while { |c| c =~ /[\d.,-]/ }
    end

    def self.parse_annotations(chars)
      ''
    end

  end

end
