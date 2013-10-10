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
    attr_reader :commodity

    attr_accessor :quantity, :precision

    # Change the amount's commodity symbol.
    #
    # @param value  a commodity symbol (see {Commodity.find_or_create}),
    #  or an instance of {Commodity}
    def commodity=(value)
      @commodity = Commodity.find_or_create(value)
    end

    # Creates an amount of the exact _quantity_ and _commodity_.
    # More often, you'll want to use the {parse} method.
    #
    # @param commodity [Commodity,String]  a (possibly empty) string
    #  denoting a fictional or a well-known currency, stock symbol or
    #  other unit.  The commodity denoted by a String must already
    #  exist (see {Commodity.create}).  Alternatively, an instance of
    #  {Commodity} may be given.
    # @param quantity  a numeric value accepted by the BigDecimal.new
    #  constructor
    def initialize(commodity, quantity)
      # Determine the initial precision from the quantity argument.
      s = case quantity
          when BigDecimal
            quantity.to_s('F')
          else
            quantity.to_s
          end
      if decimal_point = s.rindex('.')
        @precision = s.length - decimal_point - 1
      else
        @precision = 0
      end

      @commodity = Commodity.coerce(commodity)
      @quantity = BigDecimal.new(s)
    end

    def +(x); same_currency_op x, :+; end
    def -(x); same_currency_op x, :-; end

    def *(x); numeric_op x, :*; end
    def /(x); numeric_op x, :/; end

    include Comparable # implements comparison operators using <=>

    def zero?
      @quantity.zero?
    end

    def <=>(x)
      if zero? or (x.respond_to?(:zero?) and x.zero?)
        if x.respond_to?(:quantity)
          @quantity <=> x.quantity
        elsif x.is_a?(Numeric)
          @quantity <=> x
        else
          # Can't compare even zero against something that isn't
          # numeric.
          # TODO: should an error be raised here?
          nil
        end
      elsif x.respond_to?(:commodity) and x.respond_to?(:quantity)
        if @commodity == x.commodity
          @quantity <=> x.quantity
        else
          # Can't compare non-zero quantities of different commodities.
          # TODO: should an error be raised here?
          nil
        end
      else
        # Can't compare against something that has no commodity and
        # quantity.
        # TODO: should an error be raised here?
        nil
      end
    end

    def -@
      a = self.class.new @commodity, -@quantity
      a.precision = @precision
      a
    end

    def abs
      a = self.class.new @commodity, @quantity.abs
      a.precision = @precision
      a
    end

    # Coerces _value_ into an +Amount+ instance.
    #
    # @param [Amount,String] value  If _value_ is not already an
    #  +Amount+ instance, it should be a +String+ accepted by the
    #  {parse} method.
    # @return [Amount]
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

    # Return the zero amount of any commodity.  By default the zero
    # amount of the "null" commodity is returned.
    def self.zero(commodity = "")
      new commodity, '0'
    end

    COMMODITY_STYLE_DEFAULT   = 0x0000
    COMMODITY_STYLE_SEPARATED = 0x0001
    COMMODITY_STYLE_SUFFIXED  = 0x0002
    COMMODITY_STYLE_THOUSANDS = 0x0004
    COMMODITY_STYLE_EUROPEAN  = 0x0008

    AMOUNT_PARSE_DEFAULT    = 0x0000
    AMOUNT_PARSE_NO_MIGRATE = 0x0001
    AMOUNT_PARSE_NO_REDUCE  = 0x0004

    # Parses the given _input_ as a sequence of characters.
    #
    # @param [String,#chars] input  a String object, or any object
    #  which has a #chars method returning an +Enumerator+ over a
    #  sequence of single-character strings
    # @return [Amount]
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
          negative = if int[0] == '-'
                       int = int[1..-1]
                       true
                     else
                       false
                     end

          ts = (commodity.flags & COMMODITY_STYLE_EUROPEAN) != 0 ?  '.' : ','

          int = int.reverse.chars.each_slice(3).map { |digits|
            digits.join.reverse
          }.reverse.join(ts)

          int = "-#{int}" if negative
        end

        quant_str = int +
          ((commodity.flags & COMMODITY_STYLE_EUROPEAN) != 0 ?
           ',' : '.') +
          frac + ('0' * (precision - frac.length))
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
          "expected #{@commodity.inspect}"
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
