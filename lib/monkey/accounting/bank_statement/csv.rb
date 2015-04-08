require 'monkey/accounting'

module Monkey::Accounting

  # Parser for a bank account statement in CSV format.
  class BankStatement::CSV < BankStatement

    attr_accessor :account
    attr_accessor :file_encoding
    attr_accessor :skip_initial_rows
    attr_accessor :skip_trailing_rows
    attr_accessor :first_line_is_header
    attr_accessor :description_is_quoted
    attr_accessor :thousands_separator
    attr_accessor :date_format
    attr_accessor :date_column
    attr_accessor :description_column
    attr_accessor :debit_column
    attr_accessor :credit_column
    attr_accessor :currency_column
    attr_accessor :separator

    REQUIRED_OPTIONS = [
      :account, :date_format, :date_column, :description_column,
      :debit_column, :credit_column
    ]

    attr_accessor :header
    attr_accessor :entries

    class ParseError < RuntimeError
      attr_reader :cause

      def initialize(message, cause)
        super(message)
        @cause = cause
      end
    end

    class ParseStreamError < ParseError
      attr_reader :rownum
      attr_reader :line

      def initialize(message, cause, rownum, line)
        super(message, cause)
        @rownum = rownum
        @line = line
    end

    class ParseFileError < ParseError
      attr_reader :filename

      def initialize(message, cause, filename)
        super(message, cause)
        @filename = filename
      end
    end

    # A +CSV+ bank statement parser is initialized using an +options+
    # hash with the following required keys:
    #
    # * +:account*: name of the bank account
    # * +:date_column+: index or name of transaction date column
    # * +:description_column+: index or name of description column
    # * +:debit_column+: index or name of debit column
    # * +:credit_column+: index or name of credit column
    #
    # The +:format+ option can be used to preset some options.  The
    # options corresponding to the format are defined via
    # {Monkey.config.accounting.bank_statement.csv_formats}.
    def initialize(options = {})
      @file_encoding = 'ascii'
      @skip_initial_rows = 0
      @skip_trailing_rows = 0
      @first_line_is_header = false
      @decription_is_quoted = false
      @thousands_separator = nil
      @currency_column = nil
      @separator = ','

      @header = nil
      @entries = []

      if format = options[:format]
        options.delete :format
        csv_formats = Monkey.config.accounting.bank_statement.csv_formats
        if !csv_formats.has_key?(format)
          raise "CSV format %s has not been configured" % format.inspect
        end
        options = csv_formats[format].merge(options)
      end

      unless (missing_options = REQUIRED_OPTIONS - options.keys).empty?
        raise ArgumentError, "missing options: #{missing_options.join ' '}"
      end

      options.each { |k, v| send("#{k}=", v) }
    end

    # Parses the given file.
    def parse_file(filename, encoding = file_encoding)
      File.open(filename, "r:#{encoding}") do |input|
        begin
          parse input
        rescue RuntimeError => e
          raise ParseFileError.new("#{filename}: #{e.message}", e, filename)
        end
      end
      self
    end

    # Parses the given +input+ as a sequence of lines with fields
    # separated by a common separator character.  The +input+ object
    # must respond to the +lines+ method (e.g., String#lines or
    # IO#lines).
    def parse(input)
      rownum = 0
      @header = nil if first_line_is_header
      lines = input.lines.to_a
      lines.each do |line|
        rownum += 1

        next if rownum <= skip_initial_rows
        next if rownum > lines.size - skip_trailing_rows

        values = line.chomp.split(separator)

        if first_line_is_header and @header.nil?
          @header = values
          next
        end

        begin
          @entries << make_entry(values)
        rescue RuntimeError => e
          raise ParseStreamError.new("line #{rownum}: #{e.message}", e, rownum, line)
        end
      end
    end

    # Iterates over each element in #entries or returns an +Enumerator+
    # when called without a block.
    def each(&block)
      entries.each(&block)
    end

    private

    def column_lookup(column_id)
      case column_id
      when Fixnum
        column_id
      else
        if @header
          @header.index(column_id.to_s) or
            raise "can't get column index for unknown header field %s" %
            column_id.inspect
        else
          raise "can't look up the column index for %s without a header" %
            column_id.inspect
        end
      end
    end

    def make_entry(values)
      date = Date.strptime(values[column_lookup date_column], date_format)

      description = values[column_lookup description_column]
      if description_is_quoted
        if %w{' "}.include? description[0]
          if description[0] == description[-1]
            description = description[1...-1]
          else
            raise "unterminated quoted description: #{description.inspect}"
          end
        else
          raise "expected description to be quoted: #{description.inspect}"
        end
      end

      if column_lookup(debit_column) != column_lookup(credit_column)
        debit = values[column_lookup debit_column]
        credit = values[column_lookup credit_column]
        if !debit.empty? and !credit.empty?
          raise "can't find entry amount when debit (%s) and credit " +
            "(%s) are both non-empty" % [debit.inspect, credit.inspect]
        elsif !debit.empty?
          amount = debit
        else
          amount = credit
        end
      else
        amount = column_lookup(credit_column)
      end

      if !currency_column.nil?
        currency = values[column_lookup currency_column]
        amount = "#{amount} #{currency}"
      end

      if !thousands_separator.nil?
        case thousands_separator
        when ','
          amount.gsub!(/,/, '')
        when '.'
          amount.gsub!(/\./, '')
          amount.gsub!(/,/, '.')
        end
      end

      quantity, currency = amount.split(/ /, 2)
      commodity = Commodity.find_or_create(currency)
      amount = Amount.new(commodity, quantity)

      transactions = [Transaction.new(account, amount)]

      Entry.new(date, nil, nil, nil, description, transactions)
    end

  end

end
